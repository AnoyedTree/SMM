
local kMessages = {
	"Welcome to %s, Server.GetName Enjoy your stay!",
	"Only learn to command if nobody is willing to take it",
	"Type 'rtv' in console to rock the vote",
	"Please be helpful towards rookies",
	"Type 'random' in console to initiate a random teams vote",
	"Do not disrespect anybody on this server",
	"Admins: Annoyed Tree, Shuttlesworth",
	"You can type 'votekick PLAYERNAME' in console to start a votekick",
	"Ask an admin if you have any questions towards the server",
	"This server is running Server Management Mod"
};

local kMessageTranslate = {
	[ 1 ] = { [ "Server.GetName" ] = Server.GetName() }
};

local kMessageDelay = 2.5; //in minutes
local kMessageTime = 60;
local kMessagePrint = 1;

local function Messages_Update()
	if ( Shared.GetTime() < kMessageTime or Server.GetNumPlayers() <= 0 ) then return; end
	
	local num = kMessagePrint;
	local message = kMessages[ kMessagePrint ];
	
	if ( kMessageTranslate[ num ] and #kMessageTranslate[ num ] ) then
		for k, v in pairs( kMessageTranslate[ num ] ) do
			message = string.gsub( message, k, "" );
			message = string.format( message, v );
			
			break;
		end
	end
	
	local command = string.format( "sv_say %s", message );
	Shared.ConsoleCommand( command );
	
	kMessagePrint = kMessagePrint + 1;
	if ( kMessagePrint > #kMessages ) then
		kMessagePrint = 1;
	end
	
	kMessageTime = Shared.GetTime() + (kMessageDelay * 60);
end
Event.Hook( "UpdateServer", Messages_Update );