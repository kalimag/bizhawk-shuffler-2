local plugin = {}

plugin.name = "Battletoads Chaos Damage Shuffler"
plugin.author = "Phiggle"
plugin.minversion = "2.6.2"
plugin.settings =
{
	{ name='InfiniteLives', type='boolean', label='Infinite* Lives (see notes)' },
	{ name='ClingerSpeed', type='boolean', label='BT NES: Auto-Clinger-Winger (unpatched ONLY)' },
	{ name='BTSNESRash', type='boolean', label='BT SNES: I want Rash, pick 2P, give Pimple 1 HP'},
	{ name='SuppressLog', type='boolean', label='Suppress "ROM unrecognized"/"on Level 1" logs'},
}



plugin.description =
[[
	Get swapped to a different level whenever a Battletoad takes damage. Additional games shuffle on 'damage', see below. Multiplayer shuffling supported. If your ROM is not recognized, no damage swap will occur.
	
	See instructions to have multiple Battletoads games that start (or continue) at the level you specify.
	
	This is a mod of the excellent Mega Man Damage Shuffler plugin by authorblues and kalimag. Thank you to Diabetus for extensive playthroughs that tracked down bugs!
	
	Currently supports (ALL NTSC-U):
	-Battletoads (NES), 1p or 2p - also works with the bugfix patch by Ti: https://www.romhacking.net/hacks/2528/
	-Battletoads in Battlemaniacs (SNES), 1p or 2p
	-Battletoads-Double Dragon (NES), 1p or 2p
	-Battletoads-Double Dragon (SNES), 1p or 2p, including if patched to use level select by default (see instructions)
	
	-Anticipation (NES), up to 4 players, shuffles on incorrect player answers, correct CPU answers, and running out of time.
	-Captain Novolin (SNES)
	-Super Mario Kart (SNES), 1p or 2p - shuffles on bumps, falls, and being shrunk
	
	You can run the Mega Man Damage Shuffler plugin at the same time, with no conflicts.
	
	More games planned!
		
	----PREPARATION----
	-Set Min and Max Seconds VERY HIGH, assuming you don't want time swaps in addition to damage swaps.
	
	-Non-Battletoads games: just put your game in the games folder.
	
	-Battletoads games: 
	-Put multiple copies of your ROM into the games folder - one for every starting level you want to include.
	-Rename those files to START with two-digit numbers, like 01, 02, 03, etc., as below.
	
	Battletoads (NES): 
	-Level range: 01 to 13
	-How to level select: Automatically enabled.
	
	Battletoads in Battlemaniacs (SNES):
	-Level range: 01 to 08
	-How to level select: Pimple will start with 1 HP and no lives if you specify a level higher than 1, OR if you click the "I want Rash" option. Let Pimple die, and then continue (if using Pimple - it gets refunded) or don't (if playing 2P/using Rash). You get an on-screen reminder to do this, and it is gone when you shuffle back.
	
	Battletoads-Double Dragon (NES): 
	-Level range: 01 to 14
	-How to level select: Level select screen is automatically enabled. A message on screen the first time will tell you which level to pick after character select.
	
	Battletoads-Double Dragon (SNES): 
	-Level range: 01 to 14
	-How to level select: A message on screen the first time will tell you what level to pick after you choose characters. But, for now, you have to enable level select yourself :( 
	--OPTION ONE: just enter the cheat code at the character select screen. The screen blinks when it's entered correctly.
	--OPTION TWO: Patch your ROM(s) with the Game Genie code DD6F-1923. Here is a patcher! https://www.romhacking.net/utilities/1054/
	

	----EXAMPLES AND TIPS----
	To shuffle every single level of Battletoads NES, make 13 copies with filenames starting with 01 through 13.
	
	You can include one copy each of all these Battletoads games, with no special naming, to simply have damage shuffling starting from level 1.
	
	If you want a Battletoads-Double Dragon run without mid-level checkpoints (1-1, 2-1, 3-1, ... 7-1), then only add files that start with: 01, 03, 06, 09, 11, 13, 14.
	
	You could do an "all Turbo Tunnels" run with BT NES = 03, BTDD (either/both) = 05, and BT SNES = 04. Throw in Surf City (BT NES 05), Volkmire's Inferno (BT NES 07), Roller Coaster (BT SNES 06), the awful spaceship levels (BTDD 09 and 10)...
	
	Mark a ROM "cleared" whenever you want! I recommend you do so after completing a level.
				
	----OPTIONS----	
	
	Infinite* Lives will make it far easier to reach and defeat bosses.
	-- It's not quite infinite. Lives refill ON SWAP. On your LAST game, you're done swapping, so be careful!
	-- If you truly need infinite lives on your last game, consider applying cheats in Bizhawk, or re-add a game to get a lives refill.
	-- Infinite* lives do not activate for the second player on NES Clinger-Winger on an unpatched ROM, since they can't move. Use the patch if you want 2P Clinger-Winger for some reason!
	-- Anticipation NES does not have lives.
	
	Auto-Clinger-Winger NES: You can enable max speed and auto-clear the maze (level 11).
	-- You MUST use an unpatched ROM. The second player will not be able to move, so only Rash can get to the boss in 2p. Infinite Lives are disabled in this scenario.
	-- You still have to beat the boss. If you use Infinite* Lives, this could make Clinger-Winger fairly trivial.
	
	Rash 1-player mode in Battlemaniacs (SNES): see above! Start in 2p, let Pimple die to deathwarp, and make sure your 2p controller is mapped the same as 1p aside from Start.
	
	Suppress Logs: if you do not want the lua console log to tell you about file naming errors, or unrecognized ROMs. This can help keep the log cleaner if you are also using the Mega Man Damage Shuffler or other plugins!
	
	Enjoy? Send bug reports?
	
]]


local prevdata = {}
local NO_MATCH = 'NONE'

local swap_scheduled = false

local shouldSwap = function() return false end




-- Added recognition of the hashes for Battletoads (U), unmodified and patched, and additional games.
-- This is a temporary fix. Future versions will reimplement the actual, good solution of a hash database as done in the Mega Man damage shuffler.

local function get_game_tag()
	if gameinfo.getromhash() == "5C3A497A82BE60704DEDF45248B6AD9B32C855AB" then return "BT_NES"
	elseif gameinfo.getromhash() == "24D246BA605E3592F25EB04AB4DE9FDBF2B87B14" then return "BT_NES_patched" 
	elseif gameinfo.getromhash() == "61832D0F955CFF169FF059BD557BE4F522B15B7C" then return "BTDD_NES" 
	elseif gameinfo.getromhash() == "3041C5C2A88449CF358A57D019930849575F8F6D" then return "BT_SNES" 
	elseif gameinfo.getromhash() == "BF56F12BDDE3E2233D7FFCAF4825B10D92632B77" then return "BTDD_SNES" 
	elseif gameinfo.getromhash() == "0248CF714380D11E38A4C242A001E97164D477F5" then return "BTDD_SNES_patched" -- patched for level select
	elseif gameinfo.getromhash() == "72CFB569819DA4E799BF8FA1A6F023664CC7069B" then return "Novolin" 
	elseif gameinfo.getromhash() == "3634826A2A03074928052F90928DA10DC715E77B" then return "Anticipation" 
	elseif gameinfo.getromhash() == "47E103D8398CF5B7CBB42B95DF3A3C270691163B" then return "SMK_SNES" 
	end
	
	return nil
	
end


-- Which level to patch into on game load?
-- Grab the first two characters of the filename, turned into a number.
local which_level_filename = string.sub((tostring(config.current_game)),1,2)
local which_level = which_level_filename

-- if file name starts with a number outside of the expected range, reset the level to 1
-- TODO: recode to accommodate different min and max levels (Battletoads SNES requires 00-08)
-- I sure am great at coding!!
-- consider moving function elsewhere if needed

if type(tonumber(which_level)) == "number" then 
	which_level = tonumber(which_level)
	--BT_NES
		if get_game_tag(current_game) == "BT_NES" or get_game_tag(current_game) == "BT_NES_patched" then 
		if which_level >13 or which_level <1 then which_level = 1 end
		end
	--BT_SNES
		if get_game_tag(current_game) == "BT_SNES" then 
		if which_level >8 or which_level <1 then which_level = 1 end
		end
	--BTDD (both)
		if get_game_tag(current_game) == "BTDD_NES" or get_game_tag(current_game) == "BTDD_SNES" or get_game_tag(current_game) == "BTDD_SNES_patched" then 
		if which_level >14 or which_level <1 then which_level = 1 end
		end
	else 
	which_level = 1
	end


bt_nes_level_names = { "Ragnarok's Canyon", "Wookie Hole", "Turbo Tunnel", "Arctic Caverns", "Surf City", "Karnath's Lair", "Volkmire's Inferno", "Intruder Excluder", 
"Terra Tubes", "Rat Race", "Clinger-Winger", "The Revolution", "Armageddon"}


btdd_level_names = { "1-1", "1-2", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "5-1", "5-2", "6-1", "7-1"}

bt_snes_level_names = { "Khaos Mountains", "Hollow Tree", "Bonus Stage 1", "Turbo Tunnel Rematch", "Karnath's Revenge", "Roller Coaster", "Bonus Stage 2", "Dark Tower"}

bt_snes_level_recoder = { 0, 1, 2, 3, 4, 6, 8, 7 } -- THIS GAME DOESN'T STORE LEVELS IN THE ORDER YOU PLAY THEM, COOL



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
	
	
		local tag = get_game_tag()


		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local p1currcont = gamemeta.p1getcont()
		local p1currsprite = gamemeta.p1getsprite()
		local p2currhp = gamemeta.p2gethp()
		local p2currlc = gamemeta.p2getlc()
		local p2currcont = gamemeta.p2getcont()
		local p2currsprite = gamemeta.p2getsprite()

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
		local p1prevcont = data.p1prevcont
		local p1prevsprite = data.p1prevsprite
		local p2prevhp = data.p2prevhp
		local p2prevlc = data.p2prevlc
		local p2prevsprite = data.p2prevsprite

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p1prevcont = p1currcont
		data.p1prevsprite = p1currsprite
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc
		data.p2prevcont = p2currcont
		data.p2prevsprite = p2currsprite
		
		-- BT SNES likes to do a full 0-out of some memory values when you load a level. 
		-- That should NOT shuffle! 
		-- Return false if that is happening.
		
		if tag == "BT_SNES" and 
		p1currhp == 0 and p2currhp == 0 and --values dropped to 0
		p1currsprite == 0 and p2currsprite == 0 -- if both are 0, neither player is even on screen
		then return false end

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
		-- Similarly, some garbage values above 255 exist for BTDD SNES, and swaps occur when 2p is dropped to 0 HP/lives in 1p mode.
		
		-- TODO: maxlc, like maxhp?
		
		if p1prevlc ~= nil and p1currlc == (p1prevlc - 1) and p1prevlc < 255 then
			return true
		elseif p2prevlc ~= nil and p2currlc == (p2prevlc - 1) and p2prevlc < 255 then
			return true
		end
		
		
		-- In Battletoads SNES bonus levels, your pins/domino count can go down without your health going down.
		-- BUT NO, WE NEED TO SHUFFLE ON THOSE!! 
		-- but not once you're dead. That countdown shouldn't count.
		-- I CANNOT IMAGINE WHY, but this does not count up in a linear fashion.
		
		-- To simplify things, we will just swap when the "I've been hit" sprite is called.
		
		if tag == "BT_SNES" then
			if 
			memory.read_u8(0x00002C) == 2 or memory.read_u8(0x00002C) == 8 -- we are in the proper level, 2 (Pins) or 8 (Dominoes)
			then 
				if p1prevsprite ~= p1currsprite and p1currsprite == 128 -- p1 was JUST hit (prior value was not the same)
				then return true
					elseif p2prevsprite ~= p2currsprite and p2currsprite == 236 -- p1 was JUST hit (prior value was not the same)
					then return true
				end
			end
		end
				
		
		-- In Battletoads NES, we want to swap on a continue. 
		-- In Battletoads NES, you use a continue joining the game, so we should not swap when using the first continue (when continues = 3).
		
		if tag == "BT_NES" or tag == "BT_NES_patched" then
		if p1prevcont ~= nil and p1prevcont < 3 and p1currcont < p1prevcont then
			return true
		elseif p2prevcont ~= nil and p2prevcont < 3 and p2currcont < p2prevcont then
			return true
		end
		end
		
		--- might be wise to separate NES and SNES functions in future release

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
	
	-- 4. We can now swap on a correct computer answer.
	-- Found value that is "who buzzed in"
	-- Found value for "faded out with correct answer," rolls up from 0 to 31
	-- if the computer rang in, and that value increases to 31, SWAP
	
	-- human player value 00AC can be 1, 2, 3, 4 
	
	-- when who buzzed in > than 00AC, then we should swap if they get it right
	
	
		local currbotchedletter = gamemeta.getbotchedletter() 
		local currbuzzintime = gamemeta.getbuzzintime() 
		local currtypetime = gamemeta.gettypetime()
		local curranswerright = gamemeta.getanswerright()


		-- retrieve previous values for botch, buzz-in, and typing time, as well as roll-up for correct answer
		local prevbotchedletter = data.prevbotchedletter
		local prevbuzzintime = data.prevbuzzintime
		local prevtypetime = data.prevtypetime
		local prevanswerright = data.prevanswerright

		data.prevbotchedletter = currbotchedletter
		data.prevbuzzintime = currbuzzintime
		data.prevtypetime = currtypetime
		data.prevanswerright = curranswerright

		--wrong letter
		if prevbotchedletter ~= nil and currbotchedletter > prevbotchedletter then -- remember, only goes up when a wrong answer is guessed.
			return true
		end
		
		--ran out of time to buzz in (ranges from 0-6, resets to 6 once the die appears, shuffle on drop to 0)
		if memory.read_u8(0x046E) <= -- who rang in, defaults to 0
			memory.read_u8(0x00AC) -- how many humans, defaults to 1 - so, not a computer player being award spaces
		and prevbuzzintime ~= nil and prevbuzzintime ~= 255 and 
			currbuzzintime < prevbuzzintime and -- it'll stay on 0 for a while.
			currbuzzintime == 0 then 
		
		-- NOTE: will reset to 0 also when all human players are out of guesses and no one else can answer. We don't want a second swap in those cases. 
		-- In this case, currbotchedletter will == 0 or 16, and guess time will be < 25.
			if currtypetime < 25 and (currbotchedletter == 0 or currbotchedletter == 16) then return false end 
			
			return true
		end
		
		--ran out of time to type answer (ranges from 0-25, goes to 255 when timer is completely done)
		if prevtypetime ~= nil and prevtypetime == 0 and currtypetime == 255 then -- it'll stay on 255 for a while.
			return true
		end
		
		--CPU correct answer swap
		if memory.read_u8(0x046E) > -- who rang in, defaults to 0
			memory.read_u8(0x00AC) -- how many humans, defaults to 1
			and prevanswerright ~= nil
			and curranswerright > prevanswerright -- this value rolls up when a card is awarded
			and curranswerright == 31 -- and hits 31 at max
			then return true -- swap!
		end 

		return false 
	end
end


local function smk_swap(gamemeta)
	return function(data)
	
	
		local p1currcoins = gamemeta.p1getcoins()
		local p2currcoins = gamemeta.p2getcoins()
		local p1currbump = gamemeta.p1getbump()
		local p2currbump = gamemeta.p2getbump()
		local p1currfall = gamemeta.p1getfall()
		local p2currfall = gamemeta.p2getfall()
		local p1currshrink = gamemeta.p1getshrink()
		local p2currshrink = gamemeta.p2getshrink()
	

		-- retrieve previous health and lives before backup
		local p1prevcoins = data.p1prevcoins
		local p2prevcoins = data.p2prevcoins
		local p1prevbump = data.p1prevbump
		local p2prevbump = data.p2prevbump
		local p1prevfall = data.p1prevfall
		local p2prevfall = data.p2prevfall
		local p1prevshrink = data.p1prevshrink
		local p2prevshrink = data.p2prevshrink

		data.p1prevcoins = p1currcoins
		data.p2prevcoins = p2currcoins
		data.p1prevbump = p1currbump
		data.p2prevbump = p2currbump
		data.p1prevfall = p1currfall
		data.p2prevfall = p2currfall
		data.p1prevshrink = p1currshrink
		data.p2prevshrink = p2currshrink
		
		--if p1prevcoins ~= nil and p1currcoins > p1prevcoins then
		--	return true
		--elseif p2prevcoins ~= nil and p2currcoins > p2prevcoins then
		--	return true
		--end
		
		
		-- if the bump value is triggered, swap. It's 0, goes up, then counts down, so we just want to know if it is greater than the previous value.
		

		if p1prevbump ~= nil and p1currbump > p1prevbump 
			and mainmemory.read_u8(0x001086) == 0 -- p1 not invincible
			then return true
		end

		---p2 has to be active
		if(mainmemory.read_u8(0x0011D2)) == 2 and
		p2prevbump ~= nil and p2currbump > p2prevbump 
			and mainmemory.read_u8(0x001186) == 0 -- p2 not invincible
		then return true
		end

		-- if the fall value is triggered, swap. It's usually 0, goes up, then counts down. 
		-- This number only goes over 0 with a pitfall/Lakitu. You will reset to 0 when you can drive again.
		-- So we just want to know if it is greater than 0 and greater than the previous value.
		
		if p1prevfall ~= nil and p1prevfall == 0 and p1currfall > p1prevfall and p1currfall > 5 then
			return true
		end
		
		---p2 has to be active
		if(mainmemory.read_u8(0x0011D2)) == 2 and
		p2prevfall ~= nil and p2prevfall == 0 and p2currfall > p2prevfall and p2currfall > 5 then
			return true
		end
		
		--- shrunk
		
		if p1prevshrink ~= nil and p1prevshrink == 0 and p1currshrink > p1prevshrink then
			return true end
		
		---p2 has to be active
		if(mainmemory.read_u8(0x0011D2)) == 2 and
		p2prevshrink ~= nil and p2prevshrink == 0 and p2currshrink > p2prevshrink then
			return true
		end
		
		-- THERE ARE SOME BOGUS SWAPS THAT HAPPEN IN 1P DUE TO 2P VALUES. NEED A VAR TO REPRESENT IF A HUMAN IS CONTROLLING 2P
		-- ONCE THAT FOUND, THEN MAKE ALL 2P SWAPS CONDITIONAL ON 2P BEING HUMAN

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
		p1getcont=function() return mainmemory.read_u8(0x000E) end,
		p2getcont=function() return mainmemory.read_u8(0x000F) end,
		p1getsprite=function() return nil end, -- N/A
		p2getsprite=function() return nil end, -- N/A
		maxhp=function() return 6 end,
	},	
	['BT_NES_patched']={ -- Battletoads NES with bugfix patch
		func=battletoads_swap,
		p1gethp=function() return math.ceil(mainmemory.read_u8(0x051A)/8) end,
		p2gethp=function() return math.ceil(mainmemory.read_u8(0x051B)/8) end,
		p1getlc=function() return mainmemory.read_u8(0x0011) end,
		p2getlc=function() return mainmemory.read_u8(0x0012) end,
		p1getcont=function() return mainmemory.read_u8(0x000E) end,
		p2getcont=function() return mainmemory.read_u8(0x000F) end,
		p1getsprite=function() return nil end, -- N/A
		p2getsprite=function() return nil end, -- N/A
		maxhp=function() return 6 end,
	},	
	['BTDD_NES']={ -- Battletoads Double Dragon NES
		func=battletoads_swap,
		p1gethp=function() return math.ceil(mainmemory.read_u8(0x051B)/8) end,
		p2gethp=function() return math.ceil(mainmemory.read_u8(0x051C)/8) end,
		p1getlc=function() return mainmemory.read_u8(0x0011) end,
		p2getlc=function() return mainmemory.read_u8(0x0012) end,
		p1getcont=function() return mainmemory.read_u8(0x000E) end,
		p2getcont=function() return mainmemory.read_u8(0x000F) end,
		p1getsprite=function() return nil end, -- N/A 
		p2getsprite=function() return nil end, -- N/A
		maxhp=function() return 6 end,
	},	
	['BT_SNES']={ -- Battletoads in Battlemaniacs for SNES
		func=battletoads_swap,
		p1gethp=function() return mainmemory.read_u8(0x000E5E) end,
		p2gethp=function() return mainmemory.read_u8(0x000E60) end,
		p1getlc=function() return mainmemory.read_u8(0x000028) end,
		p2getlc=function() return mainmemory.read_u8(0x00002A) end,
		p1getcont=function() return mainmemory.read_u8(0x00002E) end,
		p2getcont=function() return mainmemory.read_u8(0x000030) end,
		p1getsprite=function() return mainmemory.read_u8(0x000AEE) end, -- this is an address for the sprite called for p1
		p2getsprite=function() return mainmemory.read_u8(0x000AF0) end, -- this is an address for the sprite called for p2
		maxhp=function() return 16 end,
	},	
	['BTDD_SNES']={ -- Battletoads Double Dragon SNES
		func=battletoads_swap,
		p1gethp=function() return math.ceil(mainmemory.read_u8(0x00003A)/8) end,
		p2gethp=function() return math.ceil(mainmemory.read_u8(0x00003C)/8) end,
		p1getlc=function() return mainmemory.read_u8(0x000026) end,
		p2getlc=function() return mainmemory.read_u8(0x000028) end,
		p1getcont=function() return mainmemory.read_u8(0x000010) end,
		p2getcont=function() return mainmemory.read_u8(0x000012) end,
		p1getsprite=function() return nil end, -- N/A 
		p2getsprite=function() return nil end, -- N/A
		maxhp=function() return 6 end,
	},	
	['BTDD_SNES_patched']={ -- Battletoads Double Dragon SNES
		func=battletoads_swap,
		p1gethp=function() return math.ceil(mainmemory.read_u8(0x00003A)/8) end,
		p2gethp=function() return math.ceil(mainmemory.read_u8(0x00003C)/8) end,
		p1getlc=function() return mainmemory.read_u8(0x000026) end,
		p2getlc=function() return mainmemory.read_u8(0x000028) end,
		p1getcont=function() return mainmemory.read_u8(0x000010) end,
		p2getcont=function() return mainmemory.read_u8(0x000012) end,
		p1getsprite=function() return nil end, -- N/A 
		p2getsprite=function() return nil end, -- N/A
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
		getanswerright=function() return mainmemory.read_u8(0x00A0) end,
	},	
	['SMK_SNES']={ -- Super Mario Kart
		func=smk_swap,
		p1getcoins=function() return mainmemory.read_u8(0x000E00) end,
		p2getcoins=function() return mainmemory.read_u8(0x000E02) end, 
		p1getbump=function() return mainmemory.read_u8(0x00105E) end, -- if > 0 then p1 is bumping/crashing
		p2getbump=function() return mainmemory.read_u8(0x00115E) end, -- if > 0 then p2 is bumping/crashing
		p1getfall=function() return mainmemory.read_u8(0x0010CA) end, -- if > 2 then p1 is falling - this is also the Lakitu timer! 2 is jumping, normal or feather
		p2getfall=function() return mainmemory.read_u8(0x0011CA) end, -- if > 2 then p2 is falling - this is also the Lakitu timer! 2 is jumping, normal or feather
		p1getshrink=function() return mainmemory.read_u8(0x001084) end, -- if > 0 then you're small and it's counting down
		p2getshrink=function() return mainmemory.read_u8(0x001184) end, -- if > 0 then you're small and it's counting down
	},	
}

local backupchecks = {
}



local function BT_NES_Zitz_Override()
	if get_game_tag() == "BT_NES" --unpatched Battletoads NES
		and memory.read_u8(0x000D) == 11 --in Clinger-Winger
		and memory.read_u8(0x0011) ~= 255 --Rash is alive
	then 
		return true -- if all of those are true, then don't give Zitz all those lives, it'll more or less softlock you!
	end
	
	return false
end

--TODO: Ensure Zitz lives get set down to 0 in this scenario.

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
	
	--TODO: set min and max level variable by game
	
	--BATTLETOADS NES AND BATTLETOADS DOUBLE DRAGON NES
	
	if tag == "BT_NES" or tag == "BT_NES_patched" or tag == "BTDD_NES" then 
	
	-- enable Infinite* Lives for Rash (p1) if checked
	if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
		mainmemory.read_u8(0x0011) > 0 and mainmemory.read_u8(0x0011) < 255 -- is Rash on?
		then 
		mainmemory.write_u8(0x0011, 127) -- if so, set lives to 127.
	end
	
	-- enable Infinite* Lives for Zitz (p2) if checked 
	-- DOES NOT APPLY IF LEVEL = 11 AND ROM IS UNPATCHED
	if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
		mainmemory.read_u8(0x0012) > 0 and mainmemory.read_u8(0x0012) < 255 -- is Zitz on?
		then 
			if 
				BT_NES_Zitz_Override() == false -- are we outside of the 2P/unpatched/on level 11 scenario?
				then -- if so, set lives to 127.
				mainmemory.write_u8(0x0012, 127)	
			elseif memory.read_u8(0x000D) == 11 then memory.write_u8(0x0012, 0) -- Otherwise, get Zitz to 0 lives immediately if you arrived at Clinger-Winger
			end
	end
	end
	
	
	if tag == "BT_NES" or tag == "BT_NES_patched" then
	-- if game was just loaded, these two addresses will = 255
	-- after starting or continuing, they get set to 40 or 0, respectively, and stay that way
	-- we now set these on game load, to let the player press start without sitting through the intro every time
	if mainmemory.read_u8(0x00FD) == 255 then mainmemory.write_u8(0x00FD, 40) end
	if mainmemory.read_u8(0x00FE) == 255 then mainmemory.write_u8(0x00FE, 0) end
	
	end
	
	
	-- Battletoads Double Dragon (SNES)
	
	if tag == "BTDD_SNES" or tag == "BTDD_SNES_patched" then --TODO: Improve storage system for hp/lives addresses
	
	
	-- enable Infinite* Lives for p1 if checked
	if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
		mainmemory.read_u8(0x000026) > 0 and mainmemory.read_u8(0x000026) < 255 -- is p1 on?
		then 
		mainmemory.write_u8(0x000026, 69) -- if so, set lives to 69. Nice.
	end
	
	
	-- enable Infinite* Lives for p2 if checked
	if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
		mainmemory.read_u8(0x000028) > 0 and mainmemory.read_u8(0x000028) < 255 -- is p2 on?
		then 
		mainmemory.write_u8(0x000028, 69) -- if so, set lives to 69. Nice.
	end
	
	end
	
	
	if tag == "BTDD_SNES_patched" then 
	
		if memory.read_u8(0x00001A) == 85 -- if game just started
			then gui.drawText(0, 0, "Pick " .. btdd_level_names[which_level] .. "!")
		end
		
	end

	if tag == "BTDD_SNES" then 
	
		if memory.read_u8(0x00001A) == 85 -- if game just started
			then 
			gui.drawText(0, 0, "Up Down Down Up X B Y A on char select (flash = ON)")
			gui.drawText(0, 20, "Pick " .. btdd_level_names[which_level] .. "!")
		end
		
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
	
	
	--Battletoads in Battlemaniacs (SNES)
	
	if tag == "BT_SNES" then 
	
	-- enable Infinite* Lives for P1 (Pimple) if checked
		if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
			mainmemory.read_u8(0x000028) > 0 and mainmemory.read_u8(0x000028) < 255 -- have we started playing?
			then 
			mainmemory.write_u8(0x000028, 69) -- if so, set lives to 69. Nice.
		end
			
	-- enable Infinite* Lives for P2 (Rash) if checked
		if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
			mainmemory.read_u8(0x00002A) > 0 and mainmemory.read_u8(0x00002A) < 255 -- have we started playing?
			then 
			mainmemory.write_u8(0x00002A, 69) -- if so, set lives to 69. Nice.
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
		if tonumber(which_level_filename) == nil or which_level ~= tonumber(which_level_filename) then 
		if settings.SuppressLog ~= true then
			log_message(string.format('OOPS. Double-check that your file names start with a two-digit number from 01 to 13. Starting you on Level 1. File name is ' .. tostring(config.current_game))) end
		else
			log_message('Level ' .. tostring(which_level) .. ': ' ..  bt_nes_level_names[which_level] .. ' (' .. tag .. ')')
		end
	elseif tag == "BTDD_NES" or tag == "BTDD_SNES" or tag == "BTDD_SNES_patched" then 
		if tonumber(which_level_filename) == nil or which_level ~= tonumber(which_level_filename) then 
		if settings.SuppressLog ~= true then
			log_message(string.format('OOPS. Double-check that your file names start with a two-digit number from 01 to 14. Starting you on Level 1. File name is ' .. tostring(config.current_game))) end
		else
			log_message('Level ' .. btdd_level_names[which_level] .. ' (' .. tag .. ')')
		end
	elseif tag == "BT_SNES" then 
		if tonumber(bt_snes_level_recoder[tonumber(which_level_filename)]) == nil 
		then 
		if settings.SuppressLog ~= true then
			log_message(string.format('OOPS. Double-check that your file names start with a two-digit number from 01 to 08. Starting you on Level 1. File name is ' .. tostring(config.current_game))) end
			else
			log_message('Level ' .. tostring(which_level) .. ': ' ..  bt_snes_level_names[which_level] .. ' (' .. tag .. ')')
		end
	elseif tag == "Novolin" then 
			log_message(string.format('Captain Novolin (SNES)'))
	elseif tag == "Anticipation" then 
			log_message(string.format('Anticipation (NES)'))
	elseif tag == "SMK_SNES" then 
			log_message(string.format('Super Mario Kart (SNES)'))
	elseif tag == nil or tag == NO_MATCH then
		if settings.SuppressLog ~= true then
			log_message(string.format('unrecognized? %s (%s)',
			gameinfo.getromname(), gameinfo.getromhash())) end
	end
	
end

function plugin.on_frame(data, settings)
	-- run the check method for each individual game
	if swap_scheduled then return end
	
	local tag = get_game_tag()
	
	
	--Battletoads NES
	if tag == "BT_NES" then 
	
	
	-- This enables the Game Genie code for always moving at max speed in Clinger Winger. 
	-- The bugfix makes this not work! This will only work on an unpatched ROM.
		if settings.ClingerSpeed == true and memory.read_u8(0x000D) == 11 and memory.read_u8(0xA706) == 5 then
			memory.write_u8(0xA706, 0) 
			end
	
	end
	
	
	if tag == "BT_NES" or tag == "BT_NES_patched" then 
		

	-- Set the memory value that represents the starting stage to the number specified by the file name.
		if which_level ~= nil and memory.read_u8(0x8320) <= which_level then --double check that less than/equal to gets desired effect
			memory.write_u8(0x8320, which_level)
			end
		
	end
	
	--Battletoads Double Dragon NES
	
	if tag == "BTDD_NES" then 
	
		if which_level ~= nil -- just started the game!
			then
			if memory.read_u8(0x0017) == 0 then gui.drawText(0, 0, "Level select enabled, select " .. btdd_level_names[which_level] .. "!") end -- give the level instruction
			memory.write_u8(0x0017, 10) -- then set Level Cheat Code to ON
			
			
		end
		
	end
	
	
	
	
	
	
	--Battletoads in Battlemaniacs (SNES)
	
	--Setting the level variable only works on a continue. Stupid but true! You'll just enter a glitched first level otherwise.
	--So, time for Pimple to die ASAP if you chose a level other than the first one.
	
	if tag == "BT_SNES" then 
	--if current level < which_level, then 
		--set lives to 0
		--set health to (if >1, 1, else don't touch)
		--once a continue is used, set level to which_level
		
	local BT_SNES_level_for_memory = bt_snes_level_recoder[which_level]
	
	
		if (which_level ~= nil and which_level > 1) or settings.BTSNESRash == true then -- if level specified and not the first level, or we want to play as Rash
			if memory.read_u8(0x00002C) == 0 then -- we are on the first level
				if memory.read_u8(0x000E5E) > 16 then gui.drawText(0, 0, "Deathwarp to " .. bt_snes_level_names[which_level] .. "!") end -- write message only when Pimple hasn't yet game-overed, so there is a garbage number for health
				if memory.read_u8(0x00002E) == 1 then -- Pimple just lost a continue
					memory.write_u8(0x00002C, BT_SNES_level_for_memory) -- overwrite level, and you're good to go.
					memory.write_u8(0x00002E, 3) -- bump the continue count above 2 to avoid an extra swap
				elseif memory.read_u8(0x00002E) == 2 then -- otherwise, if we just started the game and did specify a different level in the filename,
					memory.write_u8(0x000028, 0) -- set Pimple's lives to 0
					if memory.read_u8(0x000E5E) > 1 then memory.write_u8(0x000E5E, 1) end -- set Pimple's health to 1
					
				end 
			end
			
			if memory.read_u8(0x00002C) > 0 and memory.read_u8(0x00002C) == BT_SNES_level_for_memory and memory.read_u8(0x00002E) > 2 then memory.write_u8(0x00002E, 2) end -- fix Pimple's continue count once you get into the correct level.
		end
		
	end
	
	

	--Super Mario Kart
	
	if tag == "SMK_SNES" then 
	
	-- enable Infinite* continues for both players if checked
		if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
			mainmemory.read_u8(0x000154) > 0 and mainmemory.read_u8(0x000154) < 4 -- have we started playing?
			then 
			mainmemory.write_u8(0x000154, 4) -- if so, set p1 continues to 4.
		end
		
		if settings.InfiniteLives == true and -- is Infinite* Lives enabled?
			mainmemory.read_u8(0x000156) > 0 and mainmemory.read_u8(0x000156) < 4 -- have we started playing?
			then 
			mainmemory.write_u8(0x000156, 4) -- if so, set p2 continues to 4.
		end
		
	end
	
	
	local schedule_swap, delay = shouldSwap(prevdata)
	if schedule_swap and frames_since_restart > 10 then
		swap_game_delay(delay or 3)
		swap_scheduled = true
	end
	
	
end

return plugin
