
local kRandomVotes = 6;
local kRandomTimeout = {};
local kRandomTeams = false;
local kRandomData = {};
local kRandomClientVotes = {};

function table_count( tbl )
	if ( not tbl ) then return 0; end
	local __c = 0;
	for k, v in pairs( tbl ) do
		__c = __c + 1;
	end
	return __c;
end

function Random_RandomizeTeams( client, num )
	local gamerules = GetGamerules();
	
	local marines = gamerules.team1:GetNumPlayers();
	local aliens = gamerules.team2:GetNumPlayers();
	
	local player = nil;//Server.GetOwner( client );
	local id = nil;//player:GetUserId();
	
	if ( not num ) then //I found out all functions are inconsictent 
		player = Server.GetOwner( client ); //Why do I have to do this?
		id = player:GetUserId();
	else
		player = client:GetControllingPlayer();
		id = client:GetUserId();
		client = player;
	end
	
	local set_team = 0;
	
	if ( marines > aliens ) then
		gamerules:JoinTeam(client, 2);
		set_team = 2;
	elseif ( aliens > marines ) then
		gamerules:JoinTeam(client, 1);
		set_team = 1;
	elseif ( aliens == marines ) then
		local rand = math.random( 1, 2 );
		gamerules:JoinTeam(client, rand);
		set_team = rand;
	end
	
	//Shared.Message( "Setting " .. id .. " to " .. set_team );
	kRandomData[id] = set_team;
end

local function Random_VoteConsoleCommand( client )
	local id = client:GetUserId();
	if ( kRandomClientVotes[ id ] or kRandomTeams ) then return; end

	local player = client:GetControllingPlayer();
	id = tostring( id );
	
	if ( GetGamerules():GetGameState() ~= kGameState.NotStarted ) then
		//Server.SendNetworkMessage(player, "ServerAdminPrint", { message = "You can not vote in the middle of a game" }, true);
		return;
	end
	
	if ( not kRandomTimeout ) then
		//kRandomTimeout = Shared.GetTime() + 60;
		table.insert( kRandomTimeout, (Shared.GetTime() + 60) );
	end
	
	kRandomClientVotes[ id ] = { voted = true, time = (Shared.GetTime()+60) };
	
	//local amt = math_Clamp( Server.GetNumPlayers() / 4, kRandomCapMin - 1, kRandomCapMax );
	local amt = ( kRandomVotes - table_count(kRandomClientVotes) );
	
	Shared.ConsoleCommand( "sv_say " .. player:GetName() .. " has voted to randomize teams (" .. amt .. " votes left)" );
	Shared.ConsoleCommand( "sv_say type 'random' in console to vote" );
	
	if ( table_count(kRandomClientVotes) >= kRandomVotes ) then
		Shared.ConsoleCommand( "sv_rrall" );
		Shared.ConsoleCommand( "sv_reset" );
		//Shared.ConsoleCommand( "sv_randomall" );
		Server.ForAllPlayers( Random_RandomizeTeams );
		//Random_RandomizeTeams( Server.ForAllPlayers() );
		Shared.ConsoleCommand( "sv_say Randomizing teams..." );
		
		kRandomTeams = true;
		//return;
	end
end

local function Random_ResetTeam( client )
	if ( not kRandomTeams ) then return; end
	
	local set_team = client:GetTeamNumber();
	local player = Server.GetOwner( client );
	local id = player:GetUserId();
	
	if ( kRandomData[ id ] and kRandomData[ id ] ~= set_team ) then
		GetGamerules():JoinTeam(client, kRandomData[id]);
	end
end

local function Random_ResetScript()
	if ( not kRandomTeams ) then return; end
	
	kRandomClientVotes = {};
	kRandomData = {};
	kRandomTeams = false;
end

local function Random_VoteTimeout()
	if ( #kRandomTimeout < 1 or Shared.GetTime() < kRandomTimeout[1] ) then return; end
	table.remove(kRandomTimeout, 1);
end

local function Random_TeamCheck()
	Server.ForAllPlayers( Random_ResetTeam );
	
	Random_VoteTimeout();
	
	local gamerules = GetGamerules();
	if ( kRandomTeams and (gamerules:GetGameState() == kGameState.Team1Won or gamerules:GetGameState() == kGameState.Team2Won) ) then
		Random_ResetScript();
	end
end

local function Random_OnConnect( client )
	if ( not kRandomTeams ) then return; end
	Random_RandomizeTeams( client, true );
end

Event.Hook( "Console_random", Random_VoteConsoleCommand );
Event.Hook( "UpdateServer", Random_TeamCheck );
Event.Hook( "ClientConnect", Random_OnConnect );