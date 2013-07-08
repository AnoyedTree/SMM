
Script.Load( "lua/ConfigFileUtility.lua" );

local settings = LoadConfigFile( "MapCycle.json" );

if ( not settings ) then
	Shared.Message( "[SMM] No config file found for maps" );
	return;
end

local kMapVoteTime = 30;
local kMapVoteChangeMap = 0;
local kMapChangeEnable = false;
local kMapVoteAlert = false;
local kMapVotePlayers = {};
local kMapVoteList = {};

local kMapRTVVotes = 0;
local kMapRTVVotesMax = 6;

for k, v in pairs( settings.maps ) do
	local temp_tbl = { map = v, votes = 0 };
	table.insert(kMapVoteList, temp_tbl);
end

function MapRTV_TestCycleMap()
	if ( Shared.GetTime() < (settings.time * 60) or settings.time <= 0 ) then
		return false;
	end
	//MapRTV_VoteMap();
	return true;
end

function MapRTV_CycleMap()
	Shared.ConsoleCommand( "sv_say Type vote # for the next map you wish to play" );
	
	for i = 1, #settings.maps do
		local msg = "'vote " .. i .. "' in console for " .. settings.maps[ i ];
		if ( Shared.GetMapName() == settings.maps[ i ] ) then
			msg = "'vote " .. i .. "' in console to extend " ..settings.maps[ i ];
		end
		
		msg = "sv_say " .. msg;
		Shared.ConsoleCommand( msg );
	end
	kMapVoteChangeMap = Shared.GetTime() + kMapVoteTime;
	kMapChangeEnable = true;
end

local function MapRTV_Vote(client, num)
	num = tonumber(num);
	if ( not settings.maps[ num ] or client.hasvoted ) then return; end
	
	kMapVoteList[ num ].votes = kMapVoteList[ num ].votes + 1;
	client.hasvoted = true;
	
	//Shared.Message( "Voted for " .. kMapVoteList[ num ].map );
	local player = client:GetControllingPlayer();
	Shared.ConsoleCommand( "sv_say " .. player:GetName() .. " has voted for " .. kMapVoteList[ num ].map );
end

local function MapRTV_UpdateServer()
	if ( not kMapChangEnable ) then return; end
	
	if ( Shared.GetTime() < (kMapVoteChangeMap / 2) and not kMapVoteAlert ) then
		Shared.ConsoleCommand( "sv_say " .. (kMapVoteChangeMap / 2) .. " seconds left to vote" );
		kMapVoteAlert = true;
		return;
	end
	
	if ( Shared.GetTime() < kMapVoteChangeMap ) then return; end
	
	local nextmap = nil;
	local votes = 0;
	for k, v in pairs( kMapVoteList ) do
		if ( v.votes > votes ) then
			nextmap = v.map;
		end
	end
	
	local map = Shared.GetMapName();
	if ( map == nextmap ) then
		Shared.ConsoleCommand( "sv_say " .. map .. " has been extended." );
		kMapChangeEnable = false;
		return;
	end
	
	Shared.ConsoleCommand( "sv_changemap " .. nextmap );
end

local function MapRTV_RockTheVote( client )
	if ( client.hasvotedrtv ) then return; end

	local player = client:GetControllingPlayer();
	
	kMapRTVVotes = kMapRTVVotes + 1;
	
	//local amt = math_Clamp( Server.GetNumPlayers() / 4, kRandomCapMin - 1, kRandomCapMax );
	local amt = (kMapRTVVotesMax - kMapRTVVotes);
	
	Shared.ConsoleCommand( "sv_say " .. player:GetName() .. " wants to rock the vote (" .. amt .. " votes left)" );
	Shared.ConsoleCommand( "sv_say type 'rtv' in console" );
	
	if ( kMapRTVVotes >= kMapRTVVotesMax ) then
		MapRTV_CycleMap();
	end
	
	client.hasvotedrtv = true;
end

Event.Hook( "Console_vote", MapRTV_Vote );
//Event.Hook( "Console_mapvote", MapRTV_CycleMap );
Event.Hook( "UpdateServer", MapRTV_UpdateServer );
Event.Hook( "Console_rtv", MapRTV_RockTheVote );