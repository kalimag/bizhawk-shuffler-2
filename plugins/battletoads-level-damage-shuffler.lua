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
	Get swapped to a different level whenever a Battletoad takes damage. An ill-advised modification of the excellent Mega Man Damage Shuffler plugin by authorblues and kalimag (which you can use at the same time if you like!).
		
	Currently supports Battletoads (NES) NTSC-U, including co-op. Additional games are planned!
	-- Optionally, you can patch some/all copies of Battletoads NES with the bugfix by Ti. Find that, and its features, here: https://www.romhacking.net/hacks/2528/
		
	Joke games for the Chaos Shuffler for twitch.tv/the_betus that also work: 
	-Anticipation (NES) - shuffles on incorrect player answers and running out of time
	-Captain Novolin (SNES)
			
	----PREPARATION----
	-Put multiple copies of Battletoads ROMs into the games folder.
	-Rename them to START with two-digit numbers, like 01, 02, 03, etc. 
	---For example: Battletoads NES goes up to 13 (Dark Queen). Make 13 copies, starting with 01 through 13, if you want every level to be in the shuffler once. 
	---(Other games don't need this step because they won't have level select. [Sorry.])
	-Set Min and Max Seconds VERY HIGH, assuming you don't want time swaps in addition to damage swaps.
	
	Each BT ROM will start at the level number you specify in the file name, or level 1 if there is an error or nothing set. 
	
	Mark a game as complete when you finish a level - or just play your way.
	-------------------	
	
	If your ROM is not recognized, no damage swap will occur.

	If you game over, you will restart at the level specified in the ROM's file name. Continues still work as usual.
	
	Optionally, you can enable Infinite* Lives, which will make it far easier to reach and defeat bosses. 
	-- It's not quite infinite. Lives refill to max ON SWAP. On your LAST game, you're done swapping, so be careful!
	-- If you truly need infinite lives on your last game, consider applying cheats in Bizhawk, or re-add a game to get a lives refill.
	-- Infinite* lives do not activate for the second player on NES Clinger Winger on an unpatched ROM, since they can't move. Use the patch if you want 2P Clinger Winger for some reason!
	
	BATTLETOADS NES:
	Optionally, you can enable max speed and auto-clear the maze in Clinger Winger NES.
	-- You MUST use an unpatched ROM. The second player will not be able to move, so only 1 toad can get to the boss.
	-- You still have to beat the boss. If you use Infinite* Lives, this could make Clinger Winger fairly trivial.
	
	Enjoy? Send bug reports?
	
]]


local prevdata = {}
local NO_MATCH = 'NONE'

local swap_scheduled = false

local shouldSwap = function() return false end



-- Which level to patch into on game load?
-- Grab the first two characters of the filename, turned into a number.
local which_level = string.sub((tostring(config.current_game)),1,2)

-- if file name starts with a number outside of 01-13, reset the level to 1
-- TODO: recode to accommodate different min and max levels (Battletoads SNES requires 00-07)
-- consider moving function elsewhere if needed

if type(tonumber(which_level)) == "number" then 
	which_level = tonumber(which_level)
		if which_level >13 or which_level <1 then which_level = 1 end
	else 
	which_level = 1
	end




bt_level_names = { "Ragnarok's Canyon", "Wookie Hole", "Turbo Tunnel", "Arctic Caverns", "Surf City", "Karnath's Lair", "Volkmire's Inferno", "Intruder Excluder", 
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
-- You can play as Rash, Zitz, or both in Battletoads NES, so the shuffler needs to monitor both toads.
-- They have the same max HP.
-- In BT NES, this should only swap when a "box" of health is taken away. That is taken care of by the ceil function.
-- In BT SNES, damage should register even if a pip of health is not eliminated by an attack there.
local function battletoads_swap(gamemeta)
	return function(data)


		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local p2currhp = gamemeta.p2gethp()
		local p2currlc = gamemeta.p2getlc()

		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if p1currhp < minhp or p1currhp > maxhp then
			return false
		elseif p2currhp < minhp or p2currhp > maxhp then
			return false
		end

		-- retrieve previous health and lives before backup
		local p1prevhp = data.p1prevhp
		local p1prevlc = data.p1prevlc
		local p2prevhp = data.p2prevhp
		local p2prevlc = data.p2prevlc

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				return true
			end
		end		
		
		if data.p2hpcountdown ~= nil and data.p2hpcountdown > 0 then
			data.p2hpcountdown = data.p2hpcountdown - 1
			if data.p2hpcountdown == 0 and p2currhp > minhp then
				return true
			end
		end

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
		elseif p2prevhp ~= nil and p2currhp < p2prevhp then
			data.p2hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		-- In Battletoads NES, when you're in 1P mode, the other toad's life counter is set to 255. When they join, lives are set to 0.
		-- Thus, we ignore lives transitions from 255, to prevent unnecessary swaps when a toad "joins"
		
		if p1prevlc ~= nil and p1currlc < p1prevlc and p1prevlc ~= 255 then
			return true
		elseif p2prevlc ~= nil and p2currlc < p2prevlc and p2prevlc ~= 255 then
			return true
		end

		return false
	end
end

local function novolin_swap(gamemeta)
	return function(data)


		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()

		local maxhp = gamemeta.maxhp()
		local minhp = 0

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if p1currhp < minhp or p1currhp > maxhp then
			return false
		end

		-- retrieve previous health and lives before backup
		local p1prevhp = data.p1prevhp
		local p1prevlc = data.p1prevlc

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				return true
			end
		end		
	

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		if p1prevlc ~= nil and p1currlc < p1prevlc then
			return true
		end

		return false
	end
end

local function antic_swap(gamemeta) 
	return function(data)
	-- We will swap on 3 scenarios. They work across all players.
	-- 1. There is a specific address that goes to 192 when a human player gets a letter wrong, then ticks down frame by frame to 0 or 16. Never moves up otherwise.
	-- 2. There is an address that counts down the die from 6 to 0. When you run out of time, this value hits 0, and you should swap.
	-- 3. There is an address that counts down the time to type in a guess. A CPU player will always provide a correct answer when this activates. 
	-- However, when a human player runs out of time, this hits 0, then goes to 255. This should swap on 255, IGNORING the title screen.
	-- THESE VARIABLES ARE SHARED IN MULTIPLAYER YAY
	
	
	
		local currbotchedletter = gamemeta.getbotchedletter() 
		local currbuzzintime = gamemeta.getbuzzintime() 
		local currtypetime = gamemeta.gettypetime()


		-- retrieve previous values for botch, buzz-in, and typing time
		local prevbotchedletter = data.prevbotchedletter
		local prevbuzzintime = data.prevbuzzintime
		local prevtypetime = data.prevtypetime

		data.prevbotchedletter = currbotchedletter
		data.prevbuzzintime = currbuzzintime
		data.prevtypetime = currtypetime

		--wrong letter
		if prevbotchedletter ~= nil and currbotchedletter > prevbotchedletter then -- remember, only goes up when a wrong answer is guessed.
			return true
		end
		
		--ran out of time to buzz in (ranges from 0-6, resets to 6 once the die appears, shuffle on drop to 0)
		if prevbuzzintime ~= nil and 
			currbuzzintime < prevbuzzintime and -- it'll stay on 0 for a while.
			currbuzzintime == 0 then 
		
		-- NOTE: will reset to 0 also when all human players are out of guesses and no one else can answer. We don't want a second swap in those cases. 
		-- In this case, currbotchedletter will == 0 or 16, and guess time will be < 25.
			if currtypetime < 25 and currbotchedletter == 0 or currbotchedletter == 16 then return false end 
			
			return true
		end
		
		--ran out of time to type answer (ranges from 0-25, goes to 255 when timer is completely done)
		if prevtypetime ~= nil and prevtypetime == 0 and currtypetime == 255 then -- it'll stay on 255 for a while.
			return true
		end
	
		return false 
	end
end



-- Modified version of the gamedata for Mega Man games on NES.
-- Battletoads NES shows 6 "boxes" that look like HP. 
-- But, each toad actually has a max HP of 47. Each box is basically 8 HP.
-- If your health falls 40, you go from 6 boxes to 5. Anything from 41-47 will still show 6 boxes.
-- At 32, you have 4 boxes. At 24, 3 boxes. And so on - until a death at HP = 0.
-- We only want to shuffle when the # of HP on screen changes, because 'light' damage (say, of only 2 HP from a chop by one of the pigs at the beginning) gets partially refilled over time.
-- So, dividing the current HP value by 8, then rounding up, gives us the number of health boxes the toad has.

local gamedata = {
	['BT_NES']={ -- Battletoads NES
		func=battletoads_swap,
		p1gethp=function() return math.ceil(mainmemory.read_u8(0x051A)/8) end,
		p2gethp=function() return math.ceil(mainmemory.read_u8(0x051B)/8) end,
		p1getlc=function() return mainmemory.read_u8(0x0011) end,
		p2getlc=function() return mainmemory.read_u8(0x0012) end,
		maxhp=function() return 6 end,
	},	
	['BT_NES_patched']={ -- Battletoads NES with bugfix patch
		func=battletoads_swap,
		p1gethp=function() return math.ceil(mainmemory.read_u8(0x051A)/8) end,
		p2gethp=function() return math.ceil(mainmemory.read_u8(0x051B)/8) end,
		p1getlc=function() return mainmemory.read_u8(0x0011) end,
		p2getlc=function() return mainmemory.read_u8(0x0012) end,
		maxhp=function() return 6 end,
	},	
	['Novolin']={ -- Captain Novolin SNES
		func=novolin_swap,
		p1gethp=function() return bit.band(mainmemory.read_u8(0x0BDA), 0x7F) end,
		p1getlc=function() return mainmemory.read_u8(0x06C3) end,
		maxhp=function() return 4 end,
	},	
	['Anticipation']={ -- Anticipation NES
		func=antic_swap,
		getbotchedletter=function() return mainmemory.read_u8(0x00C3) end,
		getbuzzintime=function() return mainmemory.read_u8(0x007F) end,
		gettypetime=function() return mainmemory.read_u8(0x0086) end,
	},	
}

local backupchecks = {
}


-- Added recognition of the hashes for Battletoads (U), unmodified and patched, and additional games.
-- This is a temporary fix. Future versions will reimplement the actual, good solution of a hash database as done in the Mega Man damage shuffler.

local function get_game_tag()
	if gameinfo.getromhash() == "5C3A497A82BE60704DEDF45248B6AD9B32C855AB" then return "BT_NES"
	elseif gameinfo.getromhash() == "24D246BA605E3592F25EB04AB4DE9FDBF2B87B14" then return "BT_NES_patched" 
	elseif gameinfo.getromhash() == "72CFB569819DA4E799BF8FA1A6F023664CC7069B" then return "Novolin" 
	elseif gameinfo.getromhash() == "3634826A2A03074928052F90928DA10DC715E77B" then return "Anticipation" 
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
	
	
	local levelnumber = tonumber(which_level)
	
	
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	
	
	
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
	
	
	--CAPTAIN NOVOLIN
	
	if tag == "Novolin" then 
	
	-- enable Infinite* Lives for Captain Novolin if checked
		if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
			mainmemory.read_u8(0x06C3) > 0 and mainmemory.read_u8(0x06C3) < 255 -- have we started playing?
			then 
			mainmemory.write_u8(0x06C3, 69) -- if so, set lives to 69. Nice.
		end
	end

		

	-- first time through with a bad match, tag will be nil
	-- can use this to print a debug message only the first time
	
	
	if tag ~= nil and tag ~= NO_MATCH then
		local gamemeta = gamedata[tag]
		local func = gamemeta.func
		shouldSwap = func(gamemeta)
	end
	
	---log stuff
	if tag == "BT_NES" or tag == "BT_NES_patched" then 
		if type(levelnumber) ~= "number" or levelnumber > 13 or levelnumber <= 0 then 
			log_message(string.format('OOPS. Double-check that your file names start with a two-digit number from 01 to 13. Starting you on Level 1. File name is ' .. tostring(config.current_game)))
		else
			log_message('Level ' .. tostring(which_level) .. ': ' ..  bt_level_names[which_level] .. ' (' .. tag .. ')')
		end
		elseif tag == "Novolin" then 
			log_message(string.format('Captain Novolin (SNES)'))
		elseif tag == "Anticipation" then 
			log_message(string.format('Anticipation (NES)'))
		elseif tag == nil or tag == NO_MATCH then
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
