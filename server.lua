//Server Management Modification
//Created By: Annoyed Tree

//TODO: Re-write everything and organize it

if Server then

	SMM = {};
		SMM.Admins = {};
			SMM.Admins.Connected = {};
		
	function math_Clamp( value, min, max )
		if ( value < min ) then
			value = min;
		elseif ( value > max ) then
			value = max;
		end
		return value;
	end
	
	Script.Load( "lua/dkjson.lua" );
	Script.Load( "lua/smm/loadadmins.lua" );
	//Script.Load( "lua/smm/reservedslots.lua" );
	Script.Load( "lua/smm/messages.lua" );
	Script.Load( "lua/smm/votemap.lua" );
	Script.Load( "lua/smm/voterandom.lua" );
	Script.Load( "lua/smm/votekick.lua" );
	//Script.Load( "lua/smm/connectalert.lua" );
	
	Shared.Message( "[SMM] Loaded Successfully" );
	
end