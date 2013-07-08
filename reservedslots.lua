local kReservedSlots = 2;
local kReservedPassword = "thekid";

local kReservedPasswordSet = false;
local kReservedDelay = 0;

local function Reserved_SetPassword( bPassword )
	if ( kReservedPasswordSet == bPassword ) then return; end
	if ( bPassword ) then
		Server.SetPassword( kReservedPassword );
	else
		Server.SetPassword( "" );
	end
	kReservedPasswordSet = bPassword;
end

local function Reserved_ClientConnect( client )
	local maxplayers = Server.GetMaxPlayers();
	local curplayers = Server.GetNumPlayers();
	
	local used_slots = #SMM.Admins.Connected;
	
	maxplayers = (maxplayers - kReservedSlots);
	maxplayers = maxplayers + math_Clamp( used_slots, 0, kReservedSlots );
	
	if ( used_slots >= kReservedSlots ) then
		Reserved_SetPassword( false );
		return;
	end
	
	if ( curplayers >= maxplayers ) then
		Reserved_SetPassword( true );
        elseif ( not PlayerIsAdmin( client:GetUserId() ) and curplayers > maxplayers ) then
			Server.DisconnectClient( client );
		end
	end
end

local function Reserved_ClientDisconnect( client )
	local maxplayers = Server.GetMaxPlayers();
	local curplayers = Server.GetNumPlayers();
	
	local used_slots = #SMM.Admins.Connected;

	curplayers = curplayers - 1;
	
	maxplayers = (maxplayers - kReservedSlots);
	
	/*if ( PlayerIsAdmin( client:GetUserId() ) ) then
		used_slots = used_slots - 1;
	end*/
	
	maxplayers = maxplayers + math_Clamp( used_slots, 0, kReservedSlots );
	
	if ( used_slots >= kReservedSlots or curplayers < maxplayers ) then
		Reserved_SetPassword( false );
		return;
	end
end

Event.Hook( "ClientConnect", Reserved_ClientConnect );
Event.Hook( "ClientDisconnect", Reserved_ClientDisconnect );
