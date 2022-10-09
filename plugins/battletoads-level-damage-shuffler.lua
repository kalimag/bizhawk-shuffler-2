local plugin = {}

plugin.name = "Battletoads+ Chaos Damage Shuffler"
plugin.author = "Phiggle"
plugin.minversion = "2.6.2"
plugin.settings =
{
	{ name='InfiniteLives', type='boolean', label='Infinite* Lives (see notes)' },
	{ name='ClingerSpeed', type='boolean', label='BT NES: Auto-Clinger-Winger (unpatched ONLY)' },
	{ name='BTSNESRash', type='boolean', label='BT SNES: I want Rash, pick 2P, give Pimple 1 HP'},
	{ name='SuppressLog', type='boolean', label='Suppress "ROM unrecognized"/"on Level 1" logs'},
	{ name='grace', type='number', label='Grace period between swaps (minimum 10 frames)', default=10 },
}



plugin.description =
[[
	Get swapped to a different level whenever a Battletoad takes damage. Additional games shuffle on 'damage', see below. Multiplayer shuffling supported. If your ROM is not recognized, no damage swap will occur.
	
	See instructions to have multiple Battletoads games that start (or continue) at the level you specify.
	
	This is a mod of the excellent Mega Man Damage Shuffler plugin by authorblues and kalimag. 
	Additional ideas from the TownEater fork have been implemented.
	Thank you to Diabetus for extensive playthroughs that tracked down bugs!
	
	You can run the Mega Man Damage Shuffler plugin at the same time, with no conflicts.
	
	More games planned!
	
	Currently supports (ALL NTSC-U):
	-Battletoads (NES), 1p or 2p - also works with the bugfix patch by Ti: https://www.romhacking.net/hacks/2528/
	-Battletoads in Battlemaniacs (SNES), 1p or 2p
	-Battletoads-Double Dragon (NES), 1p or 2p
	-Battletoads-Double Dragon (SNES), 1p or 2p, including if patched to use level select by default (see instructions)
	
	-Anticipation (NES), up to 4 players, shuffles on incorrect player answers, correct CPU answers, and running out of time.
	-Captain Novolin (SNES)
	-Chip and Dale Rescue Rangers 1 (NES), 1p or 2p
	-Super Dodge Ball (NES), 1p or 2p, all modes
	-Super Mario Kart (SNES), 1p or 2p - shuffles on bumps, falls, and being shrunk
	
	
	CURRENTLY IN TESTING
	All of these should work with various revisions INCLUDING RANDOMIZERS if you replace the hash in the .lua file where instructed.
	This will likely be broken out into its own plugin in the near future!
	
	-The Legend of Zelda: A Link to the Past (SNES) - 1p, US or JP 1.0
	-Super Metroid (SNES) - 1p, US/JP version
	-Super Metroid x LTTP Crossover Randomizer, aka SMZ3 (SNES)
	
	ALSO CURRENTLY IN TESTING
	-Mario Bros. (NES), 1-2p
	-Super Mario Bros. (NES), 1-2p
	-Super Mario Bros. 2 JP ("Lost Levels"), NES version, 1p
	-Super Mario Bros. 2 USA (NES), 1p
	-Super Mario Bros. 3 (NES), 1-2p (includes battle mode)
	-Somari (NES, unlicensed), 1p
	-Super Mario World (SNES), 1-2p
	-Super Mario All-Stars SNES), 1-2p, (includes SMB3 battle mode)
	-Super Mario Land (GB or GBC DX patch), 1p
		
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
	-- Lives and level select are not yet running for Chip and Dale 1 (NES).
	
	Auto-Clinger-Winger NES: You can enable max speed and auto-clear the maze (level 11).
	-- You MUST use an unpatched ROM. The second player will not be able to move, so only Rash can get to the boss in 2p. Infinite Lives are disabled in this scenario.
	-- You still have to beat the boss. If you use Infinite* Lives, this could make Clinger-Winger fairly trivial.
	
	Rash 1-player mode in Battlemaniacs (SNES): see above! Start in 2p, let Pimple die to deathwarp, and make sure your 2p controller is mapped the same as 1p aside from Start.
	
	Suppress Logs: if you do not want the lua console log to tell you about file naming errors, or unrecognized ROMs. This can help keep the log cleaner if you are also using the Mega Man Damage Shuffler or other plugins!
	
	Grace period: 10 frames is the default minimum frames between swaps. Adjust up as needed. This idea originated in the TownEater fork of the damage shuffler!
	
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
	elseif gameinfo.getromhash() == "39A5FDB7EFD4425A8769FD3073B00DD85F6CD574" then return "CNDRR1" 
	elseif gameinfo.getromhash() == "42F954E9BD3256C011ABA14C7E5B400ABE35FDE3" then return "SuperDodgeBall" 
	elseif gameinfo.getromhash() == "47E103D8398CF5B7CBB42B95DF3A3C270691163B" then return "SMK_SNES" 
	elseif gameinfo.getromhash() == "DA957F0D63D14CB441D215462904C4FA8519C613" then return "SuperMetroid" -- US/JP 1.0
	elseif gameinfo.getromhash() == "E7E852F0159CE612E3911164878A9B08B3CB9060" then return "LTTP" -- JP 1.0
	elseif gameinfo.getromhash() == "6D4F10A8B10E10DBE624CB23CF03B88BB8252973" then return "LTTP" -- US release
	--elseif gameinfo.getromhash() == "PASTE YOUR HASH HERE AND REMOVE THE -- AT THE FRONT OF THIS LINE" then return "LTTP" -- YOUR SEED/REVISION FOR LTTP
	--elseif gameinfo.getromhash() == "PASTE YOUR HASH HERE AND REMOVE THE -- AT THE FRONT OF THIS LINE" then return "SuperMetroid" -- YOUR SEED/REVISION FOR SUPER METROID
	--elseif gameinfo.getromhash() == "PASTE YOUR HASH HERE AND REMOVE THE -- AT THE FRONT OF THIS LINE" then return "SMZ3" -- YOUR SMZ3 ROM
	--MAKE MULTIPLE LINES WITH EACH HASH IF YOU ARE SHUFFLING MULTIPLE ROMS OF THESE RANDOMIZERS
	end
	
	--MARIO BLOCK
	if gameinfo.getromhash() == "EA343F4E445A9050D4B4FBAC2C77D0693B1D0922" then return "SMB1_NES"
	elseif gameinfo.getromhash() == "C91796D3167ED19CB817CAAA2174A299A510E37F" then return "SMB2J_NES"
	elseif gameinfo.getromhash() == "7DF0F595B074F587C6A1D8F47E031F045D540DAE" then return "SMB2_NES"
	elseif gameinfo.getromhash() == "9286A2DB471D51713E9B75E68B47FFBF11E2D40B" then return "MB_NES"
	elseif gameinfo.getromhash() == "6CF18228CFB66D48B3642069979D4A5103CB8528" then return "SOMARI"
	elseif gameinfo.getromhash() == "A03E7E526E79DF222E048AE22214BCA2BC49C449" then return "SMB3_NES"
	elseif gameinfo.getromhash() == "C05817C5B7DF2FBFE631563E0B37237156A8F6B6" then return "SMAS_SNES"
	elseif gameinfo.getromhash() == "6B47BB75D16514B6A476AA0C73A683A2A4C18765" then return "SMW_SNES"
	elseif gameinfo.getromhash() == "3A4DDB39B234A67FFB361EE7ABC3D23E0A8B1C89" then return "SML1_GB"
	elseif gameinfo.getromhash() == "418203621B887CAA090215D97E3F509B79AFFD3E" then return "SML1_GB"
	elseif gameinfo.getromhash() == "7D95107C45D4F33649324DA2E8A3C8DDB10CDA5E" then return "SML1_GB"
	
	elseif gameinfo.getromhash() == "B9ED5789C9F481E25A64DAD1C5E8E93E4DDC1B80" then return "SML2DX_GBC"
	
	elseif gameinfo.getromhash() == "D8DFACBFEC34CDC871D73C901811551FE1706923" then return "DK1_NES"
	elseif gameinfo.getromhash() == "02633E208732B598E3A8EB80B6E0E09926F25E83" then return "DKJR_NES"
	elseif gameinfo.getromhash() == "EC6FA944C672A2522C8BC270A25842281C65FF5D" then return "DK3_NES"
	elseif gameinfo.getromhash() == "A3B727119870E6BBA4C8889EF12E9703021EA9C2" then return "NOTGOLF_NES"
	elseif gameinfo.getromhash() == "C807F2856F44FB84326FAC5B462340DCDD0471F8" then return "SMW2YI_SNES"
	elseif gameinfo.getromhash() == "34612A93741F156D6E497462AB7F253CB8A959A0" then return "SMW2YI_SNES"
	elseif gameinfo.getromhash() == "D027C03EB2FAEFA07640EC828B2A46F601F7B15F" then return "MPAINT_SNES"
	elseif gameinfo.getromhash() == "A22713711B5CD58DFBAFC9688DADEA66C59888CE" then return "NSMB_DS"
	elseif gameinfo.getromhash() == "9BEF1128717F958171A4AFAC3ED78EE2BB4E86CE" then return "SM64_N64"
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


local function sml1_swap(gamemeta)
	return function()
		local size_changed, shrinking, prev_shrinking = update_prev('shrinking', gamemeta.getsmlsize()) -- when this variable is 3, Mario is shrinking
		local lives_changed, lives, prev_lives = update_prev('lives', gamemeta.getlives()) -- usual lives counter idea
		local game_over_changed, game_over_bar, prev_game_over_bar = update_prev('game_over_bar', gamemeta.getgameover() ~= 57) -- this variable goes to 57 to show the GAME OVER bar		
		return
			(size_changed and shrinking == 3) or
			(lives_changed and lives < prev_lives) or
			(game_over_changed and game_over_bar)
		end
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

local function singleplayer_withlives_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end


		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local currtogglecheck = 0 
		if gamemeta.gettogglecheck ~= nil then currtogglecheck = gamemeta.gettogglecheck() end
		
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
		local prevtogglecheck = data.prevtogglecheck

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.prevtogglecheck = currtogglecheck
		
		--if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then return false end
		

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

local function SMZ3_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end


		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local currwhichgame = gamemeta.getwhichgame()

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
		local prevwhichgame = data.prevwhichgame
		
		--DO NOT SWAP ON GAME CHANGE
		if prevwhichgame ~= nil and prevwhichgame ~= currwhichgame then return false end

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.prevwhichgame = currwhichgame
		

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


local function twoplayers_withlives_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end


		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local p2currhp = gamemeta.p2gethp()
		local p2currlc = gamemeta.p2getlc()
		
		-- we should now be able to use the typical shuffler functions normally.

		local maxhp = gamemeta.maxhp()
		local minhp = 0

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
		end
		
		if p2prevhp ~= nil and p2currhp < p2prevhp then
			data.p2hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		if p1prevlc ~= nil and p1currlc < p1prevlc then
			return true
		end
		
		if p2prevlc ~= nil and p2currlc < p2prevlc then
			return true
		end

		return false
	end
end

local function SMAS_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end


		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local p2currhp = gamemeta.p2gethp()
		local p2currlc = gamemeta.p2getlc()
		local currsmb2mode = gamemeta.getsmb2mode()
		
		-- we should now be able to use the typical shuffler functions normally.

		local maxhp = gamemeta.maxhp()
		local minhp = 0

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
		local prevsmb2mode = data.prevsmb2mode
		
		

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc
		data.prevsmb2mode = currsmb2mode
		
		--DON'T SWAP WHEN WE JUST CAME OUT OF SMB2 SLOTS OR MENU
		if currsmb2mode ~= prevsmb2mode then 
			return false 
		end

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
		end
		
		if p2prevhp ~= nil and p2currhp < p2prevhp then
			data.p2hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		if p1prevlc ~= nil and p1currlc < p1prevlc then
			return true
		end
		
		if p2prevlc ~= nil and p2currlc < p2prevlc then
			return true
		end

		return false
	end
end

local function sdbnes_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end
	
				
		local currhowmanyplayers = gamemeta.gethowmanyplayers()
		local currmode = gamemeta.getmode()
		local p1currhp1 = gamemeta.p1gethp1()
		local p1currhp2 = gamemeta.p1gethp2()
		local p1currhp3 = gamemeta.p1gethp3()
		local p2currhp1 = gamemeta.p2gethp1()
		local p2currhp2 = gamemeta.p2gethp2()
		local p2currhp3 = gamemeta.p2gethp3()
		local p1currbbplayer = gamemeta.p1getbbplayer()
		local p2currbbplayer = gamemeta.p2getbbplayer()
		

		local maxhp = gamemeta.maxhp()
		local minhp = 0
		
		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		
		-- NOTE: IN SDB, ONLY p1currhp1 and p1currbbplayer seem to inherit garbage values
		
		if p1currhp1 < minhp or (p1currhp1 > maxhp and currmode < 2) then
			return false
		elseif p1currbbplayer > 33 and currmode == 2 then -- highest value for this is 33
			return false
		end
		
		local p1currhp = p1currhp1 + p1currhp2 + p1currhp3 -- team 1
		local p2currhp = p2currhp1 + p2currhp2 + p2currhp3 -- team 2
		
		--consider transforming the player to 1-6 to make this easy to look up.
		
		local beanballplayerhps = {
		mainmemory.read_u8(0x0323),
		mainmemory.read_u8(0x0393),
		mainmemory.read_u8(0x0403),
		mainmemory.read_u8(0x035B),
		mainmemory.read_u8(0x03CB),
		mainmemory.read_u8(0x043B),
		}
		
		--0 for 1, 16 for 2, 32 for 3, 1 for 4, 17 for 5, 33 for 6
		local p1currhpbb= beanballplayerhps[p1currbbplayer]
		local p2currhpbb= beanballplayerhps[p2currbbplayer]
		--sub in the bb healths if we are in bb
		
		if currmode == 2 then 
			p1currhp = p1currhpbb
			if currhowmanyplayers == 2 then p2currhp = p2currhpbb else p2currhp = 0 end
		end
		
		
		
		-- retrieve previous health and mode/player info from before backup
		
		local prevhowmanyplayers = data.prevhowmanyplayers
		local prevmode = data.prevmode
		local p1prevhp = data.p1prevhp
		local p2prevhp = data.p2prevhp
		local p1prevbbplayer = data.p1prevbbplayer
		local p2prevbbplayer = data.p2prevbbplayer

		data.prevhowmanyplayers = currhowmanyplayers
		data.prevmode = currmode
		data.p1prevhp = p1currhp
		data.p2prevhp = p2currhp
		data.p1prevbbplayer = p1currbbplayer
		data.p2prevbbplayer = p2currbbplayer

		



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
			if data.p2hpcountdown == 0 and p2currhp > minhp and currhowmanyplayers == 2 
			then
				return true
			end
		end		

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end
		
		if p2prevhp ~= nil and p2currhp ~= nil and p2currhp < p2prevhp and currhowmanyplayers == 2 
		then
			data.p2hpcountdown = gamemeta.delay or 3
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
		local p1currlava = gamemeta.p1getlava()
		local p2currlava = gamemeta.p2getlava()
	

		-- retrieve previous health and lives before backup
		local p1prevcoins = data.p1prevcoins
		local p2prevcoins = data.p2prevcoins
		local p1prevbump = data.p1prevbump
		local p2prevbump = data.p2prevbump
		local p1prevfall = data.p1prevfall
		local p2prevfall = data.p2prevfall
		local p1prevshrink = data.p1prevshrink
		local p2prevshrink = data.p2prevshrink
		local p1prevlava = data.p1prevlava
		local p2prevlava = data.p2prevlava

		data.p1prevcoins = p1currcoins
		data.p2prevcoins = p2currcoins
		data.p1prevbump = p1currbump
		data.p2prevbump = p2currbump
		data.p1prevfall = p1currfall
		data.p2prevfall = p2currfall
		data.p1prevshrink = p1currshrink
		data.p2prevshrink = p2currshrink
		data.p1prevlava = p1currlava
		data.p2prevlava = p2currlava

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
		-- This number only goes over 5 with a pitfall/Lakitu. You will reset to 0 when you can drive again.
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
		
		--- in lava
		
		if p1prevlava ~= nil and p1prevlava == 0 and p1currlava == 16 then
			return true end
		
		---p2 has to be active
		if(mainmemory.read_u8(0x0011D2)) == 2 and
		p2prevlava ~= nil and p2prevlava == 0 and p2currlava == 16 then
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
	['CNDRR1']={ -- Chip and Dale 1 (NES)
		func=twoplayers_withlives_swap,
				
		--three addresses for hearts - if the heart is there, these == 24 (18 hex) , otherwise they == 248 (F8 hex).
		p1gethp=function() 
		if mainmemory.read_u8(0x0210) == 24 then return 3
		elseif mainmemory.read_u8(0x020C) == 24 then return 2
		elseif mainmemory.read_u8(0x0208) == 24 then return 1 
		else return 0 end
		end,
		p2gethp=function() 
		if mainmemory.read_u8(0x0224) == 24 then return 3
		elseif mainmemory.read_u8(0x0220) == 24 then return 2
		elseif mainmemory.read_u8(0x021C) == 24 then return 1 
		else return 0 end
		end, 
		p1getlc=function() return mainmemory.read_u8(0x05B6) end,
		p2getlc=function() return mainmemory.read_u8(0x05E6) end,
		maxhp=function() return 3 end,
	},	
	['SuperDodgeBall']={ -- Super Dodge Ball (NES)
		func=sdbnes_swap,
		gethowmanyplayers=function() return mainmemory.read_u8(0x006F) end, -- # humans, 1 or 2, use this to tell whether to swap if 2p team takes damage
		getmode=function() return mainmemory.read_u8(0x06B1) end, -- mode: 0 for 1p, 1 for 2p vs, 2 for bean ball
		p1gethp1=function() return mainmemory.read_u8(0x058B) end, 
		p1gethp2=function() return mainmemory.read_u8(0x0553) end,
		p1gethp3=function() return mainmemory.read_u8(0x051B) end,
		p2gethp1=function() return mainmemory.read_u8(0x043B) end,
		p2gethp2=function() return mainmemory.read_u8(0x0403) end,
		p2gethp3=function() return mainmemory.read_u8(0x03CB) end,
		p1getbbplayer=function() return (1 + math.floor(mainmemory.read_u8(0x0587)/16) + 3*(mainmemory.read_u8(0x0587) % 16)) end, -- transforming from 0, 16, 32, 1, 17, 33 format
		p2getbbplayer=function() return (1 + math.floor(mainmemory.read_u8(0x0588)/16) + 3*(mainmemory.read_u8(0x0588) % 16)) end, -- transforming from 0, 16, 32, 1, 17, 33 format
		gmode=function() return (mainmemory.read_u8(0x0070)%2) == 0 end, -- several potential values, but if it's ever odd, we're not in-game.
		maxhp=function() return 60 end,
	},	
	['Novolin']={ -- Captain Novolin SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return bit.band(mainmemory.read_u8(0x0BDA), 0x7F) end,
		p1getlc=function() return mainmemory.read_u8(0x06C3) end,
		maxhp=function() return 4 end,
	},	
	['LTTP']={ -- LTTP SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return mainmemory.read_u8(0xF36D) end, -- single byte!
		maxhp=function() return 160 end, -- 8 hp per heart, 20 heart containers
		p1getlc=function() 
			if mainmemory.read_u8(0x0010) == 18 -- this value is the "Link is in a death spiral" value - so it tells us Link hit 0 for real, not due to resets etc.
			then return 1 else return 2
			end
		end,
		gmode=function() return mainmemory.read_u8(0x0010) ~= 23 and mainmemory.read_u8(0x0010) ~= 0 end, -- 0 means we're on the title/menu, and 23 means we are saving and quitting, so don't swap on those!
	},	
	['SuperMetroid']={ -- Super Metroid SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u16_le(0x09C2) end,
		maxhp=function() return 1399 end,
		p1getlc=function() 
			if mainmemory.read_u8(0x0998) == 25 -- this value is the "game state" where the game is fading out after Samus dies. Tells us Samus hit 0 for real, not due to resets etc.
			then return 1 else return 2
			end
		end,
		gmode=function() return mainmemory.read_u8(0x0998) >= 7 and mainmemory.read_u8(0x0998) <=25 end, -- anything outside those ranges is not normal gameplay, so don't swap on health changes
	},	
	['SMZ3']={ -- TESTING SMZ3
		func=SMZ3_swap,
		p1gethp=function()
			if memory.read_u8(0x33FE, "CARTRAM") == 255 then return memory.read_u16_le(0x09C2) -- Samus health
			elseif memory.read_u8(0x33FE, "CARTRAM") == 0 then return memory.read_u8(0xF36D) -- Link health
			else return nil end
			end, 
		maxhp=function() 
			if memory.read_u8(0x33FE, "CARTRAM") == 255 then return 1399 -- Samus max health
			elseif memory.read_u8(0x33FE, "CARTRAM") == 0 then return 160 -- Link max health
			else return nil end
			end,
		p1getlc=function() 
			if memory.read_u8(0x33FE, "CARTRAM") == 255 -- Super Metroid
				and mainmemory.read_u8(0x0998) == 25 -- this value is the "game state" where the game is fading out after Samus dies. Tells us Samus hit 0 for real, not due to resets etc.
				then return 1 
			elseif memory.read_u8(0x33FE, "CARTRAM") == 0 -- LTTP
				and mainmemory.read_u8(0x0010) == 18 -- this value is the "Link is in a death spiral" value - so it tells us Link hit 0 for real, not due to resets etc.
				then return 1 
			else return 2 end
			end,
		getwhichgame=function() return memory.read_u8(0x33FE, "CARTRAM") end,
		gmode=function() return 
		(memory.read_u8(0x33FE, "CARTRAM") == 255 and mainmemory.read_u8(0x0998) >= 7 and mainmemory.read_u8(0x0998) <=25) or -- actively in SM
		(memory.read_u8(0x33FE, "CARTRAM") == 0 and mainmemory.read_u8(0x0010) ~= 23 and mainmemory.read_u8(0x0010) ~= 0) -- actively in LTTP
		end, -- anything outside those ranges is not normal gameplay, so don't swap on health changes
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
		p1getlava=function() return mainmemory.read_u8(0x00010A) end, -- if == 16 then congrats, you're in lava 
		p2getlava=function() return mainmemory.read_u8(0x00010C) end, -- if == 16 then congrats, you're in lava 
		--eventual conversion to use update_prev instead? 
	},	
	--MARIO BLOCK
	['SMB1_NES']={ -- SMB 1 NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0756) + 1 end, -- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
		p1getlc=function() return 
		memory.read_u8(0x075A) % 255 --mario if 1p, luigi if 2p, 255 = they game overed
		+ memory.read_u8(0x0761) % 255 --mario if 2p, 255 = they game overed, stays at 2 if in 1p
		end,
		maxhp=function() return 2 end,
		gmode=function() return 
		(memory.read_u8(0x07F8)*100 + memory.read_u8(0x07F9)*10 + memory.read_u8(0x07F9)) ~= 401 end, -- we're in the demo if timer equals 401 seconds
	},	
	['SMB2J_NES']={ -- SMB 2 JP, NES version (Lost Levels)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0756) + 1 end, -- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
		p1getlc=function() return 
		memory.read_u8(0x075A) % 255 --mario if 1p, luigi if 2p, 255 = they game overed
		+ memory.read_u8(0x0761) % 255 --mario if 2p, 255 = they game overed, stays at 2 if in 1p
		end,
		maxhp=function() return 2 end,
		gmode=function() return 
		(memory.read_u8(0x07F8)*100 + memory.read_u8(0x07F9)*10 + memory.read_u8(0x07F9)) ~= 401 end, -- we're in the demo if timer equals 401 seconds
	},	
	['SMB2_NES']={ -- SMB2 USA NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x04C2) end,
		p1getlc=function() return memory.read_u8(0x04ED) end,
		maxhp=function() return 63 end,
		gettogglecheck=function() return memory.read_u8(0x04C3) end, -- this is the number of health bars - if it changes, as in goes back down to normal on slots
	},	
	['MB_NES']={ -- Mario Bros. US NES
		func=twoplayers_withlives_swap,
		-- this game only uses lives
		p1gethp=function() return 0 end, 
		p1getlc=function() return memory.read_u8(0x0048) end,
		p2gethp=function() return 0 end,
		p2getlc=function() return memory.read_u8(0x004C) end,
		maxhp=function() return 0 end,
	},	
	['SOMARI']={ -- Somari (unlicensed) NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 
		memory.read_u8(0x0336)*100 + -- hundreds digit
		memory.read_u8(0x0337)*10 + -- tens digit
		memory.read_u8(0x0338) + 1 end, -- ones digit
		p1getlc=function() return memory.read_u8(0x033C) end,
		maxhp=function() return 1000 end,
	},	
	['SMB3_NES']={ -- SMB3 NES
		func=twoplayers_withlives_swap,
		p1gethp = function() 
			if memory.read_u8(0x00ED) <= 7 
			and memory.read_u8(0x00ED) > 1 -- suits etc. range from 2 to 7 only
				then return 3
			else 
				return memory.read_u8(0x00ED) + 1 -- 1 is Big Mario/Luigi, 0 is small, 8+ is junk data, adding 1 to help with swap on small not relying on life lost
			end
		end,
		p2gethp = function() 
			if memory.read_u8(0x00ED) <= 7 
			or memory.read_u8(0x00ED) > 1 -- suits etc. range from 2 to 7 only
				then return 3
			else 
				return memory.read_u8(0x00ED) + 1 -- 1 is Big Mario/Luigi, 0 is small, 8+ is junk data, adding 1 to help with swap on small not relying on life lost
			end
		end,
		p1getlc=function() 
			if memory.read_u8(0x001D) == 18 -- we are in 2p battle mode when this == 18. Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
			then return memory.read_u8(0x0736) + 1 -- max 63?
			else return memory.read_u8(0x0736) 
			end
		end,
		p2getlc=function() 
			if memory.read_u8(0x001D) == 18 -- we are in 2p battle mode when this == 18. Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
			then return memory.read_u8(0x0737) + 1 -- max 63?
			else return memory.read_u8(0x0737) 
			end
		end,
		maxhp=function() return 3 end,
	},	
	['SMW_SNES']={ -- Super Mario World SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() 
			if memory.read_u8(0x000019) == 2 or memory.read_u8(0x000019) == 3 then return 3 -- fire (3) or cape (2), don't shuffle if you just change powerups
			else return memory.read_u8(0x000019) + 1 -- 1 for big, 0 for small, adding 1 to help with swap on small not relying on life lost
			end 
		end,
		p1getlc=function() return memory.read_u8(0x000DBE) end, --active player's lives
		maxhp=function() return 3 end,
		gmode=function() return 
		memory.read_u8(0x000100) == 11 --game mode value for fading to overworld, this is when the lives counter changes on death
		--the mario/luigi lives count swaps ON the overworld (12-14) so don't count that!
		or (memory.read_u8(0x000100) > 15 and memory.read_u8(0x000100) <= 23) -- in a level, for HP checks
		end, 
	},	
	['SMAS_SNES']={ -- Super Mario All Stars (SNES)
	--to do, function to define "which game"
		func=SMAS_swap,
		gmode=function() return
		memory.read_u8(0x01FF00) == 2 --SMB1
		or memory.read_u8(0x01FF00) == 4 --SMB2j
		or (memory.read_u8(0x01FF00) == 6 and memory.read_u8(0x000547) < 128) --SMB2 USA, 128 = slots, 255 = menu
		or memory.read_u8(0x01FF00) == 8 -- SMB3 (including battle)
		end,
		getsmb2mode=function() return memory.read_u8(0x000547) end,
		p1gethp=function()
			if memory.read_u8(0x01FF00) == 8 --SMB3
				then 
					if memory.read_u8(0x00072B) == 3 -- we are in battle mode
						then return memory.read_u8(0x019AB) + 1 --battle health, 0 = small so add 1
					elseif memory.read_u8(0x000747) <= 7 
						and memory.read_u8(0x000747) > 1 -- normal mode, suits etc. range from 2 to 7 only
						then return 3
					else 
						return memory.read_u8(0x000747) + 1 -- 1 is Big Mario/Luigi, 0 is small, 8+ is junk data, adding 1 to help with swap on small not relying on life lost
					end
			elseif memory.read_u8(0x01FF00) == 6 --SMB2 USA 
				then return math.ceil(memory.read_u8(0x0004C3)/16)
			elseif memory.read_u8(0x01FF00) == 2 or memory.read_u8(0x01FF00) == 4 -- SMB1 or SMB2j 
				then return memory.read_u8(0x000756) + 1 -- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
			else return 0 end
		end, 
		p2gethp=function()
			if memory.read_u8(0x01FF00) == 8 --SMB3
				then 
					if memory.read_u8(0x00072B) == 3 -- we are in battle mode
						then return memory.read_u8(0x019AC) + 1 --battle health, 0 = small so add 1
					elseif memory.read_u8(0x000748) <= 7 
					and memory.read_u8(0x000748) > 1 -- suits etc. range from 2 to 7 only
					then return 3
				else 
					return memory.read_u8(0x000748) + 1 -- 1 is Big Mario/Luigi, 0 is small, 8+ is junk data, adding 1 to help with swap on small not relying on life lost
					end
			elseif memory.read_u8(0x01FF00) == 6 --SMB2 USA 
				then return 0
			elseif memory.read_u8(0x01FF00) == 2 or memory.read_u8(0x01FF00) == 4 -- SMB1 or SMB2j 
				then return memory.read_u8(0x000756) + 1 -- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
			else return 0 end
		end, 
		maxhp=function() 
			if memory.read_u8(0x01FF00) == 8 --SMB3 
				then return 3
			elseif memory.read_u8(0x01FF00) == 6 --SMB2 USA 
				then return 63
			elseif memory.read_u8(0x01FF00) == 2 or memory.read_u8(0x01FF00) == 4 -- SMB1 or SMB2j 
				then return 2  -- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
			else return 0 end
		end,
		p1getlc=function()
			if memory.read_u8(0x01FF00) == 8 --SMB3 
				then 
					if memory.read_u8(0x00072B) == 3 -- we are in battle mode
						then return 5 - memory.read_u8(0x0002DB) --luigi's victory count
					elseif memory.read_u8(0x00001D) == 18 then return memory.read_u8(0x000736) + 1 --we are in 2p battle mode when this == 18. Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
					else return memory.read_u8(0x000736) 
					end
			elseif memory.read_u8(0x01FF00) == 6 --SMB2 USA 
				then return memory.read_u8(0x0004EE)
			elseif memory.read_u8(0x01FF00) == 2 or memory.read_u8(0x01FF00) == 4 -- SMB1 or SMB2j 
				then return 
				memory.read_u8(0x00075A) % 255 --mario if 1p, luigi if 2p, 255 = they game overed
				+ memory.read_u8(0x000761) % 255 --mario if 2p, 255 = they game overed, stays at 2 if in 1p
			else return 0 end
		end, 
		p2getlc=function()
			if memory.read_u8(0x01FF00) == 8 --SMB3 
				then 
					if memory.read_u8(0x00072B) == 3 -- we are in battle mode
						then return 5 - memory.read_u8(0x0002DA) --mario's victory count
					elseif memory.read_u8(0x00001D) == 18 then return memory.read_u8(0x000736) + 1 --we are in 2p battle mode when this == 18. Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
					else return memory.read_u8(0x000737)
					end
			elseif memory.read_u8(0x01FF00) == 6 --SMB2 USA 
				then return 0
			elseif memory.read_u8(0x01FF00) == 2 or memory.read_u8(0x01FF00) == 4 -- SMB1 or SMB2j 
				then return 
				memory.read_u8(0x00075A) % 255 --mario if 1p, luigi if 2p, 255 = they game overed
				+ memory.read_u8(0x000761) % 255 --mario if 2p, 255 = they game overed, stays at 2 if in 1p
			else return 0 end
		end, 
	},	
	['SML1_GB']={ -- Super Mario Land, including DX hack for Game Boy Color
		func=sml1_swap,
		getsmlsize=function() return memory.read_u8(0x19, "HRAM") end,
		getlives=function() return memory.read_u8(0x1A15, "WRAM") end,
		getgameover=function() return memory.read_u8(0x00A4, "WRAM") end,
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
	elseif tag == "CNDRR1" then 
			log_message(string.format('Chip and Dale Rescue Rangers 1 (NES)'))
	elseif tag == "SuperDodgeBall" then 
			log_message(string.format('Super Dodge Ball (NES)'))
	elseif tag == "SMK_SNES" then 
			log_message(string.format('Super Mario Kart (SNES)'))
	elseif tag == "SuperMetroid" then 
			log_message(string.format('Super Metroid (SNES)'))
	elseif tag == "LTTP" then 
			log_message(string.format('The Legend of Zelda: A Link to the Past (SNES)'))
	elseif tag == "SMZ3" then 
			log_message(string.format('SMZ3 (SNES)'))
			--THIS IS GETTING UNWIELDY AND A DAT FILE IS IN ORDER
	elseif tag ~= nil then 
			log_message(string.format(tag))
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
	if schedule_swap and frames_since_restart > math.max(settings.grace, 10) then -- avoiding super short swaps (<10) as a precaution
		swap_game_delay(delay or 3)
		swap_scheduled = true
	end
	
end

return plugin