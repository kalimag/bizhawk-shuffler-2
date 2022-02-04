local plugin = {}

plugin.name = "Battletoads Cross-Level Damage Shuffler"
plugin.author = "Phiggle"
plugin.minversion = "2.6.2"
plugin.settings =
{
	{ name='InfiniteLives', type='boolean', label='Infinite* Lives (see notes)' },
	{ name='ClingerSpeed', type='boolean', label='Auto-clear Clinger Winger NES (unpatched ONLY)' },
}



plugin.description =
[[
	An ill-advised modification of the excellent Mega Man Damage Shuffler plugin by authorblues and kalimag.
	
	Get swapped to a different level whenever a Battletoad takes damage.
	
	Currently supports Battletoads (NES) NTSC-U, including co-op. Additional games are planned!
	-- Optionally, you can patch some/all copies of Battletoads NES with the bugfix by Ti. Find that, and its features, here: https://www.romhacking.net/hacks/2528/
	
	----PREPARATION----
	Put copies of the ROM into the games folder, with filenames STARTING with two-digit numbers, 01, 02, 03, etc. 
	
	Each ROM will start at the level of the game you specify in the file name, or 1 if there is an error or nothing set. Mark a game as complete when you finish a level - or just play your way.
	
	For example, Battletoads NES goes up to 13 (Dark Queen). Make 13 copies, starting with 01 through 13, if you want every level to be in the shuffler once. 
		
	You should set Min and Max Seconds in the shuffler high, so you don't get time swaps in addition to damage swaps.
	-------------------	
	
	If your ROM is not recognized, no damage swap will occur.

	If you game over, you will restart at the level specified in the ROM's file name. Continues still work as usual.
	
	Optionally, you can enable Infinite* Lives, which will make it far easier to reach and defeat bosses. 
	-- It's not quite infinite. Lives refill to max ON SWAP. On your LAST game, you're done swapping, so be careful!
	-- If you truly need infinite lives on your last game, consider applying cheats in Bizhawk, or re-add a game to get a lives refill.
	-- Infinite* lives do not activate for the second player on NES Clinger Winger on an unpatched ROM, since they can't move. Use the patch if you want 2P Clinger Winger for some reason!
	
	Optionally, you can enable max speed and auto-clear Clinger Winger NES.
	-- You MUST use an unpatched ROM. The second player will not be able to move, so only 1 toad can get to the boss.
	-- You still have to beat the boss. If you use Infinite* Lives, this could make Clinger Winger fairly trivial.
	
	Enjoy?
	
]]


local prevdata = {}
local NO_MATCH = 'NONE'

local swap_scheduled = false

local shouldSwap = function() return false end



-- Which level to patch into on game load?
-- Grab the first two characters of the filename, turned into a number.
local which_level = string.sub((tostring(config.current_game)),1,2)

-- if file name starts with a number outside of 01-13, reset the level to 1
if type(tonumber(which_level)) == "number" then 
	which_level = tonumber(which_level)
		if which_level >13 or which_level <1 then which_level = 1 end
	else 
	which_level = 1
	end




level_names = { "Ragnarok's Canyon", "Wookie Hole", "Turbo Tunnel", "Arctic Caverns", "Surf City", "Karnath's Lair", "Volkmire's Inferno", "Intruder Excluder", 
"Terra Tubes", "Rat Race", "Clinger Winger", "The Revolution", "Armageddon"}


-- update value in prevdata and return whether the value has changed, new value, and old value
-- value is only considered changed if it wasn't nil before
local function update_prev(key, value)
	local prev_value = prevdata[key]
	prevdata[key] = value
	local changed = prev_value ~= nil and value ~= prev_value
	return changed, value, prev_value
end

-- This is the generic_swap from the Mega Man Damage Shuffler, modded to cover 2 potential players.
-- You can play as Rash, Zitz, or both, so the shuffler needs to monitor both toads.
-- They have the same max HP.
local function battletoads_swap(gamemeta)
	return function(data)


		local rashcurrhp = gamemeta.rashgethp()
		local rashcurrlc = gamemeta.rashgetlc()
		local zitzcurrhp = gamemeta.zitzgethp()
		local zitzcurrlc = gamemeta.zitzgetlc()

		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if rashcurrhp < minhp or rashcurrhp > maxhp then
			return false
		elseif zitzcurrhp < minhp or zitzcurrhp > maxhp then
			return false
		end

		-- retrieve previous health and lives before backup
		local rashprevhp = data.rashprevhp
		local rashprevlc = data.rashprevlc
		local zitzprevhp = data.zitzprevhp
		local zitzprevlc = data.zitzprevlc

		data.rashprevhp = rashcurrhp
		data.rashprevlc = rashcurrlc
		data.zitzprevhp = zitzcurrhp
		data.zitzprevlc = zitzcurrlc

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.rashhpcountdown ~= nil and data.rashhpcountdown > 0 then
			data.rashhpcountdown = data.rashhpcountdown - 1
			if data.rashhpcountdown == 0 and rashcurrhp > minhp then
				return true
			end
		end		
		
		if data.zitzhpcountdown ~= nil and data.zitzhpcountdown > 0 then
			data.zitzhpcountdown = data.zitzhpcountdown - 1
			if data.zitzhpcountdown == 0 and zitzcurrhp > minhp then
				return true
			end
		end

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if rashprevhp ~= nil and rashcurrhp < rashprevhp then
			data.rashhpcountdown = gamemeta.delay or 3
		elseif zitzprevhp ~= nil and zitzcurrhp < zitzprevhp then
			data.zitzhpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		-- In Battletoads NES, when you're in 1P mode, the other toad's life counter is set to 255. When they join, lives are set to 0.
		-- Thus, we ignore lives transitions from 255, to prevent unnecessary swaps when a toad "joins"
		
		if rashprevlc ~= nil and rashcurrlc < rashprevlc and rashprevlc ~= 255 then
			return true
		elseif zitzprevlc ~= nil and zitzcurrlc < zitzprevlc and zitzprevlc ~= 255 then
			return true
		end

		return false
	end
end

-- Modified version of the gamadata for Mega Mans on NES.
-- Battletoads NES shows 6 "boxes" that look like HP. 
-- But, each toad actually has a max HP of 47. 
-- If your health falls 40, you go from 6 boxes to 5. Anything from 41-47 will still show 6 boxes.
-- At 32, you have 4 boxes. At 24, 3 boxes. And so on - until a death at HP = 0.
-- We only want to shuffle when the # of HP on screen changes, because 'light' damage (say, of only 2 HP from a chop by one of the pigs at the beginning) gets partially refilled over time.
-- So, dividing the current HP value by 8, then rounding up, gives us the number of health boxes the toad has.

local gamedata = {
	['BT_NES']={ -- Battletoads NES
		func=battletoads_swap,
		rashgethp=function() return math.ceil(mainmemory.read_u8(0x051A)/8) end,
		zitzgethp=function() return math.ceil(mainmemory.read_u8(0x051B)/8) end,
		rashgetlc=function() return mainmemory.read_u8(0x0011) end,
		zitzgetlc=function() return mainmemory.read_u8(0x0012) end,
		maxhp=function() return 6 end,
	},	
	['BT_NES_patched']={ -- Battletoads NES with bugfix patch
		func=battletoads_swap,
		rashgethp=function() return math.ceil(mainmemory.read_u8(0x051A)/8) end,
		zitzgethp=function() return math.ceil(mainmemory.read_u8(0x051B)/8) end,
		rashgetlc=function() return mainmemory.read_u8(0x0011) end,
		zitzgetlc=function() return mainmemory.read_u8(0x0012) end,
		maxhp=function() return 6 end,
	},	
}

local backupchecks = {
}


-- Added recognition of the two hashes for Battletoads (U), unmodified and patched, so that we don't need a separate .dat file for just 2 games.

local function get_game_tag()
	if gameinfo.getromhash() == "5C3A497A82BE60704DEDF45248B6AD9B32C855AB" then return "BT_NES"
	elseif gameinfo.getromhash() == "24D246BA605E3592F25EB04AB4DE9FDBF2B87B14" then return "BT_NES_patched" 
	end
	
	return nil
	
end


local function BT_NES_Zitz_Override()
	if get_game_tag() == "BT_NES" --unpatched Battletoads NES
		and which_level == 11 --in Clinger Winger
		and mainmemory.read_u8(0x0011) ~= 255 --Rash is alive
	then 
		return true -- if all of those are true, then don't give Zitz all those lives, it'll more or less softlock you!
	end
	
	return false
end


function plugin.on_setup(data, settings)
	data.tags = data.tags or {}
	

end

function plugin.on_game_load(data, settings)
	local tag = get_game_tag()
	data.tags[gameinfo.getromhash()] = tag or NO_MATCH
	
	
	
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	
	-- This is a temporary fix. Future versions will implement the actual, good solution of a hash database as done in the Mega Man damage shuffler.
	
	--BATTLETOADS NES
	
	if tag == "BT_NES" or tag == "BT_NES_patched" then 
	
	-- enable Infinite* Lives for Rash if checked
	if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
		mainmemory.read_u8(0x0011) > 0 and mainmemory.read_u8(0x0011) < 255 -- is Rash on?
		then 
		mainmemory.write_u8(0x0011, 127) -- if so, set lives to 127.
	end
	
	-- enable Infinite* Lives for Zitz if checked 
	-- DOES NOT APPLY IF LEVEL = 11 AND ROM IS UNPATCHED
	if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
		mainmemory.read_u8(0x0012) > 0 and mainmemory.read_u8(0x0012) < 255 -- is Zitz on?
		then 
			if 
				BT_NES_Zitz_Override() == false -- are we outside of the 2P/unpatched/on level 11 scenario?
				then -- if so, set lives to 127.
				mainmemory.write_u8(0x0012, 127)	 
			end
	end
	
	-- if game was just loaded, these two addresses will = 255
	-- after starting or continuing, they get set to 40 or 0, respectively, and stay that way
	-- we now set these on game load, to let the player press start without sitting through the intro every time
	if mainmemory.read_u8(0x00FD) == 255 then mainmemory.write_u8(0x00FD, 40) end
	if mainmemory.read_u8(0x00FE) == 255 then mainmemory.write_u8(0x00FE, 0) end
	
	end
		

	-- first time through with a bad match, tag will be nil
	-- can use this to print a debug message only the first time
	
	local check01_13 = tonumber(string.sub((tostring(config.current_game)),1,2))
	
	
	if tag ~= nil and tag ~= NO_MATCH then
	
	if tag == "BT_NES" or tag == "BT_NES_patched" then 
		if type(check01_13) ~= "number" or check01_13 > 13 or check01_13 <= 0 then 
			log_message(string.format('OOPS. Double-check that your file names start with a two-digit number from 01 to 13. Starting you on Level 1. File name is ' .. tostring(config.current_game)))
			else
			log_message('Level ' .. tostring(which_level) .. ': ' ..  level_names[which_level] .. ' (' .. tag .. ')')	
		end
	end	
			local gamemeta = gamedata[tag]
		local func = gamemeta.func
		shouldSwap = func(gamemeta)
	elseif tag == nil then
		log_message(string.format('unrecognized? %s (%s)',
			gameinfo.getromname(), gameinfo.getromhash()))
	end
	
	
end

function plugin.on_frame(data, settings)
	-- run the check method for each individual game
	if swap_scheduled then return end
	
	local tag = get_game_tag()
	
	if tag == "BT_NES" or tag == "BT_NES_patched" then 
	
	
	-- This enables the Game Genie code for always moving at max speed in Clinger Winger. 
	-- The bugfix makes this not work! This will only work on an unpatched ROM.
		if settings.ClingerSpeed == true and which_level == 11 and memory.read_u8(0xA706) == 5 then
			memory.write_u8(0xA706, 0) 
			end
		
		

	-- Set the memory value that represents the stage to the number specified by the file name.
		if which_level ~= nil and memory.read_u8(0x8320) ~= which_level then 
			memory.write_u8(0x8320, which_level)
			end
		
	end

	
	local schedule_swap, delay = shouldSwap(prevdata)
	if schedule_swap and frames_since_restart > 10 then
		swap_game_delay(delay or 3)
		swap_scheduled = true
	end
	
	
end

return plugin
