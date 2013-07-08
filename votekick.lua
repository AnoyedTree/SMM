
local kVotekickAttempt = { kicke = nil, kicker = nil };
local kVotekickPlayer = nil;
local kVotekickExpire = 0;
local kVotekickVotes = { votes = 0, maxvotes = 8 };
local kVotekickPlayerID = {};
//local kVotekickCounter = 0;

local function Votekick_Reset( bool )
	if ( not kVotekickPlayer ) then return; end
	
	kVotekickPlayer = nil;
	kVotekickAttempt = { kicke = nil, kicker = nil };
	kVotekickVotes.votes = 0;
	kVotekickPlayerID = {};
	kVotekickExpire = Shared.GetTime();
	
	//true = expired, false = nope
	if ( not bool ) then return; end
	Shared.ConsoleCommand( "sv_say Votekick has expired" );
end

local function Votekick_Player( client )
	//local player = Server.GetOwner( client );
	
	local name = client:GetName();
	name = string.lower( name );
	
	if ( string.find( name, kVotekickAttempt.kicke ) ) then
		kVotekickPlayer = client;
		kVotekickExpire = Shared.GetTime() + 30;
		
		kVotekickVotes.votes = kVotekickVotes.votes + 1;
		local amt = (kVotekickVotes.maxvotes - kVotekickVotes.votes);
		
		Shared.ConsoleCommand( "sv_say " .. kVotekickAttempt.kicker:GetName() .. " has voted to kick " .. client:GetName() .. " (" .. amt .. " votes left)" );
		Shared.ConsoleCommand( "sv_say type 'votekick' in console" );
		
		kVotekickAttempt = { kicke = nil, kicker = nil };
		return;
	end
end

local function Votekick_Initialize( client, name )
	if ( not name and not kVotekickPlayer ) then return; end
	if ( kVotekickPlayerID[ client:GetUserId() ] ) then return; end
	
	local player = client:GetControllingPlayer();
	
	kVotekickPlayerID[ client:GetUserId() ] = true;
	
	if ( Shared.GetTime() > kVotekickExpire and not kVotekickPlayer ) then
		kVotekickAttempt.kicke = string.lower(name);
		kVotekickAttempt.kicker = player;
		Server.ForAllPlayers( Votekick_Player );
		return;
	else
		local kick_player = kVotekickPlayer;
		//kick_player = kick_player:GetControllingPlayer();
		//kick_player = Server.GetOwner( kick_player );
		
		kVotekickVotes.votes = kVotekickVotes.votes + 1;
		kVotekickExpire = Shared.GetTime() + 30;
		local amt = (kVotekickVotes.maxvotes - kVotekickVotes.votes);
		
		Shared.ConsoleCommand( "sv_say " .. player:GetName() .. " has voted to kick " .. kick_player:GetName() .. " (" .. amt .. " votes left)" );
		Shared.ConsoleCommand( "sv_say type 'votekick' in console" );
		
		if ( kVotekickVotes.votes >= kVotekickVotes.maxvotes ) then
			//Server.DisconnectClient( kVotekickPlayer );
			kick_player = Server.GetOwner( kick_player );
			
			Shared.ConsoleCommand( "sv_ban " .. kick_player:GetUserId() .. " 60" );
			Shared.ConsoleCommand( "sv_say " .. kVotekickPlayer:GetName() .. " has been banned for 1 hour" );
			Votekick_Reset( false );
		end
	end
end

local function Votekick_Think()
	if ( not kVotekickPlayer or Shared.GetTime() < kVotekickExpire ) then return; end
	
	Votekick_Reset( true );
end
Event.Hook( "Console_votekick", Votekick_Initialize );
Event.Hook( "UpdateServer", Votekick_Think );