local plugin = {}

plugin.name = "Chaos Damage Shuffler"
plugin.author = "authorblues and kalimag (MMDS), Phiggle, Rogue_Millipede, Shadow Hog"
plugin.minversion = "2.6.3"
plugin.settings =
{
	{ name='InfiniteLives', type='boolean', label='Infinite* Lives (see notes)' },
	{ name='ClingerSpeed', type='boolean', label='BT NES: Auto-Clinger-Winger (unpatched ONLY)' },
	{ name='BTSNESRash', type='boolean', label='BT SNES: I want Rash, pick 2P, give Pimple 1 HP'},
	{ name='SuppressLog', type='boolean', label='Suppress "ROM unrecognized"/"on Level 1" logs'},
	{ name='SMW2YI_MiniBonusSwaps', type='boolean', label="Yoshi's Island: Shuffle on Mini Battle damage/loss", default=true},
	{ name='grace', type='number', label='Grace period between swaps (minimum 10 frames)', default=10 },
}

plugin.description =
[[
	Get swapped to a different level whenever a Battletoad takes damage. Additional games shuffle on 'damage', see below. Multiplayer shuffling supported. If your ROM is not recognized, no damage swap will occur.
	
	See instructions to have multiple Battletoads games that start (or continue) at the level you specify.
	
	This is a mod of the excellent Mega Man Damage Shuffler plugin by authorblues and kalimag.
	Additional ideas from the TownEater fork have been implemented.
	Thank you to Diabetus, Smight and ConstantineDTW for extensive playthroughs that tracked down bugs!
	
	ENABLE EXPANSION SLOT FOR N64 GAMES!
	
	Currently supports (ALL NTSC-U):
	
	BATTLETOADS BLOCK
	-Battletoads (NES), 1p or 2p - also works with the bugfix patch by Ti: https://www.romhacking.net/hacks/2528/
	-Battletoads in Battlemaniacs (SNES), 1p or 2p
	-Battletoads-Double Dragon (NES), 1p or 2p
	-Battletoads-Double Dragon (SNES), 1p or 2p, including if patched to use level select by default (see instructions)
	
	MARIO BLOCK
	-Mario Bros. (NES), 1-2p
	-Super Mario Bros. (NES), 1-2p
	-Super Mario Bros. 2 JP ("Lost Levels"), NES version, 1p
	-Super Mario Bros. 2 USA (NES), 1p
	-Super Mario Bros. 3 (NES), 1-2p (includes battle mode)
	-Somari (NES, unlicensed), 1p
	-Super Mario World (SNES), 1-2p
	-Super Mario World 2: Yoshi's Island (SNES), 1p or 2p (secret mini battles) 
	--- check toggle for whether you want mini battle damage/losses to swap!
	-Super Mario All-Stars (SNES), 1-2p, with or without World (includes SMB3 battle mode)
	-Super Mario Land (GB or GBC DX patch), 1p
	-Super Mario Land 2: 6 Golden Coins (GB or GBC DX patch), 1p
	-Super Mario 64 (N64), 1p
	
	CASTLEVANIA BLOCK
	-Castlevania (NES), 1p
	-Castlevania II (NES), 1p
	-Castlevania III (NES, or Famicom with translation patch), 1p
	-Super Castlevania IV (SNES), 1p
	-Castlevania: Dracula X (SNES), 1p
	-Castlevania: Bloodlines (Genesis/Mega Drive), 1p
	-Castlevania: Rondo of Blood (TG16-CD), 1p
	-Castlevania (N64), 1p (in-progress, grabbing shuffles excessively)
	-Castlevania: Legacy of Darkness (N64), 1p (in-progress, grabbing and poison shuffle excessively)
	-Castlevania: Symphony of the Night (PSX), 1p
	-Castlevania: Aria of Sorrow (GBA), 1p
	-Castlevania: Dawn of Sorrow (DS), 1p
	-Castlevania: Portrait of Ruin (DS), 1p
	-Castlevania: Order of Ecclesia (DS), 1p

	METROID BLOCK
	-Metroid (NES), 1p
	-Metroid II (GB or GBC color patch), 1p
	-Metroid Fusion (GBA), 1p
	-Metroid Zero Mission (GBA), 1p

	ZELDA BLOCK
	-The Legend of Zelda (NES), 1p
	-Zelda II The Adventure of Link (NES), 1p
	-Link's Awakening (GB), 1p
	-Link's Awakening DX (GBC), 1p
	-Ocarina of Time (N64), 1p (ENABLE EXPANSION SLOT FOR N64 GAMES)
	-Oracle of Seasons (GBC), 1p
	-Oracle of Ages (GBC), 1p

	CONTRA BLOCK
	-Contra/Probotector (NES), 1p or 2p
	-Super C/Super Contra/Probotector II (NES), 1p or 2p
	-Contra III: The Alien Wars/Super Probotector: Alien Rebels/Contra Spirits (SNES), 1p or 2p

	KONG BLOCK
	-Donkey Kong Country (SNES), 1p, 2p Contest, or 2p Team
	-Donkey Kong Country 2: Diddy's Kong Quest (SNES), 1p, 2p Contest, or 2p Team
	-Donkey Kong Country 3: Dixie Kong's Double Trouble (SNES), 1p, 2p Contest, or 2p Team
	-DKC x Mario (SNES, DKC1 hack by RainbowSprinklez), 1p

	THE LINK/SAMUS BLOCK
	-The Legend of Zelda: A Link to the Past (SNES) - 1p, US or JP 1.0
	-Super Metroid (SNES) - 1p, US/JP version - does not shuffle on losing health from being "drained" by acid, heat, shinesparking, certain enemies
	-Super Metroid x LTTP Crossover Randomizer, aka SMZ3 (SNES)

	These three should work with various revisions INCLUDING RANDOMIZERS if you replace the hash in the .lua file where instructed.
	Other randomizers (e.g., ZOoTR) haven't been tested yet!!

	ADDITIONAL GOODIES
	-Anticipation (NES), up to 4 players, shuffles on incorrect player answers, correct CPU answers, and running out of time.
	-Banjo-Kazooie (N64), 1p
	-Batman (NES), 1p
	-Blades of Steel (NES - NA/Europe), 1p or 2p
	-Bubsy in Claws Encounters of the Furred Kind (aka Bubsy 1) (SNES)
	-Captain Novolin (SNES)
	-Chip and Dale Rescue Rangers 1 (NES), 1p or 2p
	-Chip and Dale Rescue Rangers 2 (NES), 1p or 2p
	-Darkwing Duck (NES), 1p
	-Demon's Crest (SNES), 1p
	-Double Dragon 1 (NES), 1p or 2p, Mode A or B, shuffles on knockdown and death
	-Double Dragon 2 (NES), 1p or 2p, shuffles on knockdown and death
	-Einhänder (PSX), 1p
	-F-Zero (SNES), 1p
	-Family Feud (SNES), 1p or 2p
	-Ice Climber (NES), 1p or 2p, shuffles on death or bonus game loss
	-Jackal (NES), 1p or 2p
	-Kirby's Adventure (NES), 1p
	-Last Alert (TG-16 CD), 1p
	-Little Samson (NES), 1p
	-Magical Kid's Doropie / Krion Conquest (NES), 1p
	-Mario Paint (SNES), joystick hack, Gnat Attack, 1p
	-Monopoly (NES), 1-8p (on one controller), shuffles on any human player going bankrupt, going or failing to roll out of jail, and losing money (not when buying, trading, or setting up game)
	-NBA JAM Tournament Edition (PSX), 1p - shuffles on points scored by opponent and on end of quarter
	-Pebble Beach Golf Links (Sega Saturn), 1p - Tournament Mode, shuffles after stroke
	-Rock 'n Roll Racing (SNES), 1p
	-Rocket Knight Adventures (Genesis/Mega Drive), 1p
	-Snake Rattle 'n Roll (NES), 1p
	-Star Fox 64 (N64), 1p-4p
	-Super Dodge Ball (NES), 1p or 2p, all modes
	-Super Mario Kart (SNES), 1p or 2p - shuffles on collisions with other karts (lost coins or have 0 coins), falls
	-Super Monkey Ball Jr. (GBA), 1p
	-WarioWare, Inc.: Mega Microgame$! (GBA), 1p - bonus games including 2p are pending
	
	NICHE ZONE
	- NES 240p Suite: shuffles on every second that passes in Stopwatch Mode. Can be useful for keeping Infinite Lives and shuffling alive with one "real" game left, or for testing a single game.
	
	----PREPARATION----
	-Set Min and Max Seconds VERY HIGH, assuming you don't want time swaps in addition to damage swaps.
	-If adding N64 games, enable the Expansion Slot. Some games will fail to shuffle or crash Bizhawk without it.
	
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
	-- Several games do not have 'lives' to make infinite, such as Anticipation, Super Metroid, Link to the Past, Super Dodge Ball, original Mario Bros. Nothing will change in these games with this option.
	
	Auto-Clinger-Winger NES: You can enable max speed and auto-clear the maze (level 11).
	-- You MUST use an unpatched ROM for this option to activate. The second player will not be able to move, so only Rash can get to the boss in 2p. Infinite Lives are disabled for the second player in this scenario.
	-- You still have to beat the boss. If you use Infinite* Lives, this could make Clinger-Winger fairly trivial.
	
	Rash 1-player mode in Battlemaniacs (SNES): see above! Start in 2p, let Pimple die to deathwarp, and make sure your 2p controller is mapped the same as 1p aside from Start.
	
	Suppress Logs: if you do not want the lua console log to tell you about file naming errors, or unrecognized ROMs. This can help keep the log cleaner if you are also using the Mega Man Damage Shuffler or other plugins!
	
	Grace period: 10 frames is the default minimum frames between swaps. Adjust up as needed. This idea originated in the TownEater fork of the damage shuffler!
	
	Enjoy? Send bug reports?
	
]]

local NO_MATCH = 'NONE'

local tags = {}
local tag
local gamemeta
local prevdata
local swap_scheduled
local shouldSwap
local gamesleft


local bt_nes_level_names = { "Ragnarok's Canyon",
	"Wookie Hole",
	"Turbo Tunnel",
	"Arctic Caverns",
	"Surf City",
	"Karnath's Lair",
	"Volkmire's Inferno",
	"Intruder Excluder",
	"Terra Tubes",
	"Rat Race",
	"Clinger-Winger",
	"The Revolution",
	"Armageddon"}

local btdd_level_names = { "1-1", "1-2", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "5-1", "5-2", "6-1", "7-1"}

local bt_snes_level_names = { "Khaos Mountains",
	"Hollow Tree",
	"Bonus Stage 1",
	"Turbo Tunnel Rematch",
	"Karnath's Revenge",
	"Roller Coaster",
	"Bonus Stage 2",
	"Dark Tower"}

local bt_snes_level_recoder = { 0, 1, 2, 3, 4, 6, 8, 7 } -- THIS GAME DOESN'T STORE LEVELS IN THE ORDER YOU PLAY THEM, COOL
---------------

-- update value in prevdata and return whether the value has changed, new value, and old value
-- value is only considered changed if it wasn't nil before
local function update_prev(key, value)
	if key == nil or value == nil then
		error("update_prev requires both a key and a value")
	end
	local prev_value = prevdata[key]
	prevdata[key] = value
	local changed = prev_value ~= nil and value ~= prev_value
	return changed, value, prev_value
end

local function sml1_swap(gamemeta)
	return function()
		local size_changed, shrinking, prev_shrinking = update_prev('shrinking', gamemeta.getsmlsize())
		-- when this variable is 3, Mario is shrinking
		local lives_changed, lives, prev_lives = update_prev('lives', gamemeta.getlives())
		-- usual lives counter idea
		local game_over_changed, game_over_bar, prev_game_over_bar = update_prev('game_over_bar', gamemeta.getgameover() ~= 57)
		-- this variable goes to 57 to show the GAME OVER bar
		return
			(size_changed and shrinking == 3) or
			(lives_changed and lives < prev_lives) or
			(game_over_changed and game_over_bar)
	end
end

local function somari_swap(gamemeta)
	return function()
		local sprite_changed, sprite, prev_sprite = update_prev('sprite', gamemeta.getsprite())
		local shield_changed, shield, prev_shield = update_prev('shield', gamemeta.getshield())
		return
			(sprite_changed and sprite == 10 and shield_changed == false) or -- when this variable is 9, Somari hurt sprite is on
			(sprite_changed and prev_sprite == 09) -- we just transitioned from the "you died" sprite
	end
end

local function demonscrest_swap(gamemeta)
	return function()
		local hp_changed, hp, prev_hp = update_prev('hp', gamemeta.p1gethp())
		local living_changed, living, prev_living = update_prev('living', gamemeta.p1getliving())
		local scene_changed, scene, prev_scene = update_prev('scene', gamemeta.p1getscene())
		return
			((hp_changed and hp < prev_hp and living == 1) or -- Firebrand just took damage
			(living_changed and living == 45 and prev_living == 1 and hp == 0)) -- Firebrand just died
			and
			scene ~= 37 -- 37 is the start of the credits for the Good and True endings, and HP drops to 2 there for some reason.
	end
end

local function FamilyFeud_SNES_swap(gamemeta)
	return function()
		local strike_changed, strike, prev_strike = update_prev('strike', gamemeta.getstrike()) 
		local player_changed, player, prev_player = update_prev('player', gamemeta.getwhichplayer())
		return
			(strike_changed and strike == 1) and  -- we just got a strike or 0
			(player < 2) -- It's player 1 or 2, not the CPU
		end
	end

--BATTLEMANIACS
-- This is the generic_swap from the Mega Man Damage Shuffler, modded to cover 2 potential players.
-- You can play as Pimple, Rash, or both, so the shuffler needs to monitor both toads.
-- They have the same max HP.
-- In BT SNES, damage should register even if a pip of health is not eliminated by an attack there.
local function battletoads_snes_swap(gamemeta)
	return function(data)

		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local p1currsprite = gamemeta.p1getsprite()
		local p2currhp = gamemeta.p2gethp()
		local p2currlc = gamemeta.p2getlc()
		local p2currsprite = gamemeta.p2getsprite()
		
		-- togglechecks handle when health/lives drop because of a sudden change in game mode (like a level change)
		currtogglecheck = false
		if gamemeta.gettogglecheck ~= nil then
			currtogglecheck = gamemeta.gettogglecheck()
		end

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
		local p1prevsprite = data.p1prevsprite
		local p2prevhp = data.p2prevhp
		local p2prevlc = data.p2prevlc
		local p2prevsprite = data.p2prevsprite
		local prevtogglecheck = data.prevtogglecheck

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p1prevsprite = p1currsprite
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc
		data.p2prevsprite = p2currsprite
		data.prevtogglecheck = currtogglecheck
		
		-- if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then
			return false
		end
		
		-- BT SNES likes to do a full 0-out of some memory values when you load a level.
		-- That should NOT shuffle!
		-- Return false if that is happening.
		
		if p1currhp == 0 and p2currhp == 0 and -- values dropped to 0
			p1currsprite == 0 and p2currsprite == 0 -- if both are 0, neither player is even on screen
		then
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
		elseif p2prevhp ~= nil and p2currhp < p2prevhp then
			data.p2hpcountdown = gamemeta.delay or 3
		end
		
		-- check to see if the life count went down
		
		-- When you're in 1P mode, the other toad's life counter is set to 255. When they join, lives then "drop" to 3.
		-- Thus, we ignore lives transitions from 255, to prevent unnecessary swaps when a toad "joins"
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
		
		if memory.read_u8(0x00002C, "WRAM") == 2 or memory.read_u8(0x00002C, "WRAM") == 8 then
			-- we are in the proper level, 2 (Pins) or 8 (Dominoes)
			if p1prevsprite ~= p1currsprite and p1currsprite == 128 then
				-- p1 was JUST hit (prior value was not the same)
				return true
			elseif p2prevsprite ~= p2currsprite and p2currsprite == 236 then
				-- p2 was JUST hit (prior value was not the same)
				return true
			end
		end
		
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
		if gamemeta.gettogglecheck ~= nil then
			currtogglecheck = gamemeta.gettogglecheck()
		end
		
		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

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
		
		-- if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then
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
		
		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then
			-- MUST CHECK THAT LIVES ALWAYS GO DOWN BY 1. BUT THIS SHOULD HELP REMOVE NONSENSE SWAPS
			return true
		end

		return false
	end
end

local function supermetroid_swap(gamemeta)
	return function()
		local hp_changed, currhp, prev_hp = update_prev('hp', gamemeta.gethp())
		local invuln_changed, invuln, prev_invuln = update_prev('invuln', gamemeta.getinvuln())
		-- when this variable is over 0, i-frames are on
		local samusstate_changed, samusstate, prevsamusstate = update_prev('samusstate', gamemeta.getsamusstate())
		-- this variable covers Samus states like saving, dying, normal gameplay, etc.

		return
			(invuln_changed and prev_invuln == 0 and currhp > 0 and hp_changed)
			-- i-frames just started, and we lost health on getting bumped (so, not for steam)
			or (samusstate_changed and samusstate == 25)
			-- Samus death animation just ended
	end
end

local function SMZ3_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end
		
		local currlinkhp = gamemeta.getlinkhp()
		local currlinklc = gamemeta.getlinklc()
		local currwhichgame = gamemeta.getwhichgame()

		local samushp_changed, currsamushp, samusprev_hp = update_prev('samushp', gamemeta.getsamushp())
		local invuln_changed, invuln, prev_invuln = update_prev('invuln', gamemeta.getinvuln())
		-- when this variable is over 0, i-frames are on
		local samusstate_changed, samusstate, prevsamusstate = update_prev('samusstate', gamemeta.getsamusstate())
		-- this variable covers Samus states like saving, dying, normal gameplay, etc.	
		
		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0
		
		-- Samus swaps
		if currwhichgame == 255 and
			((invuln_changed and prev_invuln == 0 and currsamushp > 0 and samushp_changed)
			-- i-frames just started and lost health
			or (samusstate_changed and samusstate == 25))
			-- Samus death animation just ended
		then
			return true
		end

		-- other swaps are geared toward LTTP specifically

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if currwhichgame == 0 and (currlinkhp < minhp or currlinkhp > maxhp) then
			return false
		end

		-- retrieve previous health and lives before backup
		local prevlinkhp = data.prevlinkhp
		local prevlinklc = data.prevlinklc
		local prevwhichgame = data.prevwhichgame
		
		data.prevlinkhp = currlinkhp
		data.prevlinklc = currlinklc
		data.prevwhichgame = currwhichgame

		-- DO NOT SWAP ON GAME CHANGE
		if prevwhichgame ~= nil and prevwhichgame ~= currwhichgame then
			return false
		end

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if currwhichgame == 0 then
			if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
				data.p1hpcountdown = data.p1hpcountdown - 1
				if data.p1hpcountdown == 0 and currlinkhp > minhp then
					return true
				end
			end
			
			-- if the health goes to 0, we will rely on the life count to tell us whether to swap
			if prevlinkhp ~= nil and currlinkhp < prevlinkhp then
				data.p1hpcountdown = gamemeta.delay or 3
			end

			-- check to see if the life count went down
			
			if prevlinklc ~= nil and currlinklc < prevlinklc then
				return true
			end

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
		local currtogglecheck = 0
		if gamemeta.gettogglecheck ~= nil then
			currtogglecheck = gamemeta.gettogglecheck()
		end
		
		-- we should now be able to use the typical shuffler functions normally.

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
		local prevtogglecheck = data.prevtogglecheck

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc
		data.prevtogglecheck = currtogglecheck
		
		
		-- if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then
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
		
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then
			return true
		end
		
		if p2prevlc ~= nil and p2currlc == p2prevlc - 1 then
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
		local currtogglecheck = 0
		if gamemeta.gettogglecheck ~= nil then
			currtogglecheck = gamemeta.gettogglecheck()
		end
		
		-- we should now be able to use the typical shuffler functions normally.

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
		local prevsmb2mode = data.prevsmb2mode
		local prevtogglecheck = data.prevtogglecheck
		
		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc
		data.prevsmb2mode = currsmb2mode
		data.prevtogglecheck = currtogglecheck
		
		-- DON'T SWAP WHEN WE JUST CAME OUT OF SMB2 SLOTS OR MENU
		if currsmb2mode ~= prevsmb2mode then
			return false
		end
		
		--if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then
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
		
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then
			return true
		end
		
		if p2prevlc ~= nil and p2currlc == p2prevlc - 1 then
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
		local minhp = gamemeta.minhp or 0
		
		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		
		-- NOTE: IN SDB, ONLY p1currhp1 and p1currbbplayer seem to inherit garbage values
		
		if p1currhp1 < minhp or (p1currhp1 > maxhp and currmode < 2) then
			return false
		elseif p1currbbplayer > 33 and currmode == 2 then
			-- highest value for this is 33
			return false
		end
		
		local p1currhp = p1currhp1 + p1currhp2 + p1currhp3 -- team 1
		local p2currhp = p2currhp1 + p2currhp2 + p2currhp3 -- team 2
		
		-- consider transforming the player to 1-6 to make this easy to look up.
		
		local beanballplayerhps = {
		memory.read_u8(0x0323, "RAM"),
		memory.read_u8(0x0393, "RAM"),
		memory.read_u8(0x0403, "RAM"),
		memory.read_u8(0x035B, "RAM"),
		memory.read_u8(0x03CB, "RAM"),
		memory.read_u8(0x043B, "RAM"),
		}
		
		-- 0 for 1, 16 for 2, 32 for 3, 1 for 4, 17 for 5, 33 for 6
		local p1currhpbb= beanballplayerhps[p1currbbplayer]
		local p2currhpbb= beanballplayerhps[p2currbbplayer]
		-- sub in the bb healths if we are in bb
		
		if currmode == 2 then
			p1currhp = p1currhpbb
			if currhowmanyplayers == 2 then
				p2currhp = p2currhpbb
			else
				p2currhp = 0
			end
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
		-- 1. There is a specific address that goes to 192 when a human player gets a letter wrong,
		-- then ticks down frame by frame to 0 or 16. Never moves up otherwise.
		-- 2. There is an address that counts down the die from 6 to 0.
		-- When you run out of time, this value hits 0, and you should swap.
		-- 3. There is an address that counts down the time to type in a guess.
		-- A CPU player will always provide a correct answer when this activates.
		-- However, when a human player runs out of time, this hits 0, then goes to 255.
		-- This should swap on 255, IGNORING the title screen.
		-- THESE VARIABLES ARE SHARED IN MULTIPLAYER YAY
		
		-- 4. We can now swap on a correct computer answer.
		-- Found value that is "who buzzed in"
		-- Found value for "faded out with correct answer," rolls up from 0 to 31
		-- if the computer rang in, and that value increases to 31, SWAP
		
		-- human player value 00AC can be 1, 2, 3, 4
		
		-- when who buzzed in > than 00AC, then we should swap if they get it right

		local _, currbotchedletter, prevbotchedletter = update_prev('botched_letter', gamemeta.getbotchedletter())
		local _, currbuzzintime, prevbuzzintime = update_prev('buzz_in_time', gamemeta.getbuzzintime())
		local _, currtypetime, prevtypetime = update_prev('type_time', gamemeta.gettypetime())
		local _, curranswerright, prevanswerright = update_prev('answer_right', gamemeta.getanswerright())

		-- wrong letter
		if prevbotchedletter ~= nil and currbotchedletter > prevbotchedletter then
			-- remember, only goes up when a wrong answer is guessed.
			return true
		end
		
		-- ran out of time to buzz in (ranges from 0-6, resets to 6 once the die appears, shuffle on drop to 0)
		if memory.read_u8(0x046E, "RAM") <= -- who rang in, defaults to 0
			memory.read_u8(0x00AC, "RAM") -- how many humans, defaults to 1 - so, not a computer player being award spaces
			and prevbuzzintime ~= nil and prevbuzzintime ~= 255
			and currbuzzintime < prevbuzzintime -- it'll stay on 0 for a while.
			and currbuzzintime == 0
		then
			-- NOTE: will reset to 0 also when all human players are out of guesses and no one else can answer.
			-- We don't want a second swap in those cases.
			-- In this case, currbotchedletter will == 0 or 16, and guess time will be < 25.
			if currtypetime < 25 and (currbotchedletter == 0 or currbotchedletter == 16) then
				return false
			end
			
			return true
		end
		
		-- ran out of time to type answer (ranges from 0-25, goes to 255 when timer is completely done)
		if prevtypetime ~= nil and prevtypetime == 0 and currtypetime == 255 then
			-- it'll stay on 255 for a while.
			return true
		end
		
		-- CPU correct answer swap
		if memory.read_u8(0x046E, "RAM") > -- who rang in, defaults to 0
			memory.read_u8(0x00AC, "RAM") -- how many humans, defaults to 1
			and prevanswerright ~= nil
			and curranswerright > prevanswerright -- this value rolls up when a card is awarded
			and curranswerright == 31 -- and hits 31 at max
		then
			return true -- swap!
		end

		return false
	end
end

local function smb3_swap(gamemeta)
	return function()
		-- if this address goes up from 0, invuln frames just got triggered.
		local invuln_changed, invuln_curr, invuln_prev = update_prev('invuln_curr', gamemeta.getinvuln())
		local boot_changed, boot = update_prev('boot', gamemeta.getboot()) -- Kuribo's shoe status
		local statue_changed, statue = update_prev('statue', gamemeta.getstatue()) -- tanooki statue status
		
		local p1_lives_changed, p1_lives_curr, p1_lives_prev = update_prev('p1_lives_curr', gamemeta.p1getlc())
		local p2_lives_changed, p2_lives_curr, p2_lives_prev = update_prev('p2_lives_curr', gamemeta.p2getlc())
		
		-- this will return whether we are in the 2p card battle (true/false)
		local smb3battling_changed, smb3battling_curr, smb3battling_prev = update_prev('smb3battling_curr', gamemeta.getsmb3battling())
		
		return (smb3battling_changed -- mode changed to/from active gameplay
				and smb3battling_prev == true) -- we were just in battle mode)
			or (invuln_changed and invuln_prev == 0 and not boot_changed and statue == 0)
			-- boot_changed if we dropped out of boot status, statue > 0 if statue timer counting down
			or (p1_lives_changed and p1_lives_curr < p1_lives_prev)
			or (p2_lives_changed and p2_lives_curr < p2_lives_prev)
	end
end

local function smk_swap(gamemeta)
	return function()
		local p1bumping, p1currbump, p1prevbump = update_prev('p1currbump', gamemeta.p1getbump())
		-- if > 0, p1 is colliding with something
		local p1coinschanged, p1currcoins, p1prevcoins = update_prev('p1currcoins', gamemeta.p1getcoins())
		-- coin count p1 - if goes down on bump, we'll swap (NOT ON LAKITU FEE)
		local p1spinningout, p1currspinout, p1prevspinout = update_prev('p1currspinout',
			-- if we start spinning out after a collision, swap (NOT ON BAD DRIFT)
			(gamemeta.p1getspinout() == 12 or -- crash
			gamemeta.p1getspinout() == 14 or -- spin out left
			gamemeta.p1getspinout() == 16 or -- spin out right
			gamemeta.p1getspinout() == 26)) -- also crash
		local p1falling, p1currfall, p1prevfall = update_prev('p1currfall', gamemeta.p1getfall() > 2)
		-- >2 means you fell, 4 for pit, 6 for lava, 8 for water
		local p1shrinking, p1currshrink, p1prevshrink = update_prev('p1currshrink', gamemeta.p1getshrink())
		-- if > 0, you are shrinking, then it counts down to 0
		local p1moled, p1currmoled, p1prevmoled = update_prev('p1currmoled', gamemeta.p1getmoled() >= 152)
		-- if >= 152, a mole just hopped on you, when off it drops to 24, then 0
		
		local p2bumping, p2currbump, p2prevbump = update_prev('p2currbump', gamemeta.p2getbump())
		-- if > 0, p2 is colliding with something
		local p2coinschanged, p2currcoins, p2prevcoins = update_prev('p2currcoins', gamemeta.p2getcoins())
		-- coin count p2 - if goes down on bump, we'll swap (NOT ON LAKITU FEE)
		local p2spinningout, p2currspinout, p2prevspinout = update_prev('p2currspinout',
			-- if we start spinning out after a collision, swap (NOT ON BAD DRIFT)
			(gamemeta.p2getspinout() == 12 or -- crash
			gamemeta.p2getspinout() == 14 or -- spin out left
			gamemeta.p2getspinout() == 16 or -- spin out right
			gamemeta.p2getspinout() == 26)) -- also crash
		local p2falling, p2currfall, p2prevfall = update_prev('p2currfall', gamemeta.p2getfall() > 2)
		-- >2 means you fell, 4 for pit, 6 for lava, 8 for water
		local p2shrinking, p2currshrink, p2prevshrink = update_prev('p2currshrink', gamemeta.p2getshrink())
		-- if > 0, you are shrinking, then it counts down to 0
		local p2moled, p2currmoled, p2prevmoled = update_prev('p2currmoled', gamemeta.p2getmoled() >= 152)
		-- if >= 152, a mole just hopped on you, when off it drops to 24, then 0
		
		local p2IsActive = gamemeta.p2getIsActive()
		-- 2p variables still get updated even if 2p is CPU, so we have to ignore all of those unless we are in 2p mode.
		
		return
			(p1falling and p1currfall) -- p1 just started falling into pit, lava, water
			-- or (p1shrinking and p1prevshrink == 0) -- p1 just started shrinking, or got run over so frame timer dropped more than 1 unit
			or (p1moled and p1currmoled) -- p1 just started shrinking
			or (p1bumping and -- p1 just started colliding AND EITHER
				((p1coinschanged and p1currcoins < p1prevcoins) -- coins dropped or
				or (p1currcoins == 0 and p1spinningout)) -- no coins and we just started spinning out
				or p1prevbump == 0 and p1currbump > 200) -- bump value goes this high when squished
			or
			p2IsActive == true and (
			(p2falling and p2currfall) -- p2 just started falling into pit, lava, water
			-- or (p2shrinking and p2prevshrink == 0) -- p2 just started shrinking, or got run over so frame timer dropped more than 1 unit
			or (p2moled and p2currmoled) -- p2 just started shrinking
			or (p2bumping and -- p2 just started colliding AND EITHER
				((p2coinschanged and p2currcoins < p2prevcoins) -- coins dropped or
				or (p2currcoins == 0 and p2spinningout)) -- no coins and we just started spinning out
				or p2prevbump == 0 and p2currbump > 200) -- bump value goes this high when squished
			)
	end
end

local function fzero_snes_swap(gamemeta)
	-- alternative option for F-Zero swapping, currently testing this out
	-- 0x00F5 is "collided with a wall", pops up to 9 then drops by 1 every frame back down to 0.
	-- We don't want a swap on just being "in" the wall or grazing it, necessarily.
	-- 0x00E9 is "hitting a guardrail" and is separate from colliding with the wall.
	-- So, you can say "no swaps" on hitting a guardrail == true when colliding with wall == false.
	-- can experiment with "invuln frames just popped from 0" AND either wall bump or other bump?
	return function()
		if 	memory.read_u8(0x0054, "WRAM") == 2 -- gamestate = "racing," and
			and memory.read_u8(0x0055, "WRAM") == 3 -- the race has started, and
			and memory.read_u8(0x00C8, "WRAM") == 0 -- invulnerability frames are done (0)
		then
			return false -- don't swap when all of those are true	
		end
		
		local hitwall_changed, hittingwall, prev_hittingwall = update_prev('hittingwall', gamemeta.gethittingwall())
		-- when this variable pops up from 0, you're hitting a wall.
		local invuln_changed, invuln, prev_invuln = update_prev('invuln', gamemeta.getinvuln())
		-- this pops up from 0 if you get i-frames, only goes up slightly for being in a wall
		local bump_changed, bump, prev_bump = update_prev('bump', gamemeta.getbump())
		-- this variable pops up if you are bounced by another car, a mine, etc.

		return
			(hitwall_changed and prev_hittingwall == 0) or
			(invuln_changed and invuln > prev_invuln and invuln >6) or
			(bump_changed and prev_bump == 0)
	end
end

local function Monopoly_NES_swap(gamemeta)
	-- goals: swap when you lose money, go to jail, or go bankrupt
	-- don't swap if: setting options at start of game, buying a property, winning an auction, trading, building on a property	
	return function(data)

		local _, currInEditor, prevInEditor = update_prev('in_editor', gamemeta.getInEditor())

		-- this needs cleanup with a table or something
		
		local _, p1currHuman, p1prevHuman = update_prev('p1_human', gamemeta.getp1Human())
		local _, p2currHuman, p2prevHuman = update_prev('p2_human', gamemeta.getp2Human())
		local _, p3currHuman, p3prevHuman = update_prev('p3_human', gamemeta.getp3Human())
		local _, p4currHuman, p4prevHuman = update_prev('p4_human', gamemeta.getp4Human())
		local _, p5currHuman, p5prevHuman = update_prev('p5_human', gamemeta.getp5Human())
		local _, p6currHuman, p6prevHuman = update_prev('p6_human', gamemeta.getp6Human())
		local _, p7currHuman, p7prevHuman = update_prev('p7_human', gamemeta.getp7Human())
		local _, p8currHuman, p8prevHuman = update_prev('p8_human', gamemeta.getp8Human())
		
		local _, p1currInJail, p1prevInJail = update_prev('p1_in_jail', gamemeta.getp1InJail())
		local _, p2currInJail, p2prevInJail = update_prev('p2_in_jail', gamemeta.getp2InJail())
		local _, p3currInJail, p3prevInJail = update_prev('p3_in_jail', gamemeta.getp3InJail())
		local _, p4currInJail, p4prevInJail = update_prev('p4_in_jail', gamemeta.getp4InJail())
		local _, p5currInJail, p5prevInJail = update_prev('p5_in_jail', gamemeta.getp5InJail())
		local _, p6currInJail, p6prevInJail = update_prev('p6_in_jail', gamemeta.getp6InJail())
		local _, p7currInJail, p7prevInJail = update_prev('p7_in_jail', gamemeta.getp7InJail())
		local _, p8currInJail, p8prevInJail = update_prev('p8_in_jail', gamemeta.getp8InJail())
		
		local _, p1currBankrupt, p1prevBankrupt = update_prev('p1_bankrupt', gamemeta.getp1Bankrupt())
		local _, p2currBankrupt, p2prevBankrupt = update_prev('p2_bankrupt', gamemeta.getp2Bankrupt())
		local _, p3currBankrupt, p3prevBankrupt = update_prev('p3_bankrupt', gamemeta.getp3Bankrupt())
		local _, p4currBankrupt, p4prevBankrupt = update_prev('p4_bankrupt', gamemeta.getp4Bankrupt())
		local _, p5currBankrupt, p5prevBankrupt = update_prev('p5_bankrupt', gamemeta.getp5Bankrupt())
		local _, p6currBankrupt, p6prevBankrupt = update_prev('p6_bankrupt', gamemeta.getp6Bankrupt())
		local _, p7currBankrupt, p7prevBankrupt = update_prev('p7_bankrupt', gamemeta.getp7Bankrupt())
		local _, p8currBankrupt, p8prevBankrupt = update_prev('p8_bankrupt', gamemeta.getp8Bankrupt())
		
		local _, p1currMoney, p1prevMoney = update_prev('p1_money', gamemeta.getp1Money())
		local _, p2currMoney, p2prevMoney = update_prev('p2_money', gamemeta.getp2Money())
		local _, p3currMoney, p3prevMoney = update_prev('p3_money', gamemeta.getp3Money())
		local _, p4currMoney, p4prevMoney = update_prev('p4_money', gamemeta.getp4Money())
		local _, p5currMoney, p5prevMoney = update_prev('p5_money', gamemeta.getp5Money())
		local _, p6currMoney, p6prevMoney = update_prev('p6_money', gamemeta.getp6Money())
		local _, p7currMoney, p7prevMoney = update_prev('p7_money', gamemeta.getp7Money())
		local _, p8currMoney, p8prevMoney = update_prev('p8_money', gamemeta.getp8Money())
		
		-- check all the property statuses
		-- each byte includes "owned," "owned by whom," "in a monopoly," "has buildings," "mortgaged," etc.
		-- these also, critically, change on the same frame as money changes
		
		local changedSpace01, currSpace01, prevSpace01 = update_prev('space_01', gamemeta.getSpace01())
		local changedSpace03, currSpace03, prevSpace03 = update_prev('space_03', gamemeta.getSpace03())
		local changedSpace05, currSpace05, prevSpace05 = update_prev('space_05', gamemeta.getSpace05())
		local changedSpace06, currSpace06, prevSpace06 = update_prev('space_06', gamemeta.getSpace06())
		local changedSpace08, currSpace08, prevSpace08 = update_prev('space_08', gamemeta.getSpace08())
		local changedSpace09, currSpace09, prevSpace09 = update_prev('space_09', gamemeta.getSpace09())
		local changedSpace11, currSpace11, prevSpace11 = update_prev('space_11', gamemeta.getSpace11())
		local changedSpace12, currSpace12, prevSpace12 = update_prev('space_12', gamemeta.getSpace12())
		local changedSpace13, currSpace13, prevSpace13 = update_prev('space_13', gamemeta.getSpace13())
		local changedSpace14, currSpace14, prevSpace14 = update_prev('space_14', gamemeta.getSpace14())
		local changedSpace15, currSpace15, prevSpace15 = update_prev('space_15', gamemeta.getSpace15())
		local changedSpace16, currSpace16, prevSpace16 = update_prev('space_16', gamemeta.getSpace16())
		local changedSpace18, currSpace18, prevSpace18 = update_prev('space_18', gamemeta.getSpace18())
		local changedSpace19, currSpace19, prevSpace19 = update_prev('space_19', gamemeta.getSpace19())
		local changedSpace21, currSpace21, prevSpace21 = update_prev('space_21', gamemeta.getSpace21())
		local changedSpace23, currSpace23, prevSpace23 = update_prev('space_23', gamemeta.getSpace23())
		local changedSpace24, currSpace24, prevSpace24 = update_prev('space_24', gamemeta.getSpace24())
		local changedSpace25, currSpace25, prevSpace25 = update_prev('space_25', gamemeta.getSpace25())
		local changedSpace26, currSpace26, prevSpace26 = update_prev('space_26', gamemeta.getSpace26())
		local changedSpace27, currSpace27, prevSpace27 = update_prev('space_27', gamemeta.getSpace27())
		local changedSpace28, currSpace28, prevSpace28 = update_prev('space_28', gamemeta.getSpace28())
		local changedSpace29, currSpace29, prevSpace29 = update_prev('space_29', gamemeta.getSpace29())
		local changedSpace31, currSpace31, prevSpace31 = update_prev('space_31', gamemeta.getSpace31())
		local changedSpace32, currSpace32, prevSpace32 = update_prev('space_32', gamemeta.getSpace32())
		local changedSpace34, currSpace34, prevSpace34 = update_prev('space_34', gamemeta.getSpace34())
		local changedSpace35, currSpace35, prevSpace35 = update_prev('space_35', gamemeta.getSpace35())
		local changedSpace37, currSpace37, prevSpace37 = update_prev('space_37', gamemeta.getSpace37())
		local changedSpace39, currSpace39, prevSpace39 = update_prev('space_39', gamemeta.getSpace39())
		
		-- start by ruling out times to swap
		if
			-- you are manually editing money before game
			currInEditor == 1 or
			-- any of the property values changed on the same frame
			changedSpace01 or changedSpace03 or
			changedSpace05 or changedSpace06 or
			changedSpace08 or changedSpace09 or
			changedSpace11 or changedSpace12 or
			changedSpace13 or changedSpace14 or
			changedSpace15 or changedSpace16 or
			changedSpace18 or changedSpace19 or
			changedSpace21 or changedSpace23 or
			changedSpace24 or changedSpace25 or
			changedSpace26 or changedSpace27 or
			changedSpace28 or changedSpace29 or
			changedSpace31 or changedSpace32 or
			changedSpace34 or changedSpace35 or
			changedSpace37 or changedSpace39 or
			-- there are no active players, like on final screen or menus
			((p1currBankrupt + p2currBankrupt + p3currBankrupt + p4currBankrupt +
				p5currBankrupt + p6currBankrupt + p7currBankrupt + p8currBankrupt) == 255*8)
		then
			return false
		end -- don't swap when any of those are true
		
		-- Now, we assume that money going down, player going bankrupt, player jail counter going up for a human means we swap

		-- implement delay so that we can catch the cause of the swap
		if data.p1countdown ~= nil and data.p1countdown > 0 then
			data.p1countdown = data.p1countdown - 1
			if data.p1countdown == 0 then
				return true
			end
		end
		
		if data.p2countdown ~= nil and data.p2countdown > 0 then
			data.p2countdown = data.p2countdown - 1
			if data.p2countdown == 0 then
				return true
			end
		end
	
		if data.p3countdown ~= nil and data.p3countdown > 0 then
			data.p3countdown = data.p3countdown - 1
			if data.p3countdown == 0 then
				return true
			end
		end
		
		if data.p4countdown ~= nil and data.p4countdown > 0 then
			data.p4countdown = data.p4countdown - 1
			if data.p4countdown == 0 then
				return true
			end
		end
		
		if data.p5countdown ~= nil and data.p5countdown > 0 then
			data.p5countdown = data.p5countdown - 1
			if data.p5countdown == 0 then
				return true
			end
		end
		
		if data.p6countdown ~= nil and data.p6countdown > 0 then
			data.p6countdown = data.p6countdown - 1
			if data.p6countdown == 0 then
				return true
			end
		end
		
		if data.p7countdown ~= nil and data.p7countdown > 0 then
			data.p7countdown = data.p7countdown - 1
			if data.p7countdown == 0 then
				return true
			end
		end
		
		if data.p8countdown ~= nil and data.p8countdown > 0 then
			data.p8countdown = data.p8countdown - 1
			if data.p8countdown == 0 then
				return true
			end
		end
		
		-- if money goes down, or jail counter goes up, or bankrupt hits true for a human, start the countdown
		if
			p1prevHuman ~= nil and p1currHuman == 0 and
			((p1prevMoney ~= nil and p1currMoney < p1prevMoney) or
			(p1prevInJail ~= nil and p1currInJail > p1prevInJail) or
			(p1prevBankrupt ~= nil and p1currBankrupt == 255 and p1prevBankrupt == 0)) == true
		then
			data.p1countdown = gamemeta.delay
		elseif
			p2prevHuman ~= nil and p2currHuman == 0 and
			((p2prevMoney ~= nil and p2currMoney < p2prevMoney) or
			(p2prevInJail ~= nil and p2currInJail > p2prevInJail) or
			(p2prevBankrupt ~= nil and p2currBankrupt == 255 and p2prevBankrupt == 0)) == true
		then
			data.p2countdown = gamemeta.delay
		elseif
			p3prevHuman ~= nil and p3currHuman == 0 and
			((p3prevMoney ~= nil and p3currMoney < p3prevMoney) or
			(p3prevInJail ~= nil and p3currInJail > p3prevInJail) or
			(p3prevBankrupt ~= nil and p3currBankrupt == 255 and p3prevBankrupt == 0)) == true
		then
			data.p3countdown = gamemeta.delay
		elseif
			p4prevHuman ~= nil and p4currHuman == 0 and
			((p4prevMoney ~= nil and p4currMoney < p4prevMoney) or
			(p4prevInJail ~= nil and p4currInJail > p4prevInJail) or
			(p4prevBankrupt ~= nil and p4currBankrupt == 255 and p4prevBankrupt == 0)) == true
		then
			data.p4countdown = gamemeta.delay
		elseif
			p5prevHuman ~= nil and p5currHuman == 0 and
			((p5prevMoney ~= nil and p5currMoney < p5prevMoney) or
			(p5prevInJail ~= nil and p5currInJail > p5prevInJail) or
			(p5prevBankrupt ~= nil and p5currBankrupt == 255 and p5prevBankrupt == 0)) == true
		then
			data.p5countdown = gamemeta.delay
		elseif
			p6prevHuman ~= nil and p6currHuman == 0 and
			((p6prevMoney ~= nil and p6currMoney < p6prevMoney) or
			(p6prevInJail ~= nil and p6currInJail > p6prevInJail) or
			(p6prevBankrupt ~= nil and p6currBankrupt == 255 and p6prevBankrupt == 0)) == true
		then
			data.p6countdown = gamemeta.delay
		elseif
			p7prevHuman ~= nil and p7currHuman == 0 and
			((p7prevMoney ~= nil and p7currMoney < p7prevMoney) or
			(p7prevInJail ~= nil and p7currInJail > p7prevInJail) or
			(p7prevBankrupt ~= nil and p7currBankrupt == 255 and p7prevBankrupt == 0)) == true
		then
			data.p7countdown = gamemeta.delay
		elseif
			p8prevHuman ~= nil and p8currHuman == 0 and
			((p8prevMoney ~= nil and p8currMoney < p8prevMoney) or
			(p8prevInJail ~= nil and p8currInJail > p8prevInJail) or
			(p8prevBankrupt ~= nil and p8currBankrupt == 255 and p8prevBankrupt == 0)) == true
		then
			data.p8countdown = gamemeta.delay
		end
	end
end

local function iframe_health_swap(gamemeta)
	return function(data)
		local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		local health_changed, health_curr, health_prev = false, 0, 0
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		if gamemeta.get_health then
			health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		end
		local iframe_minimum = 0
		if gamemeta.iframe_minimum then
			iframe_minimum = gamemeta.iframe_minimum()
		end
		-- check if we're in a valid gamestate
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		-- assumptions: by default, the iframe counter is at 0
		-- if iframes > 0, you got hit
		-- some games will let you take damage on 1 iframe left
		-- (presumably, iframes go down to 0, then it checks for damage, then sets iframes back to max)
		-- certain games do damage over time using a short iframe timer, so check a minimum iframe count to shuffle
		local iframes_valid = iframes_changed and iframes_curr > iframes_prev and iframes_prev <= 1 and iframes_curr >= iframe_minimum
		if gamemeta.get_health then
			-- check 0 health for games that don't set iframes on death
			if (iframes_valid or health_curr == 0) and health_changed and health_curr < health_prev then
				data.delayCountdown = gamemeta.delay or 3
			end
		elseif iframes_valid then
			data.delayCountdown = gamemeta.delay or 3
		end
		-- sometimes you want to swap for things that don't give iframes and change health, like non-standard game overs
		if gamemeta.other_swaps() then
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

local function health_swap(gamemeta)
	return function(data)
		-- for games where iframes are unhelpful
		local health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		-- check if we're in a valid gamestate
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		if health_changed and health_curr < health_prev then
			data.delayCountdown = gamemeta.delay or 3
		end
		-- sometimes you want to swap for things that don't reduce health
		if gamemeta.other_swaps() then
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

-- Credit to Rogue_Millipede for the basis of this code
local function sotn_swap(gamemeta)
	return function ()
		-- check if we're in a valid gamestate
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		local max_health = gamemeta.max_health()
		local min_health = gamemeta.min_health or 0
		if gamemeta.get_health() < min_health or gamemeta.get_health() > max_health then
			return false
		end

		local health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		local state_changed, state_curr, state_prev = update_prev("player_state", gamemeta.get_player_state())
		local game_over_check_changed, game_over_check_curr, game_over_check_prev = update_prev("game_over_check", gamemeta.game_over_check())

		if ((health_changed and health_curr < health_prev) -- health went down
				or (gamemeta.stone_state and state_changed and state_curr == gamemeta.stone_state)) -- 0 damage, but player was petrified
			and iframes_changed and iframes_prev == 0 -- I-frames went up (i.e.: it isn't water)
			and health_curr > min_health -- We didn't just die (delay until the game over check passes)
		then
			return true
		end

		if (game_over_check_changed and game_over_check_curr) then -- Game over is starting
			return true
		end

		return false -- Nothing that would change the game occurred
	end
end

local function jonathan_charlotte_swap(gamemeta)
	return function (data)
		-- wow! two iframe counters!
		local j_iframes_changed, j_iframes_curr, j_iframes_prev = update_prev('jonathan iframes', gamemeta.get_jonathan_iframes())
		local c_iframes_changed, c_iframes_curr, c_iframes_prev = update_prev('charlotte iframes', gamemeta.get_charlotte_iframes())
		local health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		-- unlike Symphony, Portrait sets iframes on death, don't need to check for that
		if gamemeta.is_jonathan() and j_iframes_changed and j_iframes_prev <= 1
			and health_changed and health_curr < health_prev
		then
			-- jonathan!
			data.delayCountdown = gamemeta.delay or 3
		elseif not gamemeta.is_jonathan() and c_iframes_changed and c_iframes_prev <= 1
			and health_changed and health_curr < health_prev
		then
			-- charlotte!
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

local function damage_buffer_swap(gamemeta)
	return function (data)
		-- games that instead of decreasing health directly, set a "damage buffer" value that then decreases health per frame
		local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		local buffer_changed, buffer_curr, buffer_prev = update_prev('damage buffer', gamemeta.get_damage_buffer())
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		if iframes_changed and iframes_prev == 0 and buffer_changed and buffer_curr > buffer_prev then
			-- if the buffer is very large, it may not hit 0 before iframes run out
			-- will this ever actually happen in practice? maybe not, but may as well future-proof this
			data.delayCountdown = gamemeta.delay or 3
		end
		-- sometimes you want to swap for things that don't reduce health
		if gamemeta.other_swaps() then
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

local function ocarina_swap(gamemeta)
	return function ()
		-- every version of ocarina of time has different memory addresses so it gets its own function
		-- so all the miscellaneous shuffle conditions only have to be written once
		-- local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		-- redeads don't do iframes, and while they set a "grabbed" variable on link,
		-- the same variable is set by dead hand's hands, which deal no damage and must be grabbed by to make it show up
		-- this same variable is also set by morpha, whose grab damage is much faster than redeads'
		-- shabom (bubbles in jabu) and big skulltulas set iframes 3 frames after damage and so don't shuffle
		-- so i guess we're back to ignoring iframes! this game
		-- i would really have liked to only shuffle once when initially grabbed by redead/morpha
		-- but that's part of the actor's data and i really don't want to deal with that
		local internal_health = gamemeta.get_health()
		-- 0x0: full heart
		-- 0x1-0x5: quarter heart
		-- 0x6-0xA: half heart
		-- 0xB-0xF: three quarter heart
		-- convert internal health to "quarter hearts displayed" to only shuffle when fire damage etc makes health visibly decrease
		local partialHeart = internal_health % 0x10
		local fullHearts = (internal_health - partialHeart) / 0x10
		if partialHeart == 0 then
			partialHeart = 0
		elseif partialHeart <= 5 then
			partialHeart = 1
		elseif partialHeart <= 10 then
			partialHeart = 2
		else
			partialHeart = 3
		end
		local health_curr = fullHearts * 4 + partialHeart
		local health_changed, _, health_prev = update_prev('health', health_curr)
		-- local link_grabbed = gamemeta.is_link_grabbed()
		-- local void_changed, void_curr, _ = update_prev('void', gamemeta.get_respawn_flag())
		-- 1: standard void out, 0xFF: dampe race void out, wallmaster
		-- 0xFE: ganon's tower collapse time up, sun's song in time-stopped area
		-- no longer needed since we no longer check iframes
		local savefile = gamemeta.get_savefile()
		-- 0-2 for save files 1-3, 255 on title/file select/etc
		local max_health = gamemeta.get_max_health()
		-- since all memory is 0 on reset, need a value that is not 0 during gameplay to check gamestate is valid
		local text_id_changed, text_id_curr, _ = update_prev('text id', gamemeta.get_text_id())
		-- 0 when no textbox present, otherwise the id of the textbox's text
		-- this won't play well with text randomization, or hacks that change which ids are used for certain things
		-- but it's a lot simpler than wading through n64 memory allocation to detect these conditions other ways
		if savefile >= 3 or max_health == 0 then
			return false
		end
		-- if ((iframes_changed and iframes_prev <= 1 and iframes_curr > iframes_prev) or health_curr == 0 or link_grabbed)
		if health_changed and health_curr < health_prev then
			return true, 15 -- ocarina updates health 9 whole frames before you actually see link get hit for some reason
			-- then add a bit extra so the player has time to notice the hit
			-- 9 "emulator frames", ocarina runs at 20 fps so 3 visible frames
		end
		-- volcano time up just sets health to 0, which shuffles
		-- gerudo spin attack that sends to jail deals damage and sets iframes as well
		-- the timer running out in ganon's tower collapse refills your health??? ok
		if text_id_changed
			and (text_id_curr == 0x702D -- caught by hyrule castle guard
				-- "Hey you! Stop! You, kid, over there!"
				or text_id_curr == 0x6000 -- caught by gerudo guard
				-- "Halt! Stay where you are!"
				or text_id_curr == 0x4082 -- fish escaped from hook
				-- "Hey, what happened? You lost it!"
				or text_id_curr == 0x203D -- lost first ingo horse race
				-- "Hee hee hee... Too bad for you! I get your 50 Rupees."
				or text_id_curr == 0x203E -- lost second ingo horse race
				-- "Wah ha hah! You're just a kid, after all!"
				or text_id_curr == 0x102D -- lost at ocarina memory game
				-- "Too bad...Heh heh!"
				or text_id_curr == 0x71AD -- lost at shooting gallery, zora diving game
				-- "Too bad! Practice hard and come back!"
				or text_id_curr == 0x2081 -- lost at cucco search game
				-- "Time's up! Too baaaaad!! These are some great Cuccos aren't they!"
				or text_id_curr == 0x71B0)-- trade item expired
				-- "Oh, no! Time's up!"
			-- bombchu bowling uses 0x001A "Do you want to play again?" for both losing and winning
		then
			return true, 60
		end
		return false
	end
end

-- TODO: Not necessary anymore?
local function saturn_fix_string_endianness(byteArray)
	local byteArray2 = {}
	
	-- Rotate bytes
	for i = 1, #byteArray, 2 do
		byteArray2[i] = byteArray[i+1];
		byteArray2[i+1] = byteArray[i];
	end
	-- Find the end of the string so debugging actually friggin' works
	local endHere = 1;
	for i = 1, #byteArray2, 1 do
		if (byteArray2[i] == 0x00) then
			break;
		end
		endHere = i;
	end
	-- Convert to chars
	local charArray = {};
	for i = 1, endHere, 1 do
		charArray[i] = string.char(byteArray2[i]);
	end
	local returnString = table.concat(charArray);
	return string.sub(returnString, 1, endHere);
end

local function Pebble_Beach_Golf_Links_swap(gamemeta)
	return function(data)
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end

--		local currentPlayerChanged, currentPlayer, previousPlayer = update_prev('player', gamemeta.getCurrentPlayer());
--		local player1Changed, player1, prevPlayer1 = update_prev('player1', gamemeta.getPlayer1());
--		-- TODO: This is presumably gonna swap twice if the player was the last to go - thrice if Coffee Break happens. Really need another RAM address to check...
--		-- ALSO TODO: use prevdata to store if an empty player string was encountered. If so, ignore the next two-or-so swaps?
--		if (currentPlayerChanged) then
--			console.log(string.format("Current player changed from \"%s\" to \"%s\"", previousPlayer, currentPlayer));
--			if (previousPlayer == prevPlayer1) then
--				console.log(string.format("Previous player \"%s\" was Player 1 (\"%s\"); will be swapping", previousPlayer, prevPlayer1));
--				data.delayCountdown = gamemeta.delay;
--			else
--				console.log(string.format("Previous player \"%s\" was NOT Player 1 (\"%s\"); no swap needed", previousPlayer, prevPlayer1));
--			end;
--		end;

		if (gamemeta.gmode and not gamemeta.gmode()) then
			return false; -- Not actually in a round
		end
		local holeChanged, hole, prevHole = update_prev('hole', gamemeta.getHole());
		if (hole < 1 or hole > 18) then -- There are only 18 holes.
			return false;
		end
		if (holeChanged) then
			--console.log("Hole has changed from "..prevHole.." to "..hole.."; setting P1 strokes to 0");
			update_prev('p1HoleStrokes', 0); -- Reset this now before we actually care
		end
		local player1ScoreArray = gamemeta.getPlayer1Scores();
		-- Rotate bytes, because odd and even positions are swapped, IDK why, endianness doesn't usually work like this
		for i = 1, #player1ScoreArray, 2 do
			local temp = player1ScoreArray[i];
			player1ScoreArray[i] = player1ScoreArray[i+1];
			player1ScoreArray[i+1] = temp;
		end
		local player1StrokesChanged, player1Strokes, prevPlayer1Strokes = update_prev('p1HoleStrokes', player1ScoreArray[hole]);
		if (player1StrokesChanged) then
			--console.log("P1 Strokes on hole "..hole.." has changed from "..prevPlayer1Strokes.." to "..player1Strokes);
		end
		if (player1StrokesChanged and player1Strokes == (prevPlayer1Strokes + 1)) then
			data.delayCountdown = gamemeta.delay;
		end
	end
end

local function NBA_Jam_swap(gamemeta)
	return function(data)
		-- Swap if other team scores, quarter changes, or shot timer runs out while player is holding the ball
		local opposingTeamScoreChanged, opposingTeamScore, prevOpposingTeamScore = update_prev('opposingTeamScore', gamemeta.getOpposingTeamScore());
		local teamWithBallChanged, teamWithBall, prevTeamWithBall = update_prev('teamWithBall', gamemeta.getTeamWithBall());
		local shotClockChanged, shotClock, prevShotClock = update_prev('shotClock', gamemeta.getOpposingTeamScore());
		local shotClockViolationMessageTimerChanged, shotClockViolationMessageTimer, prevShotClockViolationMessageTimer = update_prev('shotClockViolationMessageTimer', gamemeta.getShotClockViolationMessageTimer());
		local quarterChanged, quarter, prevQuarter = update_prev('quarter', gamemeta.getQuarter());
		
		-- If quarter changed, swap immediately.
		if (quarterChanged and quarter == (prevQuarter+1)) then
			--console.log(string.format("Quarter went from %d to %d; swapping", prevQuarter, quarter));
			return true;
		end
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		-- Don't do any further processing if the game mode is wrong.
		if (gamemeta.gmode and not gamemeta.gmode()) then
			return false;
		end
		-- If opposing team score went up, swap after a delay
		if (opposingTeamScoreChanged and opposingTeamScore > prevOpposingTeamScore) then
			--console.log(string.format("Opposing team score went from %d to %d; swapping in %d frames", prevOpposingTeamScore, opposingTeamScore, gamemeta.delay));
			data.delayCountdown = gamemeta.delay;
		end
		-- If "SHOT CLOCK VIOLATION" is flashing on-screen and the player's team had the ball, swap after a delay
		if (shotClockViolationMessageTimerChanged and shotClockViolationMessageTimer > prevShotClockViolationMessageTimer) then
			if (teamWithBall == 0 or (teamWithBall == -1 and teamWithBallChanged and prevTeamWithBall == 0)) then
				--console.log(string.format("Player held the ball too long without shooting; swapping in %d frames", gamemeta.delay));
				data.delayCountdown = gamemeta.delay;
			end
		end
	end
end

-- An entire clone of singleplayer_withlives_swap because RKA has to be SPECIAL
-- with everything it does vis-à-vis health and lives 😒
local function Rocket_Knight_Adventures_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			--console.log("Not gamemode; skipping");
			return false
		end

		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local currtogglecheck = 0
		if gamemeta.gettogglecheck ~= nil then currtogglecheck = gamemeta.gettogglecheck() end

		local maxhp = gamemeta.maxhp()

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		-- but don't check minhp BECAUSE ANY NEGATIVE VALUE IS VALID IN THIS GAME
		if p1currhp > maxhp then
			--console.log("p1currhp ("..p1currhp..") > "..maxhp.."; skipping");
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
			--console.log("p1hpcountdown: "..data.p1hpcountdown);
			if data.p1hpcountdown == 0 and p1currhp >= 0 then
				--console.log("p1hpcountdown is 0; HP "..p1currhp.." >= 0, so swapping");
				return true
			end
		end

		-- if health goes below 0, we will rely on life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
			--console.log("HP went from "..p1prevhp.." to "..p1currhp.."; setting p1hpcountdown to "..data.p1hpcountdown);
		end

		-- check to see if life count went down
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then -- MUST CHECK THAT LIVES ALWAYS GO DOWN BY 1. BUT THIS SHOULD HELP REMOVE NONSENSE SWAPS
			--console.log("Lives went from "..p1prevlc.." to "..p1currlc..", so swapping");
			return true
		end

		--console.log("All good; health: "..p1currhp..", lives: "..p1currlc);
		return false
	end
end

-- 240p Suite on NES has a stopwatch, so you can force a swap within a second
-- Useful if you only have one real game to test swaps on
local function StopWatch_swap(gamemeta)
	return function()
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		local secondsChanged, seconds, prevSeconds = update_prev('seconds', memory.read_u8(0x0029, "RAM"));
		if (secondsChanged) then return true end;
		return false;
	end
end

local function castlevania_n64_swap(gamemeta)
	return function(data)
		-- TODO: These games have poison DOTs. Every single tick would shuffle. Is that desirable?

		-- Derive the gamestate ID the way the game does, rather roundaboutly:
		-- a pointer to a RAM address with a pointer to ANOTHER RAM address with
		-- the data we seek 0x24 (36) bytes later. Memory management, everyone!
		local gamestate = nil
		local prevGamestate = nil
		local gamestateChanged = nil
		if gamemeta.gamestate_ptr_addr then
			local gamestate_ptr_addr = gamemeta.gamestate_ptr_addr();
			local gamestate_ptr = memory.read_u32_be(gamestate_ptr_addr & 0x7FFFFF, "RDRAM");
			gamestateChanged, gamestate, prevGamestate = update_prev('gamestate', memory.read_s32_be((gamestate_ptr + 0x24) & 0x7FFFFF, "RDRAM"));
		end
		-- Debug test
		--[[if gamestateChanged then
			if prevGamestate then
				console.log("Gamestate changed from "..prevGamestate.." to "..gamestate);
			else
				console.log("Gamestate changed to "..gamestate);
			end
		end]]
		-- If all the pieces are in place, check if we're in gameplay or are about to head to a Game Over
		if gamestate and ((gamemeta.gameplaymode and gamestate ~= gamemeta.gameplaymode())
				and (gamemeta.enteringgameovermode and gamestate ~= gamemeta.enteringgameovermode())) then
			return false -- Don't ever swap if we aren't doing either of those
		end

		local p1currhp = gamemeta.p1gethp()
		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- Health must be within an acceptable range to count
		if p1currhp < minhp or p1currhp > maxhp then
			return false
		end

		-- Retrieve previous health before backup
		local p1prevhp = data.p1prevhp
		-- Backup current health
		data.p1prevhp = p1currhp

		-- This delay is for games that tick away health at the end of a level.
		-- CV64 doesn't do that (in fact you GAIN health at level's end), but
		-- I'm too chicken to change it.
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			--console.log("p1hpcountdown: "..data.p1hpcountdown);
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				--console.log("p1hpcountdown is 0; HP "..p1currhp.." > "..minhp..", so swapping");
				return true
			end
			-- If health goes to 0, rely on whether we're going to the Game Over
			-- gamestate to tell us whether to swap
		end

		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
			--console.log("HP went from "..p1prevhp.." to "..p1currhp.."; setting p1hpcountdown to "..data.p1hpcountdown);
		end

		-- Are we about to go to a Game Over state? Swap if we are!
		if gamestate and gamemeta.enteringgameovermode and gamemeta.gameplaymode and gamestateChanged
				and gamestate == gamemeta.enteringgameovermode() and prevGamestate == gamemeta.gameplaymode() then
			--console.log("Detected shift from gameplay to Game Over, so swapping");
			return true
		end

		return false
	end
end


-- Modified version of the gamedata for Mega Man games on NES.
-- Battletoads NES and BTDD each show 6 "boxes" that look like HP.
-- But, each toad actually has a max HP of 47. Each box is basically 8 HP.
-- If your health falls 40, you go from 6 boxes to 5. Anything from 41-47 will still show 6 boxes.
-- At 32, you have 4 boxes. At 24, 3 boxes. And so on - until a death at HP = 0.
-- We only want to shuffle when the # of HP on screen changes, because 'light' damage (say, of only 2 HP from a chop by one of the pigs at the beginning) gets partially refilled over time.
-- So, dividing the current HP value by 8, then rounding up, gives us the number of health boxes the toad has.
local gamedata = {
	['BT_NES']={ -- Battletoads NES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x051A, "RAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x051B, "RAM")/8) end,
		p1getlc=function() return memory.read_u8(0x0011, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0012, "RAM") end,
		gettogglecheck=function() return memory.read_u8(0x0011, "RAM") == 255 or memory.read_u8(0x0011, "RAM") == 255 end, --did a toad just join or drop?
		maxhp=function() return 6 end,
	},
	['BT_NES_patched']={ -- Battletoads NES with bugfix patch
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x051A, "RAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x051B, "RAM")/8) end,
		p1getlc=function() return memory.read_u8(0x0011, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0012, "RAM") end,
		gettogglecheck=function() return memory.read_u8(0x0011, "RAM") == 255 or memory.read_u8(0x0011, "RAM") == 255 end, --did a toad just join or drop?
		maxhp=function() return 6 end,
	},
	['BTDD_NES']={ -- Battletoads Double Dragon NES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x051B, "RAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x051C, "RAM")/8) end,
		p1getlc=function() return memory.read_u8(0x0011, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0012, "RAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0011 end,
		p2livesaddr=function() return 0x0012 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0011, "RAM") > 0 and memory.read_u8(0x0011, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x0012, "RAM") > 0 and memory.read_u8(0x0012, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['BT_SNES']={ -- Battletoads in Battlemaniacs for SNES
		func=battletoads_snes_swap,
		p1gethp=function() return memory.read_u8(0x000E5E, "WRAM") end,
		p2gethp=function() return memory.read_u8(0x000E60, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x000028, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x00002A, "WRAM") end,
		p1getsprite=function() return memory.read_u8(0x000AEE, "WRAM") end, -- this is an address for the sprite called for p1
		p2getsprite=function() return memory.read_u8(0x000AF0, "WRAM") end, -- this is an address for the sprite called for p2
		gettogglecheck=function() return
			memory.read_u16_le(0x000F0A, "WRAM") == 65535
			and memory.read_u16_le(0x000F0C, "WRAM") == 65535
			and memory.read_u8(0x00002C, "WRAM") ~= 3 end,
		-- these addresses are the counters for # of pins/dominoes in bonus rounds
		-- they pop in or out of FFFF (65535) when entering/exiting a level, and health also drops to 0 at the same time
		-- so we won't swap on the frame that this toggles on/off!
		-- the exception is that we SHOULD swap when this drops to 0 upon reaching Turbo Tunnel Rematch (level == 3)!
		maxhp=function() return 16 end,
	},
	['BTDD_SNES']={ -- Battletoads Double Dragon SNES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x00003A, "WRAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x00003C, "WRAM")/8) end,
		p1getlc=function() return memory.read_u8(0x000026, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x000028, "WRAM") end,
		maxhp=function() return 6 end,
		
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000026 end,
		p2livesaddr=function() return 0x000028 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x000026, "WRAM") > 0 and memory.read_u8(0x000026, "WRAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x000028, "WRAM") > 0 and memory.read_u8(0x000028, "WRAM") < 255 end,
		LivesWhichRAM=function() return "WRAM" end,
	},
	['BTDD_SNES_patched']={ -- Battletoads Double Dragon SNES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x00003A, "WRAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x00003C, "WRAM")/8) end,
		p1getlc=function() return memory.read_u8(0x000026, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x000028, "WRAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000026 end,
		p2livesaddr=function() return 0x000028 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x000026, "WRAM") > 0 and memory.read_u8(0x000026, "WRAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x000028, "WRAM") > 0 and memory.read_u8(0x000028, "WRAM") < 255 end,
		LivesWhichRAM=function() return "WRAM" end,
	},
	['CNDRR1_NES']={ -- Chip and Dale 1 (NES)
		func=twoplayers_withlives_swap,
		-- three addresses for hearts - if the heart is there, these == 24 (18 hex) , otherwise they == 248 (F8 hex).
		p1gethp=function()
			if memory.read_u8(0x0210, "RAM") == 24 then
				return 3
			elseif memory.read_u8(0x020C, "RAM") == 24 then
				return 2
			elseif memory.read_u8(0x0208, "RAM") == 24 then
				return 1
			else
				return 0
			end
		end,
		p2gethp=function()
			if memory.read_u8(0x0224, "RAM") == 24 then
				return 3
			elseif memory.read_u8(0x0220, "RAM") == 24 then
				return 2
			elseif memory.read_u8(0x021C, "RAM") == 24 then
				return 1
			else
				return 0
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x05B6 end,
		p2livesaddr=function() return 0x05E6 end,
		maxlives=function() return 135 end, -- rescue rangers counts strangely
		p1getlc=function() return memory.read_u8(0x05B6, "RAM") end,
		p2getlc=function() return memory.read_u8(0x05E6, "RAM") end,
		ActiveP1=function() return memory.read_u8(0x05B6, "RAM") > 0 and memory.read_u8(0x05B6, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x05E6, "RAM") > 0 and memory.read_u8(0x05E6, "RAM") < 255 end,
		maxhp=function() return 3 end,
	},
	['CNDRR2_NES']={ -- Chip and Dale 2 (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return memory.read_u8(0x03D4, "RAM") end,
		p2gethp=function() return memory.read_u8(0x03D5, "RAM") end,
		p1getlc=function() return memory.read_u8(0x00A7, "RAM") end,
		p2getlc=function() return memory.read_u8(0x00A8, "RAM") end,
		maxhp=function() return 5 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x00A7 end,
		p2livesaddr=function() return 0x00A8 end,
		maxlives=function() return 70 end,
		ActiveP1=function() return memory.read_u8(0x00A7, "RAM") > 0 and memory.read_u8(0x00A7, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x00A8, "RAM") > 0 and memory.read_u8(0x00A8, "RAM") < 255 end,
	},
	['SuperDodgeBall']={ -- Super Dodge Ball (NES)
		func=sdbnes_swap,
		gethowmanyplayers=function() return memory.read_u8(0x006F, "RAM") end,
		-- # humans, 1 or 2, use this to tell whether to swap if 2p team takes damage
		getmode=function() return memory.read_u8(0x06B1, "RAM") end,
		-- mode: 0 for 1p, 1 for 2p vs, 2 for bean ball
		p1gethp1=function() return memory.read_u8(0x058B, "RAM") end,
		p1gethp2=function() return memory.read_u8(0x0553, "RAM") end,
		p1gethp3=function() return memory.read_u8(0x051B, "RAM") end,
		p2gethp1=function() return memory.read_u8(0x043B, "RAM") end,
		p2gethp2=function() return memory.read_u8(0x0403, "RAM") end,
		p2gethp3=function() return memory.read_u8(0x03CB, "RAM") end,
		p1getbbplayer=function() return (1 + math.floor(memory.read_u8(0x0587, "RAM")/16) + 3*(memory.read_u8(0x0587, "RAM") % 16)) end,
		-- transforming from 0, 16, 32, 1, 17, 33 format
		p2getbbplayer=function() return (1 + math.floor(memory.read_u8(0x0588, "RAM")/16) + 3*(memory.read_u8(0x0588, "RAM") % 16)) end,
		-- transforming from 0, 16, 32, 1, 17, 33 format
		gmode=function() return (memory.read_u8(0x0070, "RAM")%2) == 0 end,
		-- several potential values, but if it's ever odd, we're not in-game.
		maxhp=function() return 60 end,
	},
	['CaptainNovolin']={ -- Captain Novolin SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0BDA, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x06C3, "WRAM") end,
		maxhp=function() return 4 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x06C3 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 3 end,
		ActiveP1=function() return memory.read_u8(0x06C3, "WRAM") > 1 and memory.read_u8(0x06C3, "WRAM") < 3 end,
	},
	['Zelda_LTTP']={ -- The Legend of Zelda: A Link to the Past, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function()
			if (memory.read_u8(0x0010, "WRAM") < 23 and memory.read_u8(0x0010, "WRAM") >5) then
				-- <=5 means we're on the title/menu, 23 means save/quit and >23 is credits, etc. Don't swap on those!
				return memory.read_u8(0xF36D, "WRAM")
			else
				return 0
			end
		end, -- single byte!
		maxhp=function() return 160 end, -- 8 hp per heart, 20 heart containers
		p1getlc=function()
			if memory.read_u8(0x0010, "WRAM") == 18 then
			-- this value is the "Link is in a death spiral" value - so it tells us Link hit 0 for real, not due to resets etc.
				return 1
			else
				return 2
			end
		end,
	},
	['MetroidSuper']={ -- Super Metroid, SNES
		func=supermetroid_swap,
		getinvuln=function() return memory.read_u16_le(0x18A8, "WRAM") end,
		-- this value is 0 until i-frames are triggered
		getsamusstate=function() return memory.read_u8(0x0998, "WRAM") end,
		-- this value is the "game state" where the game is fading out after Samus dies.
		-- Tells us Samus hit 0 for real, not due to resets etc.
		gethp=function() return memory.read_u16_le(0x09C2, "WRAM") end,
	},
	['SMZ3']={ -- Super Metroid x A Link to the Past Crossover Randomizer
		func=SMZ3_swap,
		getinvuln=function() return memory.read_u16_le(0x18A8, "WRAM") end,
		-- this value is 0 until i-frames are triggered
		getsamusstate=function() return memory.read_u8(0x0998, "WRAM") end,
		-- this value is the "game state" where the game is fading out after Samus dies.
		-- Tells us Samus hit 0 for real, not due to resets etc.
		getsamushp=function() return memory.read_u8(0x09C2, "WRAM") end,
		getlinkhp=function()
			if memory.read_u8(0x33FE, "CARTRAM") == 0 then
				if (memory.read_u8(0x0010, "WRAM") < 23 and memory.read_u8(0x0010, "WRAM") >5)  then
					return memory.read_u8(0xF36D, "WRAM") -- Link health
				else
					return 0
				end
			else
				return 0
			end
		end,
		maxhp=function() return 160 end,
		getlinklc=function()
			if memory.read_u8(0x33FE, "CARTRAM") == 0 -- LTTP
				and memory.read_u8(0x0010, "WRAM") == 18
				-- this value is the "Link is in a death spiral" value - so it tells us Link hit 0 for real, not due to resets etc.
			then
				return 1
			else
				return 2
			end
		end,
		getwhichgame=function() return memory.read_u8(0x33FE, "CARTRAM") end,
	},
	['Anticipation']={ -- Anticipation NES
		func=antic_swap,
		getbotchedletter=function() return memory.read_u8(0x00C3, "RAM") end,
		getbuzzintime=function() return memory.read_u8(0x007F, "RAM") end,
		gettypetime=function() return memory.read_u8(0x0086, "RAM") end,
		getanswerright=function() return memory.read_u8(0x00A0, "RAM") end,
	},
	['SMK_SNES']={ -- Super Mario Kart
		func=smk_swap,
		p1getbump=function() return memory.read_u8(0x00105E, "WRAM") end, -- if > 0 then p1 is bumping/crashing
		p2getbump=function() return memory.read_u8(0x00115E, "WRAM") end, -- if > 0 then p2 is bumping/crashing
		p1getshrink=function() return memory.read_u16_be(0x001084, "WRAM") end, -- if > 0 then you're small and it's counting down
		p2getshrink=function() return memory.read_u16_be(0x001184, "WRAM") end, -- if > 0 then you're small and it's counting down
		p1getlava=function() return memory.read_u8(0x00010A, "WRAM") end, -- if == 16 then congrats, you're in lava
		p2getlava=function() return memory.read_u8(0x00010C, "WRAM") end, -- if == 16 then congrats, you're in lava
		p1getfall=function() return memory.read_u8(0x0010A0, "WRAM") end, -- if > 2 falling into pit (4), lava (6), deep water (8)
		p2getfall=function() return memory.read_u8(0x0011A0, "WRAM") end, -- if > 2 falling into pit (4), lava (6), deep water (8)
		p1getcoins=function() return memory.read_u8(0x000E00, "WRAM") end,
		p2getcoins=function() return memory.read_u8(0x000E02, "WRAM") end,
		p1getspinout=function() return memory.read_u8(0x0010A6, "WRAM") end, -- 12, 14, 16, and 26 should mean you spin out
		p2getspinout=function() return memory.read_u8(0x0011A6, "WRAM") end, -- 12, 14, 16, and 26 should mean you spin out
		p1getmoled=function() return memory.read_u8(0x001061, "WRAM") end, -- >=152 means a mole jumped on
		p2getmoled=function() return memory.read_u8(0x001161, "WRAM") end, -- >=152 means a mole jumped on
		p1getshrink2=function() return memory.read_u8(0x001030, "WRAM") end, -- if ==128 then you're shrunk
		p2getshrink2=function() return memory.read_u8(0x001130, "WRAM") end, -- if ==128 then you're shrunk
		p2getIsActive=function() return memory.read_u8(0x0011D2, "WRAM") == 2 end, -- if 2, you are in 2p mode
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000154 end,
		p2livesaddr=function() return 0x000156 end,
		maxlives=function() return 4 end,
		ActiveP1=function() return memory.read_u8(0x000154, "WRAM") > 0 and memory.read_u8(0x000154, "WRAM") < 4 end,
		ActiveP2=function() return memory.read_u8(0x000156, "WRAM") > 0 and memory.read_u8(0x000156, "WRAM") < 4 end,
		LivesWhichRAM=function() return "WRAM" end,
	},
	--MARIO BLOCK
	['SMB1_NES']={ -- SMB 1 NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0756, "RAM") + 1 end,
		-- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
		p1getlc=function() return
			memory.read_u8(0x075A, "RAM") % 255
			-- mario if 1p, luigi if 2p, 255 = they game overed
			+ memory.read_u8(0x0761, "RAM") % 255
			-- mario if 2p, 255 = they game overed, stays at 2 if in 1p
		end,
		p2getlc=function() return memory.read_u8(0x0761, "RAM") end,
		maxhp=function() return 2 end,
		gmode=function() return memory.read_u8(0x0770, "RAM") == 1 end,
		-- demo == 0, end of world == 2, game over == 3
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x075A end,
		p2livesaddr=function() return 0x0761 end,
		maxlives=function() return 8 end,
		ActiveP1=function() return memory.read_u8(0x075A, "RAM") > 0 and memory.read_u8(0x075A, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x0761, "RAM") > 0 and memory.read_u8(0x0761, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMB2J_NES']={ -- SMB 2 JP, NES version (Lost Levels)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0756, "RAM") + 1 end,
		-- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
		p1getlc=function() return memory.read_u8(0x075A, "RAM") end,
		maxhp=function() return 2 end,
		gmode=function() return memory.read_u8(0x0770, "RAM") == 1 end,
		-- demo == 0, end of world == 2, game over == 3
		gettogglecheck=function() return memory.read_u8(0x075A) == 255 end,
		-- not in the ending or world 9 where you get 1 life no matter what (so lives are bumped to 255 arbitrarily)
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x075A end,
		maxlives=function() return 8 end,
		p1getlc=function() return memory.read_u8(0x075A, "RAM") end,
		ActiveP1=function() return memory.read_u8(0x075A, "RAM") > 0 and memory.read_u8(0x075A, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMB2_NES']={ -- SMB2 USA NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x04C2, "RAM") end,
		p1getlc=function() return memory.read_u8(0x04ED, "RAM") end,
		maxhp=function() return 63 end,
		gettogglecheck=function() return memory.read_u8(0x04C3, "RAM") end,
		-- this is the number of health bars - if it changes, as in goes back down to normal on slots
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x04ED end,
		maxlives=function() return 70 end,
		ActiveP1=function() return memory.read_u8(0x04ED, "RAM") > 0 and memory.read_u8(0x04ED, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['MB_NES']={ -- Mario Bros. US NES
		func=twoplayers_withlives_swap,
		-- this game only uses lives
		p1gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0048, "RAM") end,
		p2gethp=function() return 0 end,
		p2getlc=function() return memory.read_u8(0x004C, "RAM") end,
		maxhp=function() return 0 end,
	},
	['SOMARI']={ -- Somari (unlicensed) NES
		func=somari_swap,
		getsprite=function() return memory.read_u8(0x0016) end,
		getshield=function() return memory.read_u8(0x001A) == 2 or memory.read_u8(0x001A) == 6 end,
		CanHaveInfiniteLives=true,
		-- consider moving to on_frame version if can identify "dying" sprite
		p1livesaddr=function() return 0x033C end,
		maxlives=function() return 9 end,
		ActiveP1=function() return memory.read_u8(0x033C, "RAM") > 0 and memory.read_u8(0x033C, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMB3_NES']={ -- SMB3 NES
		func=smb3_swap,
		getsmb3battling=function() return memory.read_u8(0x001D, "RAM") == 18 end,
		-- 2p battle true/false
		getinvuln=function() return memory.read_u8(0x0552, "RAM") end,
		-- invuln frames, 0 unless triggered, then counts down by 1 per frame
		getstatue=function() return memory.read_u8(0x057A, "RAM") end,
		-- 0 until you go into tanooki statue form, then counts down by 1 per frame
		getboot=function() return memory.read_u8(0x0577, "RAM") end,
		-- boot flag, 1 means we're in the boot!
		p1getlc=function() return memory.read_u8(0x0736, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0737, "RAM") end,
		gmode=function() return memory.read_u8(0x072B, "RAM") ~= 0 end,
		-- this value == number of players, == 0 on the title screen menu when cutscene is playing.
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0736 end,
		p2livesaddr=function() return 0x0737 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0736, "RAM") > 0 and memory.read_u8(0x0736, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x0737, "RAM") > 0 and memory.read_u8(0x0737, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMW_SNES']={ -- Super Mario World SNES
		func=singleplayer_withlives_swap,
		p1gethp=function()
			if memory.read_u8(0x000071, "WRAM") == 9 then
			-- dying, so we need to use the lives counter
				return 0
			elseif memory.read_u8(0x000019, "WRAM") == 2 or memory.read_u8(0x000019, "WRAM") == 3 then
				return 3 -- fire (3) or cape (2), don't shuffle if you just change powerups
			else
				return memory.read_u8(0x000019, "WRAM") + 1
				-- 1 for big, 0 for small, adding 1 to help with swap on small not relying on life lost
			end
		end,
		p1getlc=function() return memory.read_u8(0x000DBE, "WRAM") end,
		-- active player's lives
		maxhp=function() return 3 end,
		gettogglecheck=function() return memory.read_u8(0x000DB3, "WRAM") end,
		-- which player - if we swap players, then do not shuffle
		gmode=function() return
			memory.read_u8(0x000100, "WRAM") == 11
			-- game mode value for fading to overworld, this is when the lives counter changes on death
			-- the mario/luigi lives count swaps ON the overworld (12-14) so don't count that!
			or (memory.read_u8(0x000100, "WRAM") > 15 and memory.read_u8(0x000100, "WRAM") <= 23)
			-- in a level, for HP checks
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000DBE end,
		maxlives=function() return 68 end,
		LivesWhichRAM=function() return "WRAM" end,
		ActiveP1=function() return memory.read_u8(0x000DBE) > 0 and memory.read_u8(0x000DBE) < 255 end,
	},
	['SMAS_SNES']={ -- Super Mario All Stars (SNES)
		-- to do, function to define "which game"
		-- though I don't think that can go in this block and likely needs to go in the swap function instead
		SMAS_which_game=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 then
				return "SMB1"
			end
			if memory.read_u8(0x01FF00, "WRAM") == 4 then
				return "SMB2J"
			end
			if memory.read_u8(0x01FF00, "WRAM") == 6 and memory.read_u8(0x000547, "WRAM") < 128 then
				return "SMB2U" -- >128 means slots or menu
			end
			if memory.read_u8(0x01FF00, "WRAM") == 10 then
				return "SMW"
			end
			if memory.read_u8(0x01FF00, "WRAM") == 8 then
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					return "SMB3Battle"
				else
					return "SMB3"
				end
			end
			return false
		end,
		func=SMAS_swap,
		gmode=function()
			if ((memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4)
				and memory.read_u8(0x000770, "WRAM") ~= 1) -- demo == 0, end of world == 2, game over == 3 false
			then
				return false
			else
				return true
			end
		end,
		getsmb2mode=function()
			return memory.read_u8(0x0004C4, "WRAM")
			-- number of health bars available, changes on entering slots and can cause false swaps
		end,
		gettogglecheck=function()
			if memory.read_u8(0x01FF00, "WRAM") == 10 then
				return memory.read_u8(0x000DB3, "WRAM")
				-- tells us active character in SMW, so we know if we are switching
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return memory.read_u8(0x000577, "WRAM")
				-- tells us if we have the boot in SMB3, to not swap when we get/lose it
			else
				return nil
			end
		end,
		p1gethp=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in battle mode
					if memory.read_u8(0x001930, "WRAM") == 0 then
						-- actively battling, not in results screen countdown
						return memory.read_u8(0x019AB, "WRAM") + 1
						-- battle health, 0 = small so add 1
					else
						return 0
					end
				elseif memory.read_u8(0x0552, "WRAM") > 0 and memory.read_u8(0x057A, "WRAM") == 0 then
					return 1
				else
					return 2
					-- if invuln frames are activated, not due to tanooki suit statue timer counting down, then drop health from 2 to 1
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return math.ceil(memory.read_u8(0x0004C3)/16)
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				if memory.read_u8(0x0754, "WRAM") == 1 -- small
					and memory.read_u8(0x070B, "WRAM") == 1 -- animating a shrink/grow
				then
					return 1
				else
					return 2
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				if memory.read_u8(0x000071, "WRAM") == 9 then
					-- dying, so we need to use the lives counter
					return 0
				elseif memory.read_u8(0x000019, "WRAM") == 2 or memory.read_u8(0x000019, "WRAM") == 3 then
					return 3 -- fire (3) or cape (2), don't shuffle if you just change powerups
				else
					return memory.read_u8(0x000019, "WRAM") + 1
					-- 1 for big, 0 for small, adding 1 to help with swap on small not relying on life lost
				end
			else
				return 0
			end
		end,
		p2gethp=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in battle mode
					if memory.read_u8(0x001930, "WRAM") == 0 then
						-- actively battling, not in results screen countdown
						return memory.read_u8(0x019AC, "WRAM") + 1
						-- battle health, 0 = small so add 1
					else
						return 0
					end
				elseif memory.read_u8(0x0552, "WRAM") > 0 and memory.read_u8(0x057A, "WRAM") == 0 then
					return 1
				else
					return 2
					-- if invuln frames are activated, and not a tanooki statue, then drop health from 2 to 1
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return 0
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				if memory.read_u8(0x0754, "WRAM") == 1 -- small
					and memory.read_u8(0x070B, "WRAM") == 1 -- animating a shrink/grow
				then
					return 1
				else
					return 2
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				if memory.read_u8(0x000071, "WRAM") == 9 then
					-- dying, so we need to use the lives counter
					return 0
				elseif memory.read_u8(0x000019, "WRAM") == 2 or memory.read_u8(0x000019, "WRAM") == 3 then
					return 3 -- fire (3) or cape (2), don't shuffle if you just change powerups
				else
					return memory.read_u8(0x000019, "WRAM") + 1
					-- 1 for big, 0 for small, adding 1 to help with swap on small not relying on life lost
				end
			else
				return 0
			end
		end,
		maxhp=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				return 3
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return 63
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then
				-- SMB1 or SMB2j
				return 2 -- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				return 3
			else
				return 0
			end
		end,
		p1getlc=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in the battle mode-only game
					return 5 - memory.read_u8(0x0002DB, "WRAM")
					-- luigi's victory count
				elseif memory.read_u8(0x00001D, "WRAM") == 18 then
					return memory.read_u8(0x000736, "WRAM") + 1
					-- we are in 2p battle mode when this == 18.
					-- Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
				else
					return memory.read_u8(0x000736, "WRAM")
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return memory.read_u8(0x0004EE, "WRAM")
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				return memory.read_u8(0x00075A, "WRAM") % 255 -- mario if 1p, luigi if 2p, 255 = they game overed
					+ memory.read_u8(0x000761, "WRAM") % 255 -- mario if 2p, 255 = they game overed, stays at 2 if in 1p
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				return memory.read_u8(0x000DBE, "WRAM") -- active player's lives
			else
				return 0
			end
		end,
		p2getlc=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in the battle mode-only game
					return 5 - memory.read_u8(0x0002DA, "WRAM")
					-- mario's victory count
				elseif memory.read_u8(0x00001D, "WRAM") == 18 then
					return memory.read_u8(0x000736, "WRAM") + 1
					-- we are in 2p battle mode when this == 18.
					-- Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
				else
					return memory.read_u8(0x000737, "WRAM")
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return 0
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				return memory.read_u8(0x00075A, "WRAM") % 255 -- mario if 1p, luigi if 2p, 255 = they game overed
					+ memory.read_u8(0x000761, "WRAM") % 255 -- mario if 2p, 255 = they game overed, stays at 2 if in 1p
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				return memory.read_u8(0x000DBE, "WRAM") -- active player's lives
			else
				return 0
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then
				return 68 -- SMB1, SMB2J
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then
				return 69 -- SMB2U
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return 68 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return 68 -- SMW
			else
				return nil
			end
		end,
		p1livesaddr=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then
				return 0x00075A -- SMB1, SMB2J
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then
				return 0x0004EE -- SMB2U
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return 0x000736 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return 0x000DBE -- SMW
			else
				return nil
			end
		end,
		p2livesaddr=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 then
				return 0x000761 -- SMB1
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return 0x000737 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return 0x000DB5 -- SMW
			else
				return nil
			end
		end,
		ActiveP1=function()
			if (memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4) then
				return memory.read_u8(0x00075A, "WRAM") > 0 and memory.read_u8(0x00075A, "WRAM") < 255 -- SMB1, SMB2J
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then
				return memory.read_u8(0x0004EE, "WRAM") > 0 and memory.read_u8(0x0004EE, "WRAM") < 255 -- SMB2U
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return memory.read_u8(0x000736, "WRAM") > 0 and memory.read_u8(0x000736, "WRAM") < 255 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return memory.read_u8(0x000DB4, "WRAM") > 0 and memory.read_u8(0x000DBE, "WRAM") < 255 -- SMW
			else
				return false
			end
		end,
		ActiveP2=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 then
				return memory.read_u8(0x000761, "WRAM") > 0 and memory.read_u8(0x000761, "WRAM") < 255 -- SMB1
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return memory.read_u8(0x000737, "WRAM") > 0 and memory.read_u8(0x000737, "WRAM") < 255 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return memory.read_u8(0x000DB5, "WRAM") > 0 and memory.read_u8(0x000DB5, "WRAM") < 255 -- SMB3
			else
				return false
			end
		end,
	},
	['SML1_GB']={ -- Super Mario Land, including DX hack for Game Boy Color
		func=sml1_swap,
		getsmlsize=function() return memory.read_u8(0x19, "HRAM") end,
		getlives=function() return
			math.floor(memory.read_u8(0x1A15, "WRAM")/16)*10 +
			(memory.read_u8(0x1A15, "WRAM") % 16)
		end, -- this is actually a hex value that just skips A-F on screen. Transformed.
		getgameover=function() return memory.read_u8(0x00A4, "WRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x1A15 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 106 end,
		ActiveP1=function() return memory.read_u8(0x1A15, "WRAM") > 0 and memory.read_u8(0x033C, "WRAM") < 255 end,
	},
	['SML2_GB']={ -- Super Mario Land 2: 6 Golden Coins, including DX hack for Game Boy Color
		func=singleplayer_withlives_swap,
		p1gethp = function()
			if memory.read_u8(0x0216, "CartRAM") < 4 and memory.read_u8(0x0216, "CartRAM") > 1 then
				-- bunny = 2, fire flower = 3
				return 3
			else
				return memory.read_u8(0x0216, "CartRAM") + 1
				-- 1 is Big Mario/Luigi, 0 is small, 4+ is junk data, adding 1 to help with swap on small not relying on life lost
			end
		end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x022C, "CartRAM")/16)*10 +
			(memory.read_u8(0x022C, "CartRAM") % 16)
		end, -- this is actually a hex value that just skips A-F on screen. Transformed.
		maxhp=function() return 3 end,
		gettogglecheck=function() return memory.read_u8(0x0266, "CartRAM") == 192 end, -- did the "load the map" timer just kick in?
		-- If you died suddenly as >Small Mario, your health will drop to Small Mario. Don't double swap!
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x022C end,
		LivesWhichRAM=function() return "CartRAM" end,
		maxlives=function() return 105 end,
		ActiveP1=function() return memory.read_u8(0x022C, "CartRAM") > 0 and memory.read_u8(0x022C, "CartRAM") < 255 end,
	},
	['SMW2YI_SNES']={ -- Super Mario World 2: Yoshi's Island
		func=iframe_health_swap,
		is_valid_gamestate=function() return
			(memory.read_u16_le(0x0118, "WRAM") >= 15 and memory.read_u16_le(0x0118, "WRAM") <= 20 )
			-- actively in a level or on retry screen
			or (memory.read_u16_le(0x0118, "WRAM") == 48)
			-- in a mini battle
		end,
		get_iframes=function(settings)
			if memory.read_u8(0x0118, "WRAM") == 48 then
			-- in a mini battle
				if memory.read_u8(0x03A7, "WRAM") == 0 or 
					memory.read_u8(0x03A7, "WRAM") == 2 or 
					memory.read_u8(0x03A7, "WRAM") == 4 or 
					memory.read_u8(0x03A7, "WRAM") == 22
				-- throwing balloons (includes 22, for 2p)
				then
					if memory.read_u8(0x1166, "WRAM") == 0 then
					-- WRAM 0x1166 ticks down to 0 while Bandit completes combo to send over
					-- so, if this is ever >0, it's Bandit's mistake and should NOT shuffle
						return memory.read_u8(0x118A, "WRAM")
						-- if wrong answer or out of time (any player)
						-- this jumps up to 32 and counts down to 0 - this is basically iframes!
					end
				end
				if memory.read_u8(0x03A7, "WRAM") == 20 then
				-- 2p watermelon contest
					return memory.read_u8(0x01D6, "CARTRAM") + memory.read_u8(0x1B52, "CARTRAM")
				-- use actual 1p PLUS 2p iframes in 2p watermelon contest
				end
				return memory.read_u8(0x01D6, "CARTRAM")
				-- all other mini battles will use actual 1p iframes ONLY
				-- this applies to 8 gather coins, 10/12 popping balloons, 18 1p watermelon contest
				-- Bandit inherits 2p's iframes in other battles
				-- can we simplify this? 0x1166 never changes in other minigames
			end
			if memory.read_u8(0x00AE, "CARTRAM") == 0x000E then
			-- morphed into Ski Yoshi
				return memory.read_u8(0x0180, "CARTRAM")
				-- this value ticks up to 128 when Ski Yoshi hits an object
				-- and turns over to 0 when Ski Yoshi regains control
				-- don't use it elsewhere, it handles rotation for the helicopter, etc.
			end
			if memory.read_u8(0x00AE, "CARTRAM") > 0 then
			-- morphed into a different non-Yoshi form, including Powerful Mario
				return memory.read_u8(0x01D6, "CARTRAM")
				-- use actual iframes
			end
			return memory.read_u8(0x0CCC, "WRAM") end,
			-- technically this is the recoil timer and not iframes, but otherwise we'd shuffle twice from piranha plants
			-- actual iframes at 0x01D6 CARTRAM
			-- recoil frames at 0x0CCC WRAM
		other_swaps=function()
			-- touching a bandit changes baby state but not recoil or iframes
			-- getting eaten by a piranha plant changes baby state
			-- getting spat out by a piranha plant sets iframes but not recoil
			local baby_status = memory.read_u16_le(0x01B2, "CARTRAM")
			local cutscene_status = memory.read_u8(0x0387, "WRAM") 
			local _, incutscene_curr, incutscene_prev = update_prev("incutscene", cutscene_status == 1)
			-- 1 if in cutscene, 0 if not
			local _, baby_safe_curr, baby_safe_prev = update_prev("baby_safe", baby_status == 0x2000 or baby_status == 0x8000 or incutscene_curr == true)
			-- 0x0000 freefloating, 0x2000 super star, 0x4000 held by bandit/frog/etc, 0x8000 on yoshi's back
			-- if detached due to cutscene, such as goal ring, do not shuffle
			local inpiranha_status = memory.read_u8(0x00AC, "CARTRAM") 
			local _, inpiranha_curr, inpiranha_prev = update_prev("inpiranha", inpiranha_status == 0x001A)
			-- CARTRAM 0x00AC: 0x001A, or inpiranha here, actually corresponds to
			-- "Dying in pit / inside piranha plant / receiving boss key / shrinking during Prince Froggy"
			-- (thanks SMW Central)
			-- SO, if this address turns to 0x001A, shuffle. If it ALREADY is 0x001A, don't shuffle on baby detach!
			if inpiranha_curr and not inpiranha_prev and not incutscene_curr then
				return true
			end
			if not baby_safe_curr and baby_safe_prev and not inpiranha_curr then
				return true
			end
			-- Dying in pit properly shuffles due to lives tracking
			-- Key get properly does NOT shuffle due to incutscene_curr == true
			-- Prince Froggy deals cutscene damage
			-- - note: this is funny
			local squished_changed, squished_curr, squished_prev = update_prev("squished", memory.read_u8(0x00AC, "CARTRAM") == 0x12)
			-- 0x12 when Yoshi has been crushed by a wall, which doesn't trigger iframes
			if squished_changed and squished_curr then
				return true
			end
			local WonAtThrow1p_status = memory.read_u8(0x10F8, "WRAM") 
			-- 0x10F8 goes to 1 if 1p beats CPU at throwing balloons, don't shuffle, that's a win
			local HumanLostMiniBattle_status = memory.read_u8(0x10F4, "WRAM") 
			-- 0x10F4 goes to 1 on mini battle ending, if a human loses outside that scenario
			local _, WonAtThrow1p_curr, WonAtThrow1p_prev = update_prev("WonAtThrow1p", WonAtThrow1p_status == 1)
			local _, HumanLostMiniBattle_curr, HumanLostMiniBattle_prev = update_prev("HumanLostMiniBattle", HumanLostMiniBattle_status == 1)
			if memory.read_u8(0x0118, "WRAM") == 48 
			-- we're in a mini battle, so let's shuffle when a human loses
				and not (memory.read_u8(0x03A7, "WRAM") == 18 or memory.read_u8(0x03A7, "WRAM") == 20)
				--for watermelon contest, iframes for the last hit will suffice, no need to double-swap on iframes + loss
				then
					if HumanLostMiniBattle_curr and not HumanLostMiniBattle_prev and not WonAtThrow1p_curr then
						return true
					end
			end
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000379, "WRAM"))
			return lives_changed and lives_curr < lives_prev
		end,
		-- - bonus game notes, if i ever add shuffling on them
		-- WRAM 0x0212: bonus id
		-- 0 flip cards, 2 scratch and match, 4 drawing lots, 6 match cards, 8 roulette, 10 slot machine
		-- - flip cards
		-- WRAM 0x10F3: contents of latest card (10 = kamek), updated on button press
		-- WRAM 0x10F4: card flip animation, 65528 when done
		-- WRAM 0x1100: item count
		-- 0x10F3 == 10 and 0x10F4 == 65528 and 0x1100 > 0
		-- hit kamek with items in reserve
		-- - roulette
		-- WRAM 0x1179-0x117B: lives won (one byte per digit)
		-- WRAM 0x117F: end flag
		-- 0x1179 == 0, 0x117A == 0, 0x117B == 0, 0x117F == 1
		-- roulette ended with 0 lives
		-- need to disable lives check while in roulette
		-- - throwing balloons
		-- WRAM 0x1154: always 16 after losing?
		-- - dizzy shuffle?
		-- Per SMW Central, $701FE8, 2 bytes, Timer for fuzzy dizzy effect, starts at $400
		-- this would have to be a user option because i feel like it'll suck!
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0379 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		DisableExtraSwaps=function() return (memory.read_u8(0x0118, "WRAM") == 48) end,
	},
	['SM64_N64']={ -- Super Mario 64
		func=singleplayer_withlives_swap,
		p1gethp=function()
			if memory.read_u16_be(0x33B17E, "RDRAM") == 6440 or
				memory.read_u16_be(0x33B17E, "RDRAM") == 6442 or
				memory.read_u16_be(0x33B17E, "RDRAM") == 6444
			then
				-- these RAM values for "mario state" apply when Mario's being thrown out of a painting after death
				-- Mario's health gets set to 1 if he dies from falling/quicksand, not 0,
				-- so there will be two swaps (hp lost + life lost) unless we account for that
				return 0
			else
				return memory.read_u8(0x33B21E, "RDRAM")
			end
		end,
		p1getlc=function() return memory.read_u8(0x33B21D, "RDRAM") end,
		maxhp=function() return 8 end,
		delay=10, -- handles health ticking down from big falls, hits for >1 hp, etc.
		gmode=function() return memory.read_u8(0x33B173, "RDRAM") > 0 end, -- "mario status" variable, 0 if game hasn't started
		gettogglecheck=function() return
			memory.read_u8(0x33B173, "RDRAM") > 0
			-- Mario is in water or haze
			and memory.read_u8(0x33B21F, "RDRAM") >= 252
			-- we just reset the air timer - this should ignore health drops on losing air
			-- (0->FF on losing health, x4 speed in haze, x3 in ice water).
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x33B21D end,
		LivesWhichRAM=function() return "RDRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x33B173, "RDRAM") > 0 end,
	},
	['FZERO_SNES']={ -- F-ZERO, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s16_le(0x00C9, "WRAM") end,
		p1getlc=function() return 1 end,
		-- health function will take care of lives.
		-- health drops to 0 on loading from losing a life (like when you go over a cliff).
		maxhp=function() return 2048 end,
		minhp=-40, -- F-ZERO health value can be negative, who knew...
		delay=30,
		-- because F-ZERO can drain health continuously on every frame,
		-- you want to build in some kind of sane delay before swapping.
		gmode=function() return
			memory.read_u8(0x0054, "WRAM") == 2 -- gamestate = "racing,"
			and memory.read_u8(0x0055, "WRAM") == 3 -- and the race has started
			and memory.read_u8(0x00C8, "WRAM") == 0 -- and invulnerability frames are done (0)
		end,
		gettogglecheck=function() return memory.read_u8(0x0054, "WRAM") end,
		-- if gamestate is being changed, sometimes health drops to 0, so don't swap on that frame

		--FUTURE POSSIBLE REVISION
		--func=fzero_snes_swap,
		--gethittingwall=function() return memory.read_u8(0x00F5, "WRAM") end,
		--getinvuln=function() return memory.read_u8(0x00C8, "WRAM") end,
		--getbump=function() return memory.read_u8(0x00E0, "WRAM") end,
		--delay=30, -- because F-ZERO can drain health continuously on every frame, you want to build in some kind of sane delay before swapping. WILL REQUIRE IMPLEMENTING A COUNTDOWN
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x0059 end,
		maxlives=function() return 8 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV1_NES']={ -- Castlevania I, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0045, "RAM") end,
		p1getlc=function() return memory.read_u8(0x002A, "RAM") end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		MustDoInfiniteLivesOnFrame=function() return false end,
		p1livesaddr=function() return 0x002A end,
		maxlives=function() return 70 end,
		ActiveP1=function() return memory.read_u8(0x0045, "RAM") == 0 or memory.read_u8(0x0045, "RAM") == 64 end,
	},
	['CV2_NES']={ -- Castlevania II, NES
		func=iframe_health_swap,
		is_valid_gamestate=function()
			local gamestate = memory.read_u8(0x0018, "RAM")
			return gamestate >= 5 and gamestate <= 7
			-- 5 main game, 6 one frame on death, 7 game over
		end,
		get_iframes=function() return memory.read_u8(0x04F8, "RAM") end,
		get_health = function() return memory.read_u8(0x0080, "RAM") end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0031, "RAM"))
			-- for some reason, non-game over deaths from enemy damage tick lives down in gamestate 5,
			-- damage game overs tick lives down in gamestate 7, and pit deaths tick lives down in gamestate 6
			-- damage deaths shuffle already, so only shuffle on lives dropping from falling in a pit
			return lives_changed and lives_curr < lives_prev and memory.read_u8(0x0018, "RAM") == 6
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		MustDoInfiniteLivesOnFrame=function() return true end,
		p1livesaddr=function() return 0x0031 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV3_NES']={ -- Castlevania III, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x003C, "RAM") end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x0035, "RAM")/16)*10 +
			(memory.read_u8(0x0035, "RAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
		end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0035 end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV3_FAMI']={ -- Castlevania III, Famicom or NES-JP with English translation patch
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x004A, "RAM") end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x0037, "RAM")/16)*10 +
			(memory.read_u8(0x0037, "RAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
		end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0037 end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV4_SNES']={ -- Super Castlevania IV, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0013F4, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x00007C, "WRAM") end,
		maxhp=function() return 16 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x00007C end,
		maxlives=function() return 106 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['BLOODLINES_GEN']={ -- Castlevania: Bloodlines, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x9C11, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0x9075, "68K RAM") end,
		-- this goes to 1 when death sequence starts, then drops to 0
		maxhp=function() return 80 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		MustDoInfiniteLivesOnFrame=function() return true end,
		p1livesaddr=function() return 0xFB2F end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DRACULAX_SNES']={ -- Dracula X, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u16_le(0x0000A8, "WRAM") end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x00009E, "WRAM")/16)*10 +
			(memory.read_u8(0x00009E, "WRAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
		end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x00009E end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['RONDO_TG16']={ -- Rondo of Blood, TG16 CD
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0098, "Main Memory") end,
		p1getlc=function() return memory.read_u8(0x008D, "Main Memory") end,
		maxhp=function() return 92 end,
		gmode=function() return memory.read_u8(0x029C, "Main Memory") == 1 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "Main Memory" end,
		p1livesaddr=function() return 0x008D end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV_AoS']={ -- Aria of Sorrow, GBA
		-- touching enemy during invincibility from final guard soul, julius backdash etc gives iframes despite not doing damage
		-- dryad seed and succubus grab are weird about iframes
		-- so forget the iframes
		-- dryad and succubus will shuffle you repeatedly but stop on their own over time
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x000010, "EWRAM") == 4 -- in game
				and memory.read_u16_le(0x000E3C, "EWRAM") == 0 -- not paused, so eating rotten food won't swap
				-- there are multiple addresses that seem tied to pausing
				-- and memory.read_u16_le(0x00055C, "EWRAM") ~= 1 -- picking up heart/money gives 1 iframe, don't shuffle there
		end,
		-- get_iframes=function() return memory.read_u16_le(0x00055C, "EWRAM") end,
		get_health=function() return memory.read_u16_le(0x01327A, "EWRAM") end,
		other_swaps=function() return false end,
	},
	['CV_DoS']={ -- Dawn of Sorrow, DS
		-- checking for iframes to not swap on devil soul use etc
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0C07E8, "Main RAM") == 2 end,
		-- hopefully this works for julius/boss rush mode too, bizhawk won't let me import saves for ds games
		get_iframes=function() return memory.read_u8(0x0CA9F3, "Main RAM") end,
		get_health=function() return memory.read_u16_le(0x0F7410, "Main RAM") end,
		other_swaps=function() return false end,
	},
	['CV_PoR']={ -- Portrait of Ruin, DS
		func=jonathan_charlotte_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0F6284, "Main RAM") == 2 end,
		-- hopefully this works for richter/sisters/etc too, bizhawk won't let me import saves for ds games
		is_jonathan=function() return memory.read_u8(0x1120E2, "Main RAM") == 1 end,
		get_jonathan_iframes=function() return memory.read_u8(0x0FCB45, "Main RAM") end,
		get_charlotte_iframes=function() return memory.read_u8(0x0FCCA5, "Main RAM") end,
		get_health=function() return memory.read_u16_le(0x11216C, "Main RAM") end,
	},
	['CV_OoE']={ -- Order of Ecclesia, DS
		-- checking for iframes to not swap on dominus etc (except on death)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x12872A, "Main RAM") == 3 end,
		-- hopefully this works for albus/boss rush mode too, bizhawk won't let me import saves for ds games
		get_iframes=function() return memory.read_u8(0x1098E5, "Main RAM") end,
		get_health=function() return memory.read_u16_le(0x1002B4, "Main RAM") end,
		other_swaps=function() return false end,
	},
	['MetroidNes']={ -- Metroid, NES
		-- bomb jumping sets iframes, so must check health too
		-- but health decreases one frame before iframes are set
		-- so only check health, and instead of iframes, consider lava/metroid states invalid
		-- update zero mission's nes mode if you change this
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x001D, "RAM") == 0 -- in game
				and memory.read_u8(0x001E, "RAM") == 3 -- in game
				and ((memory.read_u8(0x0064, "RAM") == 0 -- not in lava/acid
						and memory.read_u8(0x0092, "RAM") == 0) -- not being drained by a metroid
					or memory.read_u16_le(0x0106, "RAM") == 0) -- 0 hp, want to shuffle on lava/metroid death
		end,
		-- get_iframes=function() return memory.read_u8(0x0070, "RAM") end,
		get_health=function() return memory.read_u16_le(0x0106, "RAM") end,
		-- technically this isn't your *actual* health, it's stored in decimal mode, but for our comparison purposes it works
		other_swaps=function()
			-- shuffle if escape timer runs out
			local time_up_changed, time_up_curr, _ = update_prev('time up', memory.read_u16_le(0x010A, "RAM") == 0xFF00)
			-- set to 0xFFFF when timer is off, counts down in decimal mode from 0x9999 while on, set to 0xFF00 when time runs out
			return time_up_changed and time_up_curr
		end,
	},
	['Metroid2']={ -- Metroid II Return of Samus, GB
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x1B, "HRAM") == 4 end,
		get_iframes=function() return memory.read_u8(0x104F, "WRAM") end,
		get_health=function() return memory.read_u16_le(0x1051, "WRAM") end,
		-- like nes metroid, health is stored in decimal mode
		other_swaps=function() return false end,
		-- no escape sequence this game
	},
	['MetroidFusion']={ -- Metroid Fusion, GBA
		func=iframe_health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x0BDE, "IWRAM") == 1
				-- don't shuffle on omega metroid forced hit
				and not (memory.read_u8(0x002C, "IWRAM") == 0 -- area id: main deck
					and memory.read_u8(0x002D, "IWRAM") == 63 -- room id: omega metroid room
					and memory.read_u16_le(0x1310, "IWRAM") == 1 -- hp: omega metroid forced hit takes hp to 1
					and memory.read_u8(0x1249, "IWRAM") == 48) -- iframes: you should still shuffle from time up while at 1 hp
		end,
		get_iframes=function() return memory.read_u8(0x1249, "IWRAM") end,
		get_health=function() return memory.read_u16_le(0x1310, "IWRAM") end,
		iframe_minimum=function() return 10 end,
		-- SRX amoebas, TRO leech boss, TRO plant boss flowers, electric water
		-- all do damage with short iframes rather than skipping iframes entirely like lava/heat
		other_swaps=function()
			-- check if we ran out of time (sector 3, secret lab, ending)
			local time_up_changed, time_up_curr, _ = update_prev('time up', memory.read_u8(0x08D7, "IWRAM") == 2)
			-- 0: no timer, 1: timer on, 2: timer just ran out
			return time_up_changed and time_up_curr, 65
			-- add extra delay so you get the whiteout animation before shuffling
		end,
	},
	['MetroidZero']={ -- Metroid Zero Mission, GBA
		func=iframe_health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x0C70, "IWRAM") == 4 -- main game
				or memory.read_u8(0x0C70, "IWRAM") == 7 -- nes metroid
		end,
		get_iframes=function()
			if memory.read_u8(0x0C70, "IWRAM") == 7 then -- nes metroid
				return 0 -- don't use the main shuffle function in nes metroid
			end
			return memory.read_u8(0x13DA, "IWRAM")
		end,
		get_health=function()
			if memory.read_u8(0x0C70, "IWRAM") == 7 then -- nes metroid
				return 1 -- don't use the main shuffle function in nes metroid
			end
			return memory.read_u16_le(0x1536, "IWRAM")
		end,
		iframe_minimum=function() return 16 end,
		-- hp-draining purple bugs do 15 iframes, metroids do 3
		other_swaps=function()
			-- check if we ran out of time (mother brain, mecha-ridley)
			local time_up_changed, time_up_curr, _ = update_prev('time up', memory.read_u8(0x095C, "IWRAM") == 2)
			-- 0: no timer, 1: timer on, 2: timer just ran out
			if time_up_changed and time_up_curr then
				return true, 65
				-- add extra delay so you get the whiteout animation before shuffling
			end
			-- nes metroid shuffle, ram offsets are +0x7200 from nes version
			-- update nes metroid section if you change this
			--local nes_health_changed, nes_health_curr, nes_health_prev
			--local nes_time_up_changed, nes_time_up_curr
			if memory.read_u8(0x0C70, "IWRAM") == 7 then
				local nes_health_changed, nes_health_curr, nes_health_prev = update_prev('nes health', memory.read_u16_le(0x7306, "IWRAM"))
				local nes_time_up_changed, nes_time_up_curr, _ = update_prev('nes time up', memory.read_u16_le(0x730A, "IWRAM") == 0xFF00)
				return memory.read_u8(0x721D, "IWRAM") == 0 -- in game
					and memory.read_u8(0x721E, "IWRAM") == 3 -- in game
					and ((memory.read_u8(0x7264, "IWRAM") == 0 -- not in lava/acid
							and memory.read_u8(0x7292, "IWRAM") == 0) -- not being drained by a metroid
						or memory.read_u16_le(0x7306, "IWRAM") == 0) -- 0 hp, want to shuffle on lava/metroid death
					and ((nes_health_changed and nes_health_curr < nes_health_prev) -- hp dropped
						or (nes_time_up_changed and nes_time_up_curr)) -- escape timer ran out
			end
			return false
		end,
	},
	['Zelda_1']={ -- The Legend of Zelda, NES
		func=iframe_health_swap,
		is_valid_gamestate=function()
			local gamestate = memory.read_u8(0x0012, "RAM")
			return gamestate == 5 or gamestate == 9 or gamestate == 17
			-- 5: main game, 9: side-scrolling, 17: dying (set same frame as health reaching 0)
		end,
		get_iframes=function() return memory.read_u8(0x04F0, "RAM") end,
		get_health=function()
			local fullHearts = bit.band(memory.read_u8(0x066F, "RAM"), 0x0F)
			-- other half of this byte tracks max health
			local partialHeart = memory.read_u8(0x0670, "RAM")
			return fullHearts * 0x100 + partialHeart
		end,
		other_swaps=function() return false end,
	},
	['Zelda_2']={ -- Zelda II The Adventure of Link, NES
		func=iframe_health_swap,
		is_valid_gamestate=function()
			local gamestate = memory.read_u8(0x0736, "RAM")
			return gamestate == 11 -- main game
				or gamestate == 4 -- lives reduced after death
		end,
		get_iframes=function() return memory.read_u8(0x050C, "RAM") end,
		get_health=function() return memory.read_u8(0x0774, "RAM") end,
		other_swaps=function()
			-- we shuffle on death from enemies bringing us to 0 health,
			-- but we need to shuffle on dying from pits too
			-- while zelda 2 has two addresses storing health values,
			-- one of which resets when lives decrease and the other when link respawns,
			-- zelda 2 redux removes the second one of these, so we must track what the value was last frame
			local lives_changed, lives_curr, lives_prev = update_prev('lives', memory.read_u8(0x0700, "RAM"))
			local _, _, health_prev = update_prev('health 2', memory.read_u8(0x0774, "RAM"))
			return lives_changed and lives_curr < lives_prev -- we have died
				and health_prev ~= 0 -- died from instant death
		end,
	},
	['Zelda_LA']={ -- Link's Awakening (DX), GB/GBC
		-- instead of damage directly lowering health, it's put into a "damage buffer" that then lowers health per frame
		-- we can't rely on iframes alone, since walking into deep water without flippers sets iframes but does no damage
		-- so check that iframes are set and damage buffer increased
		func=damage_buffer_swap,
		is_valid_gamestate=function() return memory.read_u8(0x1B95, "WRAM") == 11 end,
		get_iframes=function() return memory.read_u8(0x1BC7, "WRAM") end,
		-- get_health=function() return memory.read_u8(0x1B5A, "WRAM") end,
		get_damage_buffer=function() return memory.read_u8(0x1B94, "WRAM") end,
		other_swaps=function() return false end,
	},
	['Zelda_Ocarina_10']={ -- Ocarina of Time, N64 (1.0)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11B927, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11A5FE, "RDRAM") end,
		-- get_iframes=function() return memory.read_u8(0x1DB498, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11A600, "RDRAM") end,
		-- is_link_grabbed=function() return bit.band(memory.read_u8(0x1DB0A3, "RDRAM"), 0x80) == 0x80 end,
		-- get_respawn_flag=function() return memory.read_u8(0x11B937, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D8870, "RDRAM") end,
	},
	['Zelda_Ocarina_11']={ -- Ocarina of Time, N64 (1.1)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11BAE7, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11A7BE, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11A7C0, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D8A30, "RDRAM") end,
	},
	['Zelda_Ocarina_12']={ -- Ocarina of Time, N64 (1.2)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11BFD7, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11ACAE, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11ACB0, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D9130, "RDRAM") end,
	},
	['Zelda_Ocarina_GC']={ -- Ocarina of Time, N64 (GameCube version)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11C49F, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11B176, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11B178, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D9A30, "RDRAM") end,
	},
	['Zelda_Ocarina_MQ']={ -- Ocarina of Time, N64 (Master Quest GameCube version)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11C47F, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11B156, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11B158, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D99F0, "RDRAM") end,
	},
	['Zelda_Seasons']={ -- Oracle of Seasons, GBC
		-- iframes are set one frame before health is decreased if hit by enemy
		-- HOWEVER, iframes are set the same frame health decreases if you fall in a hole
		-- and drowning sets iframes at start of drowning animation, but decreases health on respawn
		-- iframes are also set during various cutscenes for some reason
		-- so i guess we just hope there's no damage over time effects?
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x02EE, "WRAM") == 2 -- main game
				and not (memory.read_u8(0x0C3A, "WRAM") == 1 -- maple present
					and memory.read_u8(0x0BEA, "WRAM") ~= 0) -- just bumped into maple
			-- don't want to shuffle on link's hearts being added to maple prize pool
		end,
		-- get_iframes=function() return memory.read_u8(0x102B, "WRAM") end,
		get_health=function() return memory.read_u8(0x06A2, "WRAM") end,
		other_swaps=function()
			local room_bank = memory.read_u8(0x0C49, "WRAM")
			local room_id = memory.read_u8(0x0C4C, "WRAM")
			-- shuffle on using revive potion
			local potion_curr = bit.band(memory.read_u8(0x0697, "WRAM"), 0x80) == 0x80
			local potion_changed, _, _ = update_prev('potion', potion_curr)
			if potion_changed and not potion_curr then
				return true
			end
			-- shuffle on dancing game failure because i think it's funny
			local lost_dance_changed, lost_dance_curr, _ = update_prev('lost dance', memory.read_u8(0x0FD0, "WRAM") == 0xFF)
			-- this address is used for different things depending on room, so check current room
			if room_bank == 3 and room_id == 0x95 -- in dance hall
				and lost_dance_changed and lost_dance_curr
			then
				return true, 70 -- enough time for the failure text to appear on max text speed
			end
			-- would like to shuffle on stealth segment failure but it's harder to detect than in Ages
			-- rosa after dungeon 1, brothers before dungeon 4
			-- rosa: 0x0308 == 0x26, 0x0309 == 1 (id of failure text)
			-- these addresses are in a general buffer area, cannot guarantee they won't be set in other contexts
			-- can't just check current room like for minigames since enemies or maple also show up in these rooms
			-- and may set these when not in stealth segment
			return false
		end,
	},
	['Zelda_Ages']={ -- Oracle of Ages, GBC
		-- same iframe weirdness as Seasons
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x02EE, "WRAM") == 2 -- main game
				and not (memory.read_u8(0x0DDA, "WRAM") == 1 -- maple present
					and memory.read_u8(0x0BE9, "WRAM") ~= 0) -- just bumped into maple
			-- don't want to shuffle on link's hearts being added to maple prize pool
		end,
		-- get_iframes=function() return memory.read_u8(0x102B, "WRAM") end,
		get_health=function() return memory.read_u8(0x06AA, "WRAM") end,
		other_swaps=function()
			local room_bank = memory.read_u8(0x0C2D, "WRAM")
			local room_id = memory.read_u8(0x0C30, "WRAM")
			-- shuffle on using revive potion
			local potion_curr = bit.band(memory.read_u8(0x069F, "WRAM"), 0x80) == 0x80
			local potion_changed, _, _ = update_prev('potion', potion_curr)
			if potion_changed and not potion_curr
				and not (room_bank == 5 and room_id == 0xAD) -- king zora's throne room
				-- don't shuffle on giving potion to king zora
			then
				return true
			end
			-- got caught in ambi's palace stealth section
			if room_bank == 1 and room_id == 0x46 then -- outside ambi's palace
				local caught_curr = memory.read_u8(0x1004, "WRAM") == 15 -- link state, 15 when kicked out of palace
				-- i can't guarantee this link state is only used here, so that's why we check the room for safety
				local caught_changed, _, _ = update_prev('caught', caught_curr)
				return caught_changed and caught_curr
			end
			-- MINIGAME BLOCK
			-- what does and doesn't count for minigames is admittedly somewhat arbitrary
			-- general premise is that "score attack" games don't shuffle from just getting a low score,
			-- pass/fail games shuffle on failure, and games with "miss" states shuffle per miss
			if room_bank == 3 and room_id == 0x3E then -- big bang game room
				-- big bang game loss
				local bb_ended_curr = memory.read_u8(0x0DDB, "WRAM") == 0x80
				local bb_ended_changed, _, _ = update_prev('big bang', bb_ended_curr)
				local bb_won = memory.read_u8(0x0FC0, "WRAM") == 1
				return bb_ended_changed and bb_ended_curr and not bb_won, 80
			elseif room_bank == 2 and (room_id == 0xED or room_id == 0xEF) then -- goron dance present and past respectively
				-- goron dance miss
				local dance_changed, dance_curr, _ = update_prev('goron dance', memory.read_u8(0x0FD9, "WRAM") == 1)
				return dance_changed and dance_curr
			elseif room_bank == 5 and room_id == 0xE8 then -- patch's basement
				-- patch's crazy cart loss
				local patch_changed, patch_curr, _ = update_prev('patch', memory.read_u8(0x0FD5, "WRAM") == 1)
				return patch_changed and patch_curr, 120 -- fade to white before shuffle
			elseif (room_bank == 2 and room_id == 0xE9) -- lynna shooting gallery
				or (room_bank == 3 and room_id == 0xE7) -- goron shooting gallery
			then
				-- shooting gallery ball missed
				local round_end_curr = bit.band(memory.read_u8(0x0CD6, "WRAM"), 0x80) == 0x80
				local round_end_changed, _, _ = update_prev('round ended', round_end_curr)
				local strike = memory.read_u8(0x0FD6, "WRAM") == 1
				return round_end_changed and round_end_curr and strike, 60 -- let strike text show up before shuffle
			elseif room_bank == 2 and room_id == 0xDE then -- wild tokay room
				-- wild tokay loss
				local tokay_changed, tokay_curr, _ = update_prev('tokay', memory.read_u8(0x0FDE, "WRAM") == 0xFF)
				return tokay_changed and tokay_curr
			end
			return false
		end,
	},
	['MPAINT_DPAD_SNES']={ -- Gnat Attack in Mario Paint for SNES
		-- (I tested this with a version that can use the dpad for movement and face buttons for clicks)
		func=singleplayer_withlives_swap,
		p1gethp=function() return 0 end, -- we will always rely on lives, unless I need to do a sprite thing.
		p1getlc=function() return memory.read_u8(0x010018, "WRAM") end, -- hands remaining
		maxhp=function() return 6 end,
		gmode=function() return memory.read_u8(0x000206, "WRAM") == 0 end, -- 1 for painting, 0 for Gnat Attack
		CanHaveInfiniteLives=true, -- MAYBE THIS SHOULD BE AN OPTION
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x010018 end,
		maxlives=function() return 6 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['KIRBY_NES']={ -- Kirby's Adventure, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return (math.ceil((memory.read_u8(0x0597, "RAM")) % 255/8)) end,
		-- aside from 255 == death, HP is like Battletoads (7, 15, 23 ... 47)
		p1getlc=function() return memory.read_u8(0x0599, "RAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0599 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DemonsCrest']={ -- Demon's Crest (SNES)
		func=demonscrest_swap,
		p1gethp=function() return memory.read_u8(0x1062, "WRAM") end,
		p1getliving=function() return memory.read_u8(0x00E7, "WRAM") end,
		p1getscene=function() return memory.read_u8(0x01FFFC, "WRAM") end, -- value changes on scene changes
		CanHaveInfiniteLives=false -- you always have infinite lives in Demon's Crest, so "enabling" them does not apply
	},
	['FamilyFeud_SNES']={ -- Family Feud (SNES)
		func=FamilyFeud_SNES_swap,
		getstrike=function() return memory.read_u8(0x020E, "WRAM") end,
		getwhichplayer=function() return memory.read_u8(0x08DF, "WRAM") end,
		CanHaveInfiniteLives=false
	},
	['Monopoly_NES']={ -- Monopoly (NES)
		func=Monopoly_NES_swap,
		delay=120, -- higher than normal to help player process reason for swap!
		getInEditor=function() return memory.read_u8(0x0067, "RAM") end,
		-- if 1, we are editing the game before starting, so don't swap when money values change
		
		-- literally grabbing all the properties to know if they are owned/mortgaged/built up or not...
		-- I am sure there is a better, mathematical way to do this
		getSpace01=function() return memory.read_u8(0x039E, "RAM") end, -- Mediterranean Ave
		getSpace03=function() return memory.read_u8(0x03A0, "RAM") end, -- Baltic Ave
		getSpace05=function() return memory.read_u8(0x03A2, "RAM") end, -- Reading RR
		getSpace06=function() return memory.read_u8(0x03A3, "RAM") end, -- Oriental Ave
		getSpace08=function() return memory.read_u8(0x03A5, "RAM") end, -- Vermont Ave
		getSpace09=function() return memory.read_u8(0x03A6, "RAM") end, -- Connecticut Ave
		getSpace11=function() return memory.read_u8(0x03A8, "RAM") end, -- St. Charles Pl
		getSpace12=function() return memory.read_u8(0x03A9, "RAM") end, -- Electric Co
		getSpace13=function() return memory.read_u8(0x03AA, "RAM") end, -- States Ave
		getSpace14=function() return memory.read_u8(0x03AB, "RAM") end, -- Virginia Ave
		getSpace15=function() return memory.read_u8(0x03AC, "RAM") end, -- Pennsylvania RR
		getSpace16=function() return memory.read_u8(0x03AD, "RAM") end, -- St. James Pl
		getSpace18=function() return memory.read_u8(0x03AF, "RAM") end, -- Tennessee Ave
		getSpace19=function() return memory.read_u8(0x03B0, "RAM") end, -- New York Ave
		getSpace21=function() return memory.read_u8(0x03B2, "RAM") end, -- Kentucky Ave
		getSpace23=function() return memory.read_u8(0x03B4, "RAM") end, -- Indiana Ave
		getSpace24=function() return memory.read_u8(0x03B5, "RAM") end, -- Illinois Ave
		getSpace25=function() return memory.read_u8(0x03B6, "RAM") end, -- B&O RR
		getSpace26=function() return memory.read_u8(0x03B7, "RAM") end, -- Atlantic Ave
		getSpace27=function() return memory.read_u8(0x03B8, "RAM") end, -- Ventnor Ave
		getSpace28=function() return memory.read_u8(0x03B9, "RAM") end, -- Water Works
		getSpace29=function() return memory.read_u8(0x03BA, "RAM") end, -- Marvin Gardens
		getSpace31=function() return memory.read_u8(0x03BC, "RAM") end, -- Pacific Ave
		getSpace32=function() return memory.read_u8(0x03BD, "RAM") end, -- North Carolina Ave
		getSpace34=function() return memory.read_u8(0x03BF, "RAM") end, -- Pennsylvania Ave
		getSpace35=function() return memory.read_u8(0x03C0, "RAM") end, -- Short Line
		getSpace37=function() return memory.read_u8(0x03C2, "RAM") end, -- Park Place
		getSpace39=function() return memory.read_u8(0x03C4, "RAM") end, -- Boardwalk
		
		--DON'T SWAP ON ANY OF THESE
		--DEPRECATED
		--getUnowned=function() return memory.read_u8(0x005A, "RAM") end, -- if 21, player has rolled onto an unowned property.
		--getAuctioning=function() return memory.read_u8(0x04D2, "RAM") end, -- if 2, an auction is in progress.
		--getTradeAccepted=function() return memory.read_u8(0x0576, "RAM") + memory.read_u8(0x0577, "RAM") end, -- if 1 and 1, both have accepted the deal
		--getBuildingTimer=function() return memory.read_u8(0x0593, "RAM") end, -- if 1, someone bought houses/hotels and the building scene is about to happen
		
		-- PLAYER CASH TOTALS
		getp1Money=function() return memory.read_u8(0x03C5, "RAM")*10000 + memory.read_u8(0x03C6, "RAM")*1000 + memory.read_u8(0x03C7, "RAM")*100 + memory.read_u8(0x03C8, "RAM")*10 + memory.read_u8(0x03C9, "RAM") end,
		getp2Money=function() return memory.read_u8(0x03CA, "RAM")*10000 + memory.read_u8(0x03CB, "RAM")*1000 + memory.read_u8(0x03CC, "RAM")*100 + memory.read_u8(0x03CD, "RAM")*10 + memory.read_u8(0x03CE, "RAM") end,
		getp3Money=function() return memory.read_u8(0x03CF, "RAM")*10000 + memory.read_u8(0x03D0, "RAM")*1000 + memory.read_u8(0x03D1, "RAM")*100 + memory.read_u8(0x03D2, "RAM")*10 + memory.read_u8(0x03D3, "RAM") end,
		getp4Money=function() return memory.read_u8(0x03D4, "RAM")*10000 + memory.read_u8(0x03D5, "RAM")*1000 + memory.read_u8(0x03D6, "RAM")*100 + memory.read_u8(0x03D7, "RAM")*10 + memory.read_u8(0x03D8, "RAM") end,
		getp5Money=function() return memory.read_u8(0x03D9, "RAM")*10000 + memory.read_u8(0x03DA, "RAM")*1000 + memory.read_u8(0x03DB, "RAM")*100 + memory.read_u8(0x03DC, "RAM")*10 + memory.read_u8(0x03DD, "RAM") end,
		getp6Money=function() return memory.read_u8(0x03DE, "RAM")*10000 + memory.read_u8(0x03DF, "RAM")*1000 + memory.read_u8(0x03E0, "RAM")*100 + memory.read_u8(0x03E1, "RAM")*10 + memory.read_u8(0x03E2, "RAM") end,
		getp7Money=function() return memory.read_u8(0x03E3, "RAM")*10000 + memory.read_u8(0x03E4, "RAM")*1000 + memory.read_u8(0x03E5, "RAM")*100 + memory.read_u8(0x03E6, "RAM")*10 + memory.read_u8(0x03E7, "RAM") end,
		getp8Money=function() return memory.read_u8(0x03E8, "RAM")*10000 + memory.read_u8(0x03E9, "RAM")*1000 + memory.read_u8(0x03EA, "RAM")*100 + memory.read_u8(0x03EB, "RAM")*10 + memory.read_u8(0x03EC, "RAM") end,
		
		-- IS PLAYER HUMAN
		getp1Human=function() return memory.read_u8(0x033C, "RAM") end,
		getp2Human=function() return memory.read_u8(0x033D, "RAM") end,
		getp3Human=function() return memory.read_u8(0x033E, "RAM") end,
		getp4Human=function() return memory.read_u8(0x033F, "RAM") end,
		getp5Human=function() return memory.read_u8(0x0340, "RAM") end,
		getp6Human=function() return memory.read_u8(0x0341, "RAM") end,
		getp7Human=function() return memory.read_u8(0x0342, "RAM") end,
		getp8Human=function() return memory.read_u8(0x0343, "RAM") end,
		
		-- IS PLAYER IN JAIL - this goes up 1, 2, 3 for # turns in jail, 0 if you're out
		getp1InJail=function() return memory.read_u8(0x042C, "RAM") end,
		getp2InJail=function() return memory.read_u8(0x042D, "RAM") end,
		getp3InJail=function() return memory.read_u8(0x042E, "RAM") end,
		getp4InJail=function() return memory.read_u8(0x042F, "RAM") end,
		getp5InJail=function() return memory.read_u8(0x0430, "RAM") end,
		getp6InJail=function() return memory.read_u8(0x0431, "RAM") end,
		getp7InJail=function() return memory.read_u8(0x0432, "RAM") end,
		getp8InJail=function() return memory.read_u8(0x0433, "RAM") end,
		
		-- IS PLAYER BANKRUPT - 255 means player is out of the game, if it wasn't 255 to start with, they just went bankrupt
		getp1Bankrupt=function() return memory.read_u8(0x032C, "RAM") end,
		getp2Bankrupt=function() return memory.read_u8(0x032D, "RAM") end,
		getp3Bankrupt=function() return memory.read_u8(0x032E, "RAM") end,
		getp4Bankrupt=function() return memory.read_u8(0x032F, "RAM") end,
		getp5Bankrupt=function() return memory.read_u8(0x0330, "RAM") end,
		getp6Bankrupt=function() return memory.read_u8(0x0331, "RAM") end,
		getp7Bankrupt=function() return memory.read_u8(0x0332, "RAM") end,
		getp8Bankrupt=function() return memory.read_u8(0x0333, "RAM") end,
		
		CanHaveInfiniteLives=false
	},
	['BUBSY1_SNES']={ -- Bubsy in Claws Encounters of the Furred Kind, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 0 end ,
		p1getlc=function() return
			math.floor(memory.read_u8(0x020D, "WRAM")/16)*10 +
			(memory.read_u8(0x020D, "WRAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
			end,
		maxhp=function() return 69 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x020D end,
		maxlives=function() return 104 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['LAST_ALERT_TGCD']={ -- Last Alert, TG-CD
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x040A, "Main Memory") end,
		maxhp=function() return memory.read_u8(0x040B, "Main Memory") + 5 end, -- Technically player's rank + 5
		p1getlc=function()
			if memory.read_u8(0x0E8C, "Main Memory") > 0 -- Counts up as the screen fades out
				and memory.read_u8(0x040A, "Main Memory") == 0 -- but that's for ANY fade, so ensure it's for HP = 0
			then
				return 2
			else
				return 1
			end
		end,
	},
	['PEBBLE_BEACH_GOLF_LINKS_SAT']={ -- Pebble Beach Golf Links, Sega Saturn
		func=Pebble_Beach_Golf_Links_swap,
		getCurrentPlayer = function() return saturn_fix_string_endianness(memory.read_bytes_as_array(0x03BA3C, 10, "Work Ram High")) end,
		getPlayer1 = function() return saturn_fix_string_endianness(memory.read_bytes_as_array(0x03ABA4, 10, "Work Ram High")) end,
		getPlayer1Scores = function() return memory.read_bytes_as_array(0x03ABFA, 18, "Work Ram High") end,
		getHole = function() return memory.read_u8(0x00C002, "Work Ram Low") end,
		getGameMode = function() return memory.read_u16_be(0x00A988, "Work Ram Low") end,
		gmode = function() return memory.read_u16_be(0x00A988, "Work Ram Low") == 262 end,
		delay = 20,
	},
	['NBA_JAM_PS1']= { -- NBA Jam Tournament Edition, PS1
		func=NBA_Jam_swap,
		getOpposingTeamScore = function() return memory.read_s32_le(0x07D09C, "MainRAM") end,
		getTeamWithBall = function() return memory.read_s32_le(0x07D038, "MainRAM") end,
		getShotClock = function() return memory.read_s32_le(0x07D034, "MainRAM") end,
		getShotClockViolationMessageTimer = function() return memory.read_u16_le(0x7D012, "MainRAM") end,
		getQuarter = function() return memory.read_u16_le(0x07CF88, "MainRAM") end,
		delay = 120,
		gmode=function() return memory.read_u16_le(0x086560, "MainRAM") == 25932 end, -- This absolutely isn't the actual game mode variable, but it's consistently this value during a match, so, close enough for government work
	},
	['EINHANDER_PS1']={ -- Einhänder, PS1
		func=singleplayer_withlives_swap,
		p1gethp = function() return 0 end,
		maxhp = function() return 0 end,
		p1getlc = function() return memory.read_u8(0x0813C4, "MainRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x0813C4 end,
		LivesWhichRAM = function() return "MainRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
		delay = 45,
	},
	['ROCKET_KNIGHT_ADVENTURES_GEN']={ -- Rocket Knight Adventures, Genesis
		func=Rocket_Knight_Adventures_swap,
		p1gethp=function() return memory.read_s16_be(0xC040, "68K RAM") end,
		maxhp=function() return 32767 end, -- Realistically this won't be above 63, but the game handles this value *somewhat* gracefully
		p1getlc = function()
			-- This is stored in decimal mode, meaning 0x69 is treated as 69 and
			-- not 105, so we need to convert it to a standard integer first so
			-- the "lives went down by 1" check passes gracefully
			local currLivesAsHex = memory.read_s16_be(0xFB0C, "68K RAM");
			local currLivesAsDecimal = (((currLivesAsHex & 0xF0) >> 4) * 10) + (currLivesAsHex & 0x0F);
			-- But also! You can keep playing at 0 lives! It's only when you DIE
			-- at 0 lives that a Game Over is executed. Fortunately, a specific
			-- memory address is set to a specific value when this happens, so
			-- check for it and treat it as -1 lives
			local gameOver = (memory.read_s16_be(0xB02C, "68K RAM") == 3);
			if (currLivesAsDecimal == 0 and gameOver) then
				return -1;
			else
				-- Otherwise, use the converted value for our purposes
				return currLivesAsDecimal;
			end
		end,
		-- Below: 0xC000 appears to be 1 during gameplay/0 during not-gameplay;
		-- at any rate, changes to 0 when life's set to 0 between cutscenes and
		-- stages, then changes back when life isn't 0 anymore.

		-- 0xB02C, meanwhile, is set to various values during fadeouts - 3 is
		-- the value for the continue/game over screen, and is basically the
		-- only way I can find to detect that the player's run out of lives,
		-- since 0 is a valid life value and it never goes negative (unlike HP).
		gmode = function()
			return memory.read_s16_be(0xC000, "68K RAM") == 1
				and memory.read_s16_be(0xB02C, "68K RAM") ~= 3
			end,
		-- Life Bonus, ticks down alongside health during stage clear screen
		gettogglecheck = function() return memory.read_u32_be(0xB174, "68K RAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0xFB0D end,
		LivesWhichRAM = function() return "68K RAM" end,
		maxlives = function() return 0x99 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_NA_V10_N64']={ -- Banjo-Kazooie, North America v1.0, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x385F83, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x385F87, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x385F87, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x385F8B, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x385F8B end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_NA_V11_N64']={ -- Banjo-Kazooie, North America v1.1, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x3851A3, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x3851A7, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x3851A7, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x3851AB, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x3851AB end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_EUR_N64']={ -- Banjo-Kazooie, Europe, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x386963, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x386967, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x386967, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x38696B, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x38696B end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_JPN_N64']={ -- Banjo to Kazooie no Daibouken, Japan, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x386AC3, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x386AC7, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x386AC7, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x386ACB, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x386ACB end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['SNAKE_RATTLE_N_ROLL_NES']={ -- Snake Rattle 'N' Roll, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x61, "RAM") + 1 end, -- offset because 0 is a valid health value and we still need to change on hitting it
		maxhp=function() return 17 end, -- I don't actually know the maximum length of the snake. I thought it was 4, but then it was 5. Seems to vary per level.
		gettogglecheck=function() return (
			memory.read_u8(0x48D, "RAM") -- this constantly increases during level exit
			| (math.max(memory.read_u8(0x409, "RAM")-1,0) << 8) -- this shoots up when stomped and decreases until death is logged. Offset down by 0 so the lives check still triggers.
		) end, -- bitwise OR them together in separate bytes, if either changes it'll be noted
		p1getlc=function() return memory.read_u8(0x3DF, "RAM") end,
		gmode=function() -- multiple values to accommodate the death animation
			return memory.read_u8(0xC, "RAM") == 0x04 -- normal gameplay
				or memory.read_u8(0xC, "RAM") == 0x48 -- one of the death states
				or memory.read_u8(0xC, "RAM") == 0xAF -- the other death state
				or memory.read_u8(0xC, "RAM") == 0xF8 -- set after death or level exit
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x3DF end,
		LivesWhichRAM = function() return "RAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['ROCK_N_ROLL_RACING_SNES']={ -- Rock n' Roll Racing, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0xEDF, "WRAM") end,
		maxhp=function() return 12 end,
		p1getlc=function()
			if memory.read_u8(0xEDF) == 0 then
				return 2
			else
				return 1
			end
		end,
		-- Below: lap counter. Goes up the same time health goes up for the
		-- first time, preventing a bogus shuffle. DOES mean getting hit the
		-- instant you finish a lap won't trigger a shuffle, though...
		gettogglecheck=function() return memory.read_u8(0xEF1, "WRAM") end,
	},
	['240P_NES']={
		func=StopWatch_swap,
		gmode=function() return memory.read_u8(0x01FB, "RAM") == 136 end, -- 136 is the stopwatch mode
	},
	['SOTN_PS1']={ -- Japan (1.0, 1.1) and North America releases
		func=sotn_swap,
		get_health=function() return memory.read_u32_le(0x97BA0, "MainRAM") end,
		max_health=function() return memory.read_u32_le(0x97BA4, "MainRAM") end,
		get_iframes=function() return memory.read_u16_le(0x72F1C, "MainRAM") end,
		get_player_state=function() return memory.read_u16_le(0x73404, "MainRAM") end,
		stone_state=11,
		game_over_check=function()
			gamestate = memory.read_u32_le(0x3C734, "MainRAM")
			if gamestate == 3 and memory.read_u32_le(0x73060, "MainRAM") == 5 then -- Screen melt starting
				return true -- Game Over
			else
				return false -- Gameplay
			end
		end,
		is_valid_gamestate=function()
			gamestate = memory.read_u32_le(0x3C734, "MainRAM")
			return gamestate == 2 -- Gameplay
				or gamestate == 3 -- Game Over
		end,
	},
	['SOTN_PS1_2']={ -- Japan (1.2), Europe and Asia releases
		func=sotn_swap,
		get_health=function() return memory.read_u32_le(0x97BB0, "MainRAM") end,
		max_health=function() return memory.read_u32_le(0x97BB4, "MainRAM") end,
		get_iframes=function() return memory.read_u16_le(0x72F24, "MainRAM") end,
		get_player_state=function() return memory.read_u16_le(0x7340C, "MainRAM") end,
		stone_state=11,
		game_over_check=function()
			gamestate = memory.read_u32_le(0x3C73C, "MainRAM")
			if gamestate == 3 and memory.read_u32_le(0x73068, "MainRAM") == 0 then -- Screen melt starting
				return true -- Game Over
			else
				return false -- Gameplay
			end
		end,
		is_valid_gamestate=function()
			gamestate = memory.read_u32_le(0x3C73C, "MainRAM")
			return gamestate == 2 -- Gameplay
				or gamestate == 3 -- Game Over
		end,
	},
	['SOTN_SATURN']={ -- Akumajou Dracula X: Gekka no Yasoukyoku (Saturn)
		func=sotn_swap,
		get_health=function() return memory.read_u16_le(0x5C942, "Work Ram High") end,
		max_health=function() return memory.read_u16_le(0x5C946, "Work Ram High") end,
		get_iframes=function() return memory.read_u16_le(0x5C524, "Work Ram High") end,
		get_player_state=function() return memory.read_u16_le(0x99824, "Work Ram High") end,
		stone_state=11,
		is_valid_gamestate=function()
			gamestate = memory.read_u16_le(0x5CD72, "Work Ram High") -- May not be the actual gamestate addr, but works for our purpose
			return gamestate == 1 -- Gameplay
				or gamestate == 5 -- Game Over
		end,
		game_over_check=function()
			gamestate = memory.read_u16_le(0x5CD72, "Work Ram High")
			if gamestate == 5 then -- Changes as soon as the fade-to-white starts
				return true -- Game Over
			else
				return false -- Gameplay
			end
		end,
	},
	['CV64_JPN_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C3E, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A9AA0 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CV64_NA_V10_V11_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C3E, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A7820 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CV64_NA_V12_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C3E, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A7BC0 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CV64_EUR_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C42, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A82F0 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CVLOD_JPN_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x1CC4EA, "RDRAM") end,
		maxhp=function() return 10000 end,
		gamestate_ptr_addr=function() return 0x800C3CC0 end,
		gameplaymode=function() return 3 end,
		enteringgameovermode=function() return -11 end
	},
	['CVLOD_NA_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x1CAB3A, "RDRAM") end,
		maxhp=function() return 10000 end,
		gamestate_ptr_addr=function() return 0x800C1520 end,
		gameplaymode=function() return 3 end,
		enteringgameovermode=function() return -11 end
	},
	['CVLOD_EUR_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x1CC00A, "RDRAM") end,
		maxhp=function() return 10000 end,
		gamestate_ptr_addr=function() return 0x800C2800 end,
		gameplaymode=function() return 3 end,
		enteringgameovermode=function() return -11 end
	},
	['IceClimber_NES']={ -- Ice Climber NES
		func=twoplayers_withlives_swap,
		maxhp=function() return 2 end,
		-- we can implement a swap on failing the bonus game
		-- 0x0055 RAM is a sort of game mode, 0 title, 1 main level, 2 bonus, 3 and 4 bonus screen, 5 fly up to preview level
		-- 0x001E RAM is "got dactyl", 0 no, 1 1p, 2 2p
		-- so, if 0x0055 == 3 and 0x001E == 0, you just lost the bonus game
		p1gethp=function()
			if memory.read_u8(0x0055, "RAM") == 3 and
				memory.read_u8(0x001E, "RAM") == 0
				then return 1
			else return 2
			end
		end,
		p2gethp=function()
			if memory.read_u8(0x0055, "RAM") == 3 and
				memory.read_u8(0x001E, "RAM") == 0
				then return 1
			else return 2
			end
		end,
		p1getlc=function() return memory.read_u8(0x0020, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0021, "RAM") end,
		gmode=function() return memory.read_u8(0x0053, "RAM") ~= 1 end, -- 1 == in demo
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0020 end,
		p2livesaddr=function() return 0x0021 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0020, "RAM") ~= 252 end, -- 0 on start, 252 if player out of lives
		ActiveP2=function() return memory.read_u8(0x0021, "RAM") ~= 252 end, -- 0 on start, 252 if player out of lives
	},
	['DarkwingDuck_NES']={ -- Darkwing Duck (NES)
		func=singleplayer_withlives_swap,
		maxhp=function() return 4 end,
		p1gethp=function()
		-- four addresses for heart pieces
			if memory.read_u8(0x05B4, "RAM") == 0x80 then
				return 4
			--first heart piece
			elseif memory.read_u8(0x05B8, "RAM") == 0x81 then
				return 3
			--second heart piece
			elseif memory.read_u8(0x05B6, "RAM") == 0x81 then
				return 2
			--third heart piece
			elseif memory.read_u8(0x05B2, "RAM") == 0x80 then
				return 1
			--last heart piece to go
			else
				return 0
			end
		end,
		p1getlc=function() return memory.read_u8(0x05E4, "RAM") * 10 + memory.read_u8(0x05E6, "RAM") end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x05E4 end,
		maxlives=function() return 0x76 end, 
		-- Darkwing Duck counts strangely, 0x05E4 is the tens diget and 0x0536 is the ones digit, and this byte reads as 0x7_ where the trailing digit is number of lives
		-- so we can't really give 69 lives this way without reworking the Infinite* Lives function
		-- so you get 60 + x lives instead.
		ActiveP1=function() return true end, -- P1 is always active!
	},
	['Contra_NES']={ -- Contra/Probotector (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0032, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0033, "RAM") end,
		gettogglecheck=function()
			local p1gameover_changed, p1gameover_curr, p1gameover_prev = update_prev('p1gameover', memory.read_u8(0x0038, "RAM") == 1)
			local p2gameover_changed, p2gameover_curr, p2gameover_prev = update_prev('p2gameover', memory.read_u8(0x0039, "RAM") == 1)
			-- if a player steals a life to tag back in, "game over" flag will change on the same frame. This toggle prevents an extra swap.
			if p1gameover_changed == true or p2gameover_changed == true
			then
				return true
			end
			return false
		end,
		gmode=function() return memory.read_u8(0x001C, "RAM") == 0 end, -- if 1, then in demo
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0032 end,
		p2livesaddr=function() return 0x0033 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0032, "RAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x0033, "RAM") > 0 end,
		maxhp=function() return 0 end,
	},
	['SuperC_NES']={ -- Super Contra/Probotector II (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0053, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0054, "RAM") end,
		gettogglecheck=function()
			-- Super C loves doing things one frame at a time, not simultaneously, it seems. Here, lives and "game over state" change on consecutive frames!
			-- So we need a different toggle for this than for the first Contra.
			-- When a player steals a life to tag back in, their lives will go up from 0 to 1 AND the i-frames timer will start at 128.
			-- Let's track those two things for both players, and not swap when they both change this way.
			local p1lives_changed, p1lives_curr, p1lives_prev = update_prev('p1lives', memory.read_u8(0x0053, "RAM"))
			local _, p1tagin_started_curr, p1tagin_started_prev = update_prev('p1tagin_started', memory.read_u8(0x00C4, "RAM") == 128)
			local p2lives_changed, p2lives_curr, p2lives_prev = update_prev('p2lives', memory.read_u8(0x0054, "RAM"))
			local _, p2tagin_started_curr, p2tagin_started_prev = update_prev('p2tagin_started', memory.read_u8(0x00C5, "RAM") == 128)
			-- if a player steals a life to tag back in, the countdown on iframes starts on 128 and lasts 2 frames. This toggle prevents an extra swap.
			if (p1lives_curr == 1 and p1lives_prev == 0 and p1tagin_started_curr == true and p1tagin_started_prev == false) or 
				(p2lives_curr == 1 and p2lives_prev == 0 and p2tagin_started_curr == true and p2tagin_started_prev == false) 
			then
				return true
			end
			local p1respawn_frames_changed, p1respawn_frames_curr, p1respawn_frames_prev = update_prev('p1respawn_frames', memory.read_u8(0x00C0, "RAM"))
			local p2respawn_frames_changed, p2respawn_frames_curr, p2respawn_frames_prev = update_prev('p2respawn_frames', memory.read_u8(0x00C1, "RAM"))
			-- let's grab the countdown for spawning in, including stuff like the helicopter at the start of the game!
			-- if these are 0, the player is "live" and can be harmed.
			if (p1lives_changed == true and p1respawn_frames_changed == true and p1respawn_frames_curr > 0) or 
				(p2lives_changed == true and p2respawn_frames_changed == true and p2respawn_frames_curr > 0) 
			then
				return true
			end
			local levelstarted_changed, levelstarted_curr, levelstarted_prev = update_prev('levelstarted', memory.read_u8(0x0087, "RAM") == 1)
			if (levelstarted_changed == true and levelstarted_prev == false)
			-- on level start, Super C deducts a life from the stash! Why?! Anyway, don't swap on that.
			then
				return true
			end
			return false
		end,
		gmode=function() return memory.read_u8(0x001F, "RAM") == 0 end, -- actually in gameplay
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0053 end,
		p2livesaddr=function() return 0x0054 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x00C2, "RAM") ~= 1 end,
		ActiveP2=function() return memory.read_u8(0x00C3, "RAM") ~= 1 end,
		-- player is either inactive or in death sequence when these addresses == 1, lives go down the same frame that these addresses tick to 0
		maxhp=function() return 0 end,
	},
	['ContraIII_SNES']={ -- Contra III/Probotector (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x1F8A, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x1FCA, "WRAM") end,
		-- gmode=function() return memory.read_u8(0x001C, "RAM") == 0 end, -- if 1, then in demo
		gettogglecheck=function()
			local gameover_changed, gameover_curr, gameover_prev = update_prev('p1gameover', memory.read_u8(0x00A6, "WRAM") == 160)
			-- if a player steals a life to tag back in, "one player has game overed in 2p mode" flag will change to 160 (both alive) on the same frame. This toggle prevents an extra swap.
			if gameover_changed == true
			then
				return true
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x1F8A end,
		p2livesaddr=function() return 0x1FCA end,
		maxlives=function() return 70 end, -- sorry, Japan, yours shows 70 instead of 69
		ActiveP1=function() return memory.read_u8(0x1F8A, "WRAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x1FCA, "WRAM") > 0 end,
		maxhp=function() return 0 end,
	},
	['BladesofSteel_NES']={ -- Blades of Steel NES
		func=twoplayers_withlives_swap,
		gmode=function() return memory.read_u8(0x0019, "RAM") ~= 1 end, -- 1 == in demo
		maxhp=function() return 5 + 1 end,
		-- hp is going to cover fights and Gradius losses, and lives will cover goals
		p1gethp=function()
			if memory.read_u8(0x0648, "RAM") > 5 and memory.read_u8(0x0648, "RAM") <= 40
				-- gradius cutscene ramps this up to 40 for some reason?? let's just drop the health until you get into a fight again
				-- and the health drop itself will cause you to swap on the ship exploding if you lose at Gradius!
				or (memory.read_u8(0x0080, "RAM") >=6 and memory.read_u8(0x0080, "RAM") <=8)
				-- this address marks out a game mode, and 6 through 8 apply to penalty shots to break a tie
				-- we need this because Blades of Steel has once again reused the fight health address! cool!
			then
				return 1
			elseif memory.read_u8(0x0648, "RAM") > 0 or memory.read_u8(0x0649, "RAM") > 0
				-- we are in a fight
			then
				return memory.read_u8(0x0648, "RAM") + 1
			else
				return 0
				-- outside of fights and Gradius, rely on goals
			end
		end,
		p2gethp=function()
			if (memory.read_u8(0x0080, "RAM") >=6 and memory.read_u8(0x0080, "RAM") <=8)
				-- this address marks out a game mode, and 6 through 8 apply to penalty shots to break a tie
				-- we need this because Blades of Steel has once again reused the fight health address! cool!
			then
				return 1
			elseif memory.read_u8(0x0022, "RAM") == 1 and 
				(memory.read_u8(0x0648, "RAM") > 0 or memory.read_u8(0x0649, "RAM") > 0)
				-- we are in a 2p game AND a fight
			then 
				return memory.read_u8(0x0649, "RAM") + 1
			else
				return 0
				-- outside of fights, rely on goals
			end
		end,
		p1getlc=function()  
			return -1*(math.floor(memory.read_u8(0x07E9, "RAM")/16)*10 + (memory.read_u8(0x07E9, "RAM") % 16))
			-- second team's goals
			-- this is actually a hex value that just skips A-F on screen. Transformed and inverted so it counts down.
			-- TODO: subtract 1 for Gradius ship if it dies
		end,
		p2getlc=function() 
			if memory.read_u8(0x0022, "RAM") == 1
			-- we are in a 2p game
			then
				return -1*(math.floor(memory.read_u8(0x07E5, "RAM")/16)*10 + (memory.read_u8(0x07E5, "RAM") % 16))
			-- first team's goals
			-- this is actually a hex value that just skips A-F on screen. Transformed and inverted, so it counts down.
			else
				return 0
			end
		end,
		gettogglecheck=function()
			local _, p1hp_curr, p1hp_prev = update_prev('p1hp', memory.read_u8(0x0648, "RAM"))
			local _, p2hp_curr, p2hp_prev = update_prev('p2hp', memory.read_u8(0x0649, "RAM"))
			-- the winning fighter drops to 0 when transition from fight to normal gameplay happens, so let's prevent a double swap
			return p1hp_curr == 0 and p2hp_curr == 0
		end,
			-- if both fighters just dropped to 0, that's "end of battle"
			-- update_prev set up because there could be further exceptions identified later
		CanHaveInfiniteLives=false, -- Blades of Steel does not work this way.
	},
	['DoubleDragon1_NES']={ -- Double Dragon NES
		func=twoplayers_withlives_swap,
		-- objective: only swap on knockdowns, not every punch, and lives lost
		-- RAM 0x03C8 is a stun frame counter, sits at 0, pops to 32 on getting hit, then rolls down to 0
		-- RAM 0x03C4 is a hit counter, as you can get hit a few times before a knockdown, it goes back to 0 when knockdown activated
		-- if we only update hp on "hit counter == 0 and stun frames just hit 0," we can use this HP function
		-- amazingly, this works the same way in the fighting game!
		gmode=function() return memory.read_u8(0x00FE, "RAM") == 24 end,
		-- we are actually in gameplay this way! cool!
		p1gethp=function() 
			local p1hp_changed, p1hp_curr, p1hp_prev = update_prev('p1hp', memory.read_u8(0x03B4, "RAM"))
			local p1hitcounter_changed, p1hitcounter_curr, p1hitcounter_prev = update_prev('p1hitcounter', memory.read_u8(0x03C4, "RAM"))
			local p1stunframes_changed, p1stunframes_curr, p1stunframes_prev = update_prev('p1stunframes', memory.read_u8(0x03C8, "RAM"))
			if p1hp_curr == 0 then
				return 0
			end
			if p1hitcounter_curr == 0 and p1stunframes_changed and p1stunframes_curr == 31
				--we use 31 rather than 32 because you can get knocked down on a simultaneous hit that would have bumped up your hit counter
			then
				return 1
			end
			return 2 
		end,
		p2gethp=function()
		-- objective: only swap on knockdowns, not every punch, and lives lost
		-- RAM 0x03C9 is a stun frame counter, sits at 0, pops to 32 on getting hit, then rolls down to 0
		-- RAM 0x03C5 is a hit counter, as you can get hit a few times before a knockdown, it goes back to 0 when knockdown activated
		-- if we only update hp on "hit counter == 0 and stun frames just hit 0," we can use this HP function
		-- amazingly, this works the same way in the fighting game!
			local p2hp_changed, p2hp_curr, p2hp_prev = update_prev('p2hp', memory.read_u8(0x03B5, "RAM"))
			local p2hitcounter_changed, p2hitcounter_curr, p2hitcounter_prev = update_prev('p2hitcounter', memory.read_u8(0x03C5, "RAM"))
			local p2stunframes_changed, p2stunframes_curr, p2stunframes_prev = update_prev('p2stunframes', memory.read_u8(0x03C9, "RAM"))
			if memory.read_u8(0x0030, "RAM") == 2 and memory.read_u8(0x0032, "RAM") == 1 then
			-- the 2p addresses apply to enemies in 1p Mode A (side scroller), so we need to specify that we are actually in 2p fighting mode
				if p2hp_curr == 0 then
					return 0
				end
				if p2hitcounter_curr == 0 and p2stunframes_changed and p2stunframes_curr == 31
				then
					return 1
				end
			end
			return 2 
		end,
		maxhp=function() return 2 end,
		-- because of how we are calculating HP, the fighting game HP differences shouldn't matter
		p1getlc=function() return memory.read_u8(0x0043, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0043, "RAM") end,
		gettogglecheck=function() return memory.read_u8(0x0031, "RAM") == 1 end,
		-- Did the current player change on this frame? If so, don't shuffle. That frame is when the stored number of lives gets loaded.
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function()
			if memory.read_u8(0x0031, "RAM") == 2 then
			-- side scroller, 2p is active, so fill in the saved number of lives for inactive p1
				return 0x06B1
			else
				return 0x0043
			-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x06BD end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		ActiveP2=function() return true end, -- p2 is always active! the way the lives are stored, you just never swap in this player and their lives in 1p A mode
		delay=32,
		-- let players see the knockdown happen
	},
	['DoubleDragon2_NES']={ -- Double Dragon NES
		func=twoplayers_withlives_swap,
		-- objective: only swap on knockdowns, not every punch, and lives lost
		-- iframes won't work, because they only trigger on respawn.
		-- unlike DD1, one address appears to count frames both for stun frames and knockdowns the same way.
		-- it is not usable, even with a hit counter.
		-- RAM 0x0055 (p1) and 0x0056 hold some form of knockdown counter, however.
		-- on a knockdown specifically, this starts at 3, rolls down to 0, wraps around to 255, and eventually skips to 19 and further down.
		-- 19 does not activate on falling to your death.
		-- I suspect that the fourth bit of the byte is only activated on knockdown, because some other values (like high score) work similarly.
		-- Anyway, we're just looking for a 19 to be our HP!
		p1gethp=function() 
			local p1knockdown_changed, p1knockdown_curr, p1knockdown_prev = update_prev('p1knockdown', memory.read_u8(0x0055, "RAM"))
			if p1knockdown_changed and p1knockdown_curr == 19 then
				return 1
			end
			return 2 
		end,
		p2gethp=function() 
			local p2knockdown_changed, p2knockdown_curr, p2knockdown_prev = update_prev('p2knockdown', memory.read_u8(0x0056, "RAM"))
			if p2knockdown_changed and p2knockdown_curr == 19 then
				return 1
			end
			return 2 
		end,
		maxhp=function() return 2 end,
		-- this is clearly a hack to make "HP" out of a non-HP variable, but okay.
		p1getlc=function() return memory.read_u8(0x0432, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0433, "RAM") end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0432 end,
		p2livesaddr=function() return 0x0433 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return memory.read_u8(0x0432, "RAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x0433, "RAM") > 0 end,
		delay=7,
		-- let players see the knockdown happen
	},
	['DKC1_SNES']={ -- Donkey Kong Country (SNES)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x000527, "WRAM") ~= 1 end,
		-- not on the map
		get_iframes=function() 
			if memory.read_u8(0x16D5, "WRAM") + memory.read_u8(0x16D7, "WRAM") > 20 then
				-- DK (0x16D5) and Diddy (0x16D7) get 108 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x16D5, "WRAM") + memory.read_u8(0x16D7, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000575, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x000044, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x000527, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x000042, "WRAM") == 2 and memory.read_u8(0x000044, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x012343
			else
				return 0x000575
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x012567 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x000042, "WRAM") == 2 end, -- only applies when mode is 2p Contest
	},
	['DKC1_SFC']={ -- Super Donkey Kong (SFC)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x000527, "WRAM") ~= 1 end,
		-- not on the map
		get_iframes=function() 
			if memory.read_u8(0x16E7, "WRAM") + memory.read_u8(0x16E9, "WRAM") > 20 then
				-- DK (0x16E7) and Diddy (0x16E9) get 108 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x16E7, "WRAM") + memory.read_u8(0x16E9, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000585, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x000044, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x000527, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x000042, "WRAM") == 2 and memory.read_u8(0x000044, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x012343
			else
				return 0x000585
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x012569 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x000042, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: bonus game shuffles
		-- TODO: Can these versions be condensed?
	},
	['DKC2_SNES']={ -- Donkey Kong Country 2: Diddy's Kong Quest (SNES) / Super Donkey Kong 2 (SFC)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x00060D, "WRAM") <= 2 end,
		-- not in sound test or cheat entry mode
		get_iframes=function() 
			if memory.read_u8(0x16C6, "WRAM") + memory.read_u8(0x16EC, "WRAM") > 20 then
				-- Diddy (0x16C6) and Dixie (0x16EC) get 96 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x16C6, "WRAM") + memory.read_u8(0x16EC, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0008BE, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x00060F, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x000DE5, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x00060D, "WRAM") == 2 and memory.read_u8(0x00060F, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x00527C
			else
				return 0x0008BE
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x0055E1 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x00060D, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: doublecheck onmap address
		-- TODO: bonus game shuffles
		-- TODO: better behavior on a hard reset?
	},
	['DKC3_SNES_US']={ -- Donkey Kong Country 3: Dixie Kong's Double Trouble (SNES) (USA)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0004C4, "WRAM") <= 2 end,
		-- not in any debug/sound test/cheat entry mode
		get_iframes=function() 
			if memory.read_u8(0x1494, "WRAM") + memory.read_u8(0x14E6, "WRAM") > 20 then
				-- Dixie (0x1494) and Kiddy (0x14E6) get 96 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x1494, "WRAM") + memory.read_u8(0x14E6, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0005D5, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x0004C6, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x0006D8, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x0004C4, "WRAM") == 2 and memory.read_u8(0x0004C6, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x00292C
			else
				return 0x0005D5
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x002A26 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x0004C4, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: doublecheck onmap address
		-- TODO: bonus game shuffles
	},
	['DKC3_SNES_EU_JP']={ -- Donkey Kong Country 3: Dixie Kong's Double Trouble (SNES) (Europe)
		-- also, Super Donkey Kong 3: Nazo no Kremis-tou (Japan)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0004C4, "WRAM") <= 2 end,
		-- not in any debug/sound test/cheat entry mode
		get_iframes=function() 
			if memory.read_u8(0x149A, "WRAM") + memory.read_u8(0x14EC, "WRAM") > 20 then
				-- Dixie (0x1494) and Kiddy (0x14E6) get 96 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x149A, "WRAM") + memory.read_u8(0x14EC, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0005DB, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x0004C6, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x0006DE, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x0004C4, "WRAM") == 2 and memory.read_u8(0x0004C6, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x00292C
			else
				return 0x0005DB
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x002A26 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x0004C4, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: doublecheck onmap address
		-- TODO: bonus game shuffles
	},
	['DKCxMARIO_SNES']={ -- DKC x Mario (SNES), version 1.107 tested
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x000527, "WRAM") ~= 1 end,
		-- not on the map
		get_iframes=function()
			-- Big Mario took DK's spot, and Small Mario took Diddy's spot.
			if memory.read_u8(0x00056F, "WRAM") == 1 and memory.read_u8(0x16D5, "WRAM") > 60 then
				-- Big Mario, note that 60 iframes are awarded on powerups and a small amount of iframes are awarded on stomps
				return memory.read_u8(0x16D5, "WRAM")
			elseif memory.read_u8(0x00056F, "WRAM") == 2 and memory.read_u8(0x16D7, "WRAM") > 60 then
				-- Small Mario
				return memory.read_u8(0x16D7, "WRAM")
			end
			-- return 0 if none of these apply
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000575, "WRAM"))
			if lives_changed and lives_curr < lives_prev and not (memory.read_u8(0x000527, "WRAM") == 1) then
				-- 1 == on map; this is simpler than DKC 1 as there's only one player!
				return true
			end
			local diedfromdamage_changed, diedfromdamage_curr, diedfromdamage_prev = update_prev("diedfromdamage", memory.read_u8(0x1599, "WRAM") == 1)
			-- this flag *appears* to tick to 1 for one frame, then back to 0, when small Mario dies from damage
			-- triggering a fadeout and return to checkpoint
			if diedfromdamage_changed and diedfromdamage_curr == true and not (memory.read_u8(0x000527, "WRAM") == 1) then
				-- 1 == on map
				return true
			end
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000575 end,
		-- active player's lives (1p only), lives do not get deducted on dying from damage as small Mario
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
	},
	['Jackal_NES']={ -- Jackal (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0031, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0032, "RAM") end,
		gettogglecheck=function()
			local p1lives_changed, p1lives_curr, p1lives_prev = update_prev('p1lives', memory.read_u8(0x0031, "RAM"))
			local p2lives_changed, p2lives_curr, p2lives_prev = update_prev('p2lives', memory.read_u8(0x0032, "RAM"))
			-- if a player steals a life to tag back in, don't swap.
			if p1lives_changed == true and p1lives_prev == 0 
				or p2lives_changed == true and p2lives_prev == 0
			then
				return true
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0031 end,
		p2livesaddr=function() return 0x0032 end,
		maxlives=function() return 10 end, -- just one digit displays for extra lives in this game
		ActiveP1=function() return memory.read_u8(0x0031, "RAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x0032, "RAM") > 0 end,
		maxhp=function() return 0 end,
	},
	['StarFox64_N64']={ -- Star Fox 64 (N64)
		func=iframe_health_swap,
		is_valid_gamestate=function() return 
			memory.read_u8(0x11B550, "RDRAM") == 1 or
			-- story mode
			memory.read_u8(0x11B550, "RDRAM") == 3 or
			-- all-range mode, includes versus
			memory.read_u8(0x11B550, "RDRAM") == 247
			-- training mode
			-- this may need additional data points to prevent wrong shuffles
		end,
		iframe_minimum=function() return 20 end,
		get_iframes=function()
			if memory.read_u8(0x11B550, "RDRAM") == 247 then
				-- training mode
				if memory.read_u8(0x13AAB7, "RDRAM") < 100 then
				-- some garbage values in other scenarios can make this address run over the minimum 20 iframes you actually receive on damage
					return memory.read_u8(0x13AAB7, "RDRAM")
				end
			elseif memory.read_u8(0x0DB15B, "RDRAM") == 1 then
				-- 1 == in battle mode, just add all the iframes together for all four players
				return memory.read_u8(0x137C4B, "RDRAM") +
					memory.read_u8(0x13835B, "RDRAM") +
					memory.read_u8(0x13883B, "RDRAM") +
					memory.read_u8(0x138D1B, "RDRAM")
			end
			-- p1, in story or battle mode
			if memory.read_u8(0x137BD7, "RDRAM") < 100 then
				return memory.read_u8(0x137BD7, "RDRAM")
			end
			-- otherwise, no iframes are active
			return 0
		end,
		other_swaps=function() return false end, -- the explosion cutscene uses iframes and thus handles p1 deaths in story mode
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x157911 end,
		-- importantly, we have to write just one byte
		LivesWhichRAM=function() return "RDRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active! lives do not apply elsewhere
	},
	['LittleSamson_NES']={ -- Little Samson, NES
		func=singleplayer_withlives_swap,
		-- we'll track every character's hp and maxhp individually
		-- so that dying due to lost health shuffles when the life counter ticks down
		gmode=function() return memory.read_u8(0x0050, "RAM") <= 3 end,
		-- characters are numbered 0 to 3 at this address
		p1gethp=function()
			if memory.read_u8(0x0050, "RAM") == 3 then
				return memory.read_u8(0x009A, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 2 then
				return memory.read_u8(0x0099, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 1 then
				return memory.read_u8(0x0098, "RAM")
			else
				return memory.read_u8(0x0097, "RAM")
			end
		end,
		p1getlc=function() return memory.read_u8(0x0091, "RAM") end,
		-- lives are shared across characters!
		maxhp=function()
			if memory.read_u8(0x0050, "RAM") == 3 then
				return memory.read_u8(0x0096, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 2 then
				return memory.read_u8(0x0095, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 1 then
				return memory.read_u8(0x0094, "RAM")
			else
				return memory.read_u8(0x0093, "RAM")
			end
		end,
		gettogglecheck=function() 
			local character_changed, character_curr, character_prev = update_prev("character", memory.read_u8(0x0050, "RAM"))
			-- characters have different max health.
			-- if active character swaps, health may go down as a result, don't swap on that.
			return character_changed
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0091 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['WarioWare_GBA']={ -- WarioWare, Inc. / Made in Wario, GBA
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_u8(0x39D5, "IWRAM") end,
		-- consider tries remaining in microgames to be lives - this is the primary mechanism for swaps
		-- HP will apply only to specific game modes that don't tick down your 4 tries
		p1gethp=function()
			if memory.read_u8(0x3ADC, "IWRAM") == 0xD9 then
				-- boxing, you get three HP
				return memory.read_u8(0x5769, "IWRAM")
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xD7 then
				-- baseball
				-- 0x5831 == target to hit out of 10 balls, 11 - this == maxhp as you can miss that many balls before losing a life
				-- 0x57D9 == balls thrown, 0x57DA == balls hit, 0x57DB == balls missed; all change on same frame
				-- so, calculate 11 - maxhp - balls missed
				return 11 - memory.read_u8(0x5831, "IWRAM") - memory.read_u8(0x57DB, "IWRAM")
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xE4 then
				-- fly swatter
				if memory.read_u8(0x6366, "IWRAM") == 255 then
					-- 255 == game over, 0 means 0 extra hands
					return 0
				else 
					return memory.read_u8(0x6366, "IWRAM") + 1
				end
			else
				return 0
			end
		end,
		maxhp=function()
			if memory.read_u8(0x3ADC, "IWRAM") == 0xD9 then
				-- boxing, you get three HP
				return 3
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xD7 then
				-- 0x5831 == target to hit out of 10 balls, 11 - this == maxhp as you can miss that many balls before losing a life
				-- if it hasn't loaded yet, return 0
					if memory.read_u8(0x5831, "IWRAM") == 0 then
						return 0
					else
						return 11 - memory.read_u8(0x5831, "IWRAM")
					end
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xE4 and memory.read_u8(0x0118, "IWRAM") == 1 then
				-- fly swatter: game won't drop extra hands if you have 6 banked, make sure you are in active mode
					return 6
			else
				return 0
			end
		end,
		gettogglecheck=function()
			local gameon_changed, gameon_curr, gameon_prev = update_prev("gameon", memory.read_u8(0x0118, "IWRAM"))
			-- value ticks from 0 to 1 and back when you enter a game mode versus stay on the game selection grid
			local progress_changed, progress_curr, progress_prev = update_prev("progress", memory.read_u8(0x39DC, "IWRAM"))
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x39D5, "IWRAM"))
			-- progress and lives change on the same frame. if you make progress, and you don't lose a life, you should never swap.
			-- creating this toggle will solve problems like HP for boxing/baseball resetting on the same frame if you progress to next round.
			return gameon_changed or (progress_changed and not lives_changed)
		end,
		CanHaveInfiniteLives=false,
		-- may add a option for this in the future, but you don't lose *progress* in the story if you game over (similar to Mega Man)
		-- would also need to consider modes that don't use lives
	},
	['MagicalDoropie_NES']={ -- Magical Doropie / Krion Conquest, NES
		func=iframe_health_swap,
		get_health=function() return memory.read_u8(0x004C, "RAM") end,
		get_iframes=function() return memory.read_u8(0x03E0, "RAM") end,
		is_valid_gamestate=function()
			-- During gameplay, 004C is health and 004D is death indicator. Elsewhere, 004C..004D is a jump address
			-- So don't swap if 004D is non-zero, except in the case of 0001=zero health+dying
			return (memory.read_u8(0x004D, "RAM") == 0 or memory.read_u16_be(0x004C, "RAM") == 0x0001) and
				memory.read_u32_le(0x0030, "RAM") ~= 0 -- just random memory that's zeroed during reset and nonzero otherwise
		end,
		other_swaps=function() end,
		CanHaveInfiniteLives=true,
		ActiveP1=function()
			return (memory.read_u8(0x004D, "RAM") == 0 or memory.read_u16_be(0x004C, "RAM") == 0x0001) and
				memory.read_u32_le(0x0030, "RAM") ~= 0
		end,
		-- Strange, it's reading this as BCD for display, but otherwise treating this as a signed byte
		maxlives=function() return 3 end,
		p1livesaddr=function() return 0x0043 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['JUNKY_BALL_MR_GBA']={ -- Super Monkey Ball Jr., GBA
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_s8(0x2ADC, "EWRAM") end,
		p1gethp=function() return 1 end, -- No HP in this game
		maxhp=function() return 1 end, -- Again, no HP in this game
		gmode=function() return memory.read_u8(0x1CE, "EWRAM") == 85 end, -- Not 100% sure about this, but seems good
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x2ADC end,
		LivesWhichRAM=function() return "EWRAM" end,
		maxlives=function() return 99 end, -- 127+1 wraps around to -128, and
		-- you get 1ups for 50 bananas that doesn't account for that, so 99 is a
		-- safe compromise. 3 lives max drawn on HUD, but higher values do count
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['BATMAN_NES']={ -- Batman, NES
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_s8(0xBE, "RAM") end,
		p1gethp=function() return memory.read_u8(0xB7, "RAM") end,
		maxhp=function() return 8 end,
		gmode=function() return memory.read_u8(0x3D, "RAM") == 0 end, -- Confirmed with the disassembly of one "pwnskar"
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0xBE end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end, -- Anything higher corrupts the pause menu graphics,
		-- but technically works; anything negative, however, immediately triggers a Game Over
		ActiveP1=function() return true end, -- p1 is always active!
	},
}

local backupchecks = {
}

local function get_game_tag()
	-- try to just match the rom hash first
	local tag = get_tag_from_hash_db(gameinfo.getromhash(), 'plugins/chaos-shuffler-hashes.dat')
	if tag ~= nil and gamedata[tag] ~= nil then
		return tag
	end

	-- check to see if any of the rom name samples match
	local name = gameinfo.getromname()
	for _,check in pairs(backupchecks) do
		if check.test() then
			return check.tag
		end
	end

	return nil
end

local function BT_NES_Zitz_Override()
	if tag == "BT_NES" -- unpatched Battletoads NES
		and memory.read_u8(0x000D, "RAM") == 11 -- in Clinger-Winger
		and memory.read_u8(0x0011, "RAM") ~= 255 -- Rash is alive
	then
		return true -- if all of those are true, then don't give Zitz all those lives, it'll more or less softlock you!
	end
	
	return false
end

function plugin.on_game_load(data, settings)
	prevdata = {}
	swap_scheduled = false
	shouldSwap = function() return false end
	
	tag = tags[gameinfo.getromhash()] or get_game_tag()
	tags[gameinfo.getromhash()] = tag or NO_MATCH
	
	---------------
	-- For Battletoads games to do level skip/select based on filename
	----

	-- Which level to patch into on game load?
	-- Grab the first two characters of the filename, turned into a number.
	local which_level_filename = string.sub((tostring(config.current_game)),1,2)
	local which_level = which_level_filename

	-- if file name starts with a number outside of the expected range, reset the level to 1
	-- TODO: recode to accommodate different min and max levels (Battletoads SNES requires 00-08)
	-- consider moving function elsewhere if needed

	if type(tonumber(which_level)) == "number" then
		which_level = tonumber(which_level)
		-- BT_NES
		if tag == "BT_NES" or tag == "BT_NES_patched" then
			if which_level >13 or which_level <1 or which_level == nil then
				which_level = 1
			end
		end
		-- BT_SNES
		if tag == "BT_SNES" then
			if which_level >8 or which_level <1 then
				which_level = 1
			end
		end
		-- BTDD (both)
		if tag == "BTDD_NES"
			or tag == "BTDD_SNES"
			or tag == "BTDD_SNES_patched"
		then
			if which_level >14 or which_level <1 then
				which_level = 1
			end
		end
	else
		which_level = 1
	end

	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	
	-- TODO: set min and max level variable by game
	
	-- BATTLETOADS NES
	if tag == "BT_NES" or tag == "BT_NES_patched" then
		-- enable Infinite* Lives for Rash (p1) if checked
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x0011, "RAM") > 0 and memory.read_u8(0x0011, "RAM") < 255 -- is Rash on?
		then
			memory.write_u8(0x0011, 69, "RAM") -- if so, set lives to 69. Nice.
		end
	
		-- enable Infinite* Lives for Zitz (p2) if checked
		-- DOES NOT APPLY IF LEVEL = 11 AND ROM IS UNPATCHED
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x0012, "RAM") > 0 and memory.read_u8(0x0012, "RAM") < 255 -- is Zitz on?
		then
			if
				BT_NES_Zitz_Override() == false -- are we outside of the 2P/unpatched/on level 11 scenario?
			then -- if so, set lives to 69. Nice.
				memory.write_u8(0x0012, 127, "RAM")	
			elseif memory.read_u8(0x000D, "RAM") == 11 then
				memory.write_u8(0x0012, 0, "RAM") -- Otherwise, get Zitz to 0 lives immediately if you arrived at Clinger-Winger
			end
		end
	end
	
	if tag == "BT_NES" or tag == "BT_NES_patched" then
		-- if game was just loaded, these two addresses will = 255
		-- after starting or continuing, they get set to 40 or 0, respectively, and stay that way
		-- we now set these on game load, to let the player press start without sitting through the intro every time
		if memory.read_u8(0x00FD, "RAM") == 255 then
			memory.write_u8(0x00FD, 40, "RAM")
		end
		if memory.read_u8(0x00FE, "RAM") == 255 then
			memory.write_u8(0x00FE, 0, "RAM")
		end
	end
	
	-- Battletoads in Battlemaniacs (SNES)
	if tag == "BT_SNES" then
		-- enable Infinite* Lives for P1 (Pimple) if checked
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x000028, "WRAM") > 0 and memory.read_u8(0x000028, "WRAM") < 255 -- have we started playing?
		then
			memory.write_u8(0x000028, 69, "WRAM") -- if so, set lives to 69. Nice.
		end
		-- enable Infinite* Lives for P2 (Rash) if checked
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x00002A, "WRAM") > 0 and memory.read_u8(0x00002A, "WRAM") < 255 -- have we started playing?
		then
			memory.write_u8(0x00002A, 69, "WRAM") -- if so, set lives to 69. Nice.
		end
	end

	-- first time through with a bad match, tag will be nil
	-- can use this to print a debug message only the first time
	
	if tag ~= nil and tag ~= NO_MATCH then
		gamemeta = gamedata[tag]
		local func = gamemeta.func
		shouldSwap = func(gamemeta)
		
		-- Infinite* Lives - set lives to max on game load
		local CanHaveInfiniteLives = gamemeta.CanHaveInfiniteLives
		
		if settings.InfiniteLives == true -- is infinite lives enabled?
			and CanHaveInfiniteLives == true -- can this game can do infinite lives?
		then
			-- returns the number of games left in the shuffler
			-- this will be key for how infinite lives are handled at the end!
			gamesleft = #(get_games_list())

			local ActiveP1 = false
			if gamemeta.ActiveP1 then
				ActiveP1 = gamemeta.ActiveP1()
			end
			local ActiveP2 = false
			if gamemeta.ActiveP2 then
				ActiveP2 = gamemeta.ActiveP2()
			end
			local p1livesaddr = nil
			if gamemeta.p1livesaddr then
				p1livesaddr = gamemeta.p1livesaddr()
			end
			local p2livesaddr = nil
			if gamemeta.p2livesaddr then
				p2livesaddr = gamemeta.p2livesaddr()
			end
			local maxlives = nil
			if gamemeta.maxlives then
				maxlives = gamemeta.maxlives()
			end
			local LivesWhichRAM = nil
			if gamemeta.LivesWhichRAM then
				LivesWhichRAM = gamemeta.LivesWhichRAM()
			end
			
			-- enable Infinite* Lives for p1 if checked and able
			if ActiveP1 == true -- is p1 on?
				and p1livesaddr ~= nil -- is an address specified for p1?
			then -- if so, set lives to max specified
				if LivesWhichRAM ~= nil then
					memory.writebyte(p1livesaddr, maxlives, LivesWhichRAM)
				end
			end
			
			-- enable Infinite* Lives for p2 if checked and able
			if ActiveP2 == true -- is p1 on?
				and p2livesaddr ~= nil -- is an address specified for p1?
			then -- if so, set lives to max specified
				if LivesWhichRAM ~= nil then
					memory.writebyte(p2livesaddr, maxlives, LivesWhichRAM)
				end
			end
		end
	else
		gamemeta = nil
	end

	-- log stuff
	if tag == "BT_NES" or tag == "BT_NES_patched" then
		if tonumber(which_level_filename) == nil or which_level ~= tonumber(which_level_filename) then
			if settings.SuppressLog ~= true and (which_level > 13 or which_level == 1) then
				log_console(string.format('Battletoads (NES) - no level specified (' .. string.format(tag) .. ')'))
			end
		else
			log_console('Battletoads (NES) Level ' .. tostring(which_level) .. ': ' ..  bt_nes_level_names[which_level])
		end
	elseif tag == "BTDD_NES" or tag == "BTDD_SNES" or tag == "BTDD_SNES_patched" then
		if tonumber(which_level_filename) == nil or which_level ~= tonumber(which_level_filename) then
			if settings.SuppressLog ~= true and (which_level > 14 or which_level == 1) then
				log_console(string.format('Battletoads Double Dragon - no level specified (' .. string.format(tag) .. ')'))
			end
		else
			log_console('Battletoads Double Dragon Level ' .. btdd_level_names[which_level])
		end
	elseif tag == "BT_SNES" then
		if tonumber(bt_snes_level_recoder[tonumber(which_level_filename)]) == nil then
			if tonumber(which_level_filename) == nil or tonumber(which_level_filename) > 8 then 
				log_console(string.format('Battletoads in Battlemaniacs - no level specified (' .. string.format(tag) .. ')'))
			end
		else
			log_console('Battletoads in Battlemaniacs Level ' .. tostring(which_level) .. ': ' ..  bt_snes_level_names[which_level] .. ' (' .. tag .. ')')
		end
	elseif tag ~= nil then 
		log_console('Chaos Shuffler: recognized as ' .. string.format(tag))
	elseif tag == nil or tag == NO_MATCH then
		if settings.SuppressLog ~= true then
			log_console(string.format('Chaos Shuffler: unrecognized - do you have chaos-shuffler-hashes.dat? %s (%s)',
			gameinfo.getromname(), gameinfo.getromhash())) end
	end
end

function plugin.on_frame(data, settings)
	-- Which level to patch into on game load?
	-- Grab the first two characters of the filename, turned into a number.
	local which_level_filename = string.sub((tostring(config.current_game)),1,2)
	local which_level = tonumber(which_level_filename)

if type(tonumber(which_level)) == "number" then 
	which_level = tonumber(which_level)
	--BT_NES
		if tag == "BT_NES" or tag == "BT_NES_patched" then 
		if which_level >13 or which_level <1 or which_level == nil then which_level = 1 end
		end
	--BT_SNES
		if tag == "BT_SNES" then 
		if which_level >8 or which_level <1 then which_level = 1 end
		end
	--BTDD (both)
		if tag == "BTDD_NES" or tag == "BTDD_SNES" or tag == "BTDD_SNES_patched" then 
		if which_level >14 or which_level <1 then which_level = 1 end
		end
	else 
	which_level = 1
	end
	-- TODO: CAN WE MAKE THIS A FUNCTION AND CALL IT WHEN WE NEED IT
	
	-- run the check method for each individual game
	
	if not swap_scheduled then
	
		-- PROCESS "DON'T SWAP" SETTINGS HERE
		-- A function like this should be generalizable for other games in the future to make exceptions 
		-- so that users can turn off specific swap conditions
		-- laid out by a DisableExtraSwaps function
		
		-- Yoshi's Island (SNES)
		if tag == "SMW2YI_SNES" and settings.SMW2YI_MiniBonusSwaps ~= true then
		-- can add "or this game+setting, that game+setting, etc." in the future
			if gamemeta.DisableExtraSwaps() == true then 
				return 
				-- don't swap
			end
		end
		
		-- AND NOW WE SWAP
		local schedule_swap, delay = shouldSwap(prevdata)
		if schedule_swap and frames_since_restart > math.max(settings.grace, 10) then -- avoiding super short swaps (<10) as a precaution
			swap_game_delay(delay or 3)
			swap_scheduled = true
		end
	end
	
	if gamemeta then
		-- Infinite* Lives ON FRAME - set lives to max on frame when we are either on the last game or in a game that requires it
		local MustDoInfiniteLivesOnFrame = false
		if gamemeta.MustDoInfiniteLivesOnFrame then MustDoInfiniteLivesOnFrame = gamemeta.MustDoInfiniteLivesOnFrame() end
		
		if settings.InfiniteLives == true -- is infinite lives enabled?
			and gamemeta.CanHaveInfiniteLives == true -- can this game can do infinite lives?
			and
				(MustDoInfiniteLivesOnFrame == true -- can this game can do infinite lives only on frame?
				or gamesleft == 1) -- are we in the last game left in the shuffler?
		then
			local ActiveP1 = false
			if gamemeta.ActiveP1 then
				ActiveP1 = gamemeta.ActiveP1()
			end
			local ActiveP2 = false
			if gamemeta.ActiveP2 then
				ActiveP2 = gamemeta.ActiveP2()
			end
			local p1livesaddr = nil
			if gamemeta.p1livesaddr then
				p1livesaddr = gamemeta.p1livesaddr()
			end
			local p2livesaddr = nil
			if gamemeta.p2livesaddr then
				p2livesaddr = gamemeta.p2livesaddr()
			end
			local maxlives = nil
			if gamemeta.maxlives then
				maxlives = gamemeta.maxlives()
			end
			local LivesWhichRAM = nil
			if gamemeta.LivesWhichRAM then
				LivesWhichRAM = gamemeta.LivesWhichRAM()
			end
		
			-- enable Infinite* Lives for p1 if checked and able
			if ActiveP1 == true -- is p1 on?
				and p1livesaddr ~= nil -- is an address specified for p1?
			then -- if so, let's figure out whether to set lives to max specified
				if LivesWhichRAM ~= nil then
					if memory.readbyte(p1livesaddr, LivesWhichRAM) < maxlives
						and not
						(memory.readbyte(p1livesaddr, LivesWhichRAM) ~= (maxlives - 1) and swap_scheduled == true)
						-- let 1 frame with lives < maxlives slip through so we swap on deaths
					then
						memory.writebyte(p1livesaddr, maxlives, LivesWhichRAM)
					end
				end
			end
	
			-- enable Infinite* Lives for p2 if checked and able
			if ActiveP2 == true -- is p1 on?
				and p2livesaddr ~= nil -- is an address specified for p1?
			then -- if so, let's figure out whether to set lives to max specified
				if LivesWhichRAM ~= nil then
					if memory.readbyte(p2livesaddr, LivesWhichRAM) < maxlives
						and not memory.readbyte(p2livesaddr, LivesWhichRAM) ~= (maxlives - 1)
						-- let 1 frame with lives < maxlives slip through so we swap on deaths
					then
						memory.writebyte(p2livesaddr, maxlives, LivesWhichRAM)
					end
				end
			end
		end

		-- Battletoads NES
		
		-- CLINGER-WINGER SPEED
		-- This enables the Game Genie code for always moving at max speed in Clinger Winger.
		-- The bugfix makes this not work! This will only work on an unpatched ROM. The proper, non-patched tag handles this.
		if tag == "BT_NES" then
			if settings.ClingerSpeed == true and memory.read_u8(0x000D, "RAM") == 11 and memory.read_u8(0xA706, "System Bus") == 5 then
				memory.write_u8(0xA706, 0, "System Bus")
			end
		end
		
		-- Set the memory value that represents the starting stage to the number specified by the file name.
		if tag == "BT_NES" or tag == "BT_NES_patched" then
			if which_level ~= nil and memory.read_u8(0x8320, "System Bus") ~= which_level then
				-- double check that less than/equal to gets desired effect
				memory.write_u8(0x8320, which_level, "System Bus")
			end
		end
		
		-- Battletoads Double Dragon NES
		
		-- Set the memory value that represents the starting stage to the number specified by the file name.
		if tag == "BTDD_NES" then
			if which_level ~= nil -- just started the game!
			then
				if memory.read_u8(0x0017, "RAM") == 0 then
					gui.drawText(0, 0, "Level select enabled, select " .. btdd_level_names[which_level] .. "!")
					-- give the level instruction
				end
				memory.write_u8(0x0017, 10, "RAM") -- then set Level Cheat Code to ON
			end
		end
		
		--Battletoads Double Dragon SNES
		
		if tag == "BTDD_SNES_patched" then
			if memory.read_u8(0x00002C, "WRAM") == 80 -- just started the game!
				and which_level ~= nil 
			then
				gui.drawText(0, 0, "Pick " .. btdd_level_names[which_level] .. "!")
			end
		end

		if tag == "BTDD_SNES" then
			if memory.read_u8(0x00002C, "WRAM") == 80 -- just started the game!
				and which_level ~= nil
			then 
				gui.drawText(0, 0, "Up Down Down Up X B Y A on char select (flash = ON)")
				gui.drawText(0, 20, "Pick " .. btdd_level_names[which_level] .. "!")
			end
		end
		
		--Battletoads in Battlemaniacs (SNES)
		
		-- Setting the level variable only works on a continue. Stupid but true! You'll just enter a glitched first level otherwise.
		-- So, time for Pimple to die ASAP if you chose a level other than the first one.
		
		if tag == "BT_SNES" then
			-- if current level < which_level, then
			-- set lives to 0
			-- set health to (if >1, 1, else don't touch)
			-- once a continue is used, set level to which_level
			
			-- set the value for level properly
			local BT_SNES_level_for_memory = bt_snes_level_recoder[which_level]
			
			if (which_level ~= nil and which_level > 1) or settings.BTSNESRash == true then
				-- if level specified and not the first level, or we want to play as Rash
				if memory.read_u8(0x00002C, "WRAM") == 0 then
					-- we are on the first level
					if memory.read_u8(0x000E5E, "WRAM") > 16 then
						gui.drawText(0, 0, "Take a death and continue to go to " .. bt_snes_level_names[which_level] .. "!")
						-- write message only when Pimple hasn't yet game-overed, so there is a garbage number for health
					end
					if memory.read_u8(0x00002E, "WRAM") == 1 then
						-- Pimple just lost a continue
						memory.write_u8(0x00002C, BT_SNES_level_for_memory, "WRAM")
						-- overwrite level, and you're good to go.
						memory.write_u8(0x00002E, 3, "WRAM")
						-- bump the continue count above 2 to avoid an extra swap
					elseif memory.read_u8(0x00002E, "WRAM") == 2 then
						-- otherwise, if we just started the game and did specify a different level in the filename,
						memory.write_u8(0x000028, 0, "WRAM")
						-- set Pimple's lives to 0
						if memory.read_u8(0x000E5E, "WRAM") > 1 then
							memory.write_u8(0x000E5E, 0, "WRAM")
							-- set Pimple's health to 0
							swap_scheduled = false
							-- override the swap being scheduled for a health drop
						end
					end
				end
				
				if memory.read_u8(0x00002C, "WRAM") > 0
					and memory.read_u8(0x00002C, "WRAM") == BT_SNES_level_for_memory
					and memory.read_u8(0x00002E, "WRAM") > 2
				then
					memory.write_u8(0x00002E, 2, "WRAM")
					-- fix Pimple's continue count once you get into the correct level.
				end
			end
		end
		
		if tag == "MPAINT_DPAD_SNES" and memory.read_u8(0x000206) == 1 then
			-- give the player some Gnat Attack instructions!
			gui.drawText(0,0,"GNAT ATTACK! Dpad moves, face buttons click, hold one/both of L/R to go fast", "green")
		end
	end
end

return plugin