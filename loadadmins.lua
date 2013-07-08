
Script.Load( "lua/ConfigFileUtility.lua" );

local settings = LoadConfigFile( "ServerAdmin.json" );

if ( not settings ) then
	Shared.Message( "[SMM] - Error obtaning config file for admins" );
	return;
end

local function AddAdmin( id )
	table.insert( SMM.Admins, id );
	Shared.Message( string.format( "[SMM] SteamID '%s' added to admins", id ) );
end

//AddAdmin( 41841254 );
//AddAdmin( 126534365 );

for k, v in pairs( settings.users ) do
	AddAdmin( v.id );
end

function PlayerIsAdmin( steamid )
	for k, v in pairs( SMM.Admins ) do
		if ( v == steamid ) then
			return true;
		end
	end
	
	return false;
end

local function AddAdminOnConnect( client )
	if ( PlayerIsAdmin( client:GetUserId() ) ) then
		table.insert( SMM.Admins.Connected, client:GetUserId() );
	end
end
Event.Hook( "ClientConnect", AddAdminOnConnect );

local function RemoveAdminFromTable( client )
	if ( PlayerIsAdmin( client:GetUserId() ) ) then
		table.remove( SMM.Admins.Connected, client:GetUserId() );
	end
end
Event.Hook( "ClientDisconnect", RemoveAdminFromTable );