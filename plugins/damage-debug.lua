local PRINT_CHANGES = true -- print changes to prevdata values
local SHOW_PREVDATA = true -- show current prevdata values on screen
local SHOW_GAMEMETA = true -- show current gamemeta values on screen
local PAUSE_ON_SWAP = true -- pause whenever a swap would occur

local MIN_FRAMES_SINCE_RESTART = 10
local DEFAULT_DELAY = 3

-- gameinfo.getromhash() to game tag
local HASH_DB = {
	["F0CC04FBEBB2552687309DA9AF94750F7161D722"] = "mm1nes"
}

-- "gameinfo.getromname() emu.getsystemid()" to game tag
local NAME_DB = {
	["Mega Man NES"] = "mm1nes"
}

-- gamemeta functions that should not be shown in the debug display
-- mostly for active functions that change data (otherwise they would be called twice)
local GAMEMETA_BLACKLIST = {
	func = true,
}

-- debug text display
local DISPLAY_X, DISPLAY_Y = 0, 0
local DISPLAY_ANCHOR = "topright"
local DISPLAY_PADDING = {0, 0, 200, 0} -- left, top, right, bottom padding

local LOG_FUNC = log_console -- or log_quiet

local UNLOAD_MODULE = true -- hack: remove plugin from Lua module cache so script changes take effect without reopening the Lua Console



local plugin = {}
plugin.name = "Damage Shuffler Debugger"
plugin.author = "kalimag"
plugin.settings = {}
plugin.description =
[[
	Debug plugin for damage/hit detection.

	Edit damage-debug.lua to insert the swap function that you want to debug.

	Turn off other damage shuffler plugins.
]]

local NO_MATCH = 'NONE'

local prevdata
local swap_scheduled
local shouldSwap
local prev_framecount
local is_rewinding
local frames_since_restart -- local value to simulate restarts
local dump_values
local gamemeta

-- optionally load BizHawk 2.9 compat helper to get rid of bit operator warnings
local bit = bit
if compare_version("2.9") >= 0 then
	local success, migration_helpers = pcall(require, "migration_helpers")
	bit = success and migration_helpers.EmuHawk_pre_2_9_bit and migration_helpers.EmuHawk_pre_2_9_bit() or bit
end

local function format_debug_value(key, value)
	if type(value) == "number" and type(key) == "string" and (key:find("addr") or key:find("hex")) then
		return string.format("%X", value)
	else
		return tostring(value)
	end
end

local function dump(value, key)
	dump_values = dump_values or {}
	if key == nil then key = #dump_values + 1 end
	dump_values[key] = value
	return value
end

-- log message including timestamp and framecount
local function log(format, ...)
	LOG_FUNC('[%s f:%d] ' .. format, os.date('%H:%M:%S'), emu.framecount(), ...)
end

-- proxy table that prints out changed values
local LoggingData = function()
	local obj = {}
	local inner_data = {}
	setmetatable(obj, {
		__index = function(_, key) return inner_data[key] end,
		__newindex = function(_, key, value)
			local prev_value = inner_data[key]
			inner_data[key] = value
			if value ~= prev_value and not is_rewinding then -- prevent log spam
				log("%s = %s (was %s)", key, format_debug_value(key, value), format_debug_value(key, prev_value))
			end
		end,
		__len = function() return #inner_data end,
		__pairs = function() return pairs(inner_data) end,
	})
	return obj
end

-- update value in prevdata and return whether the value has changed, new value, and old value
-- value is only considered changed if it wasn't nil before
local function update_prev(key, value)
	local prev_value = prevdata[key]
	prevdata[key] = value
	local changed = prev_value ~= nil and value ~= prev_value
	return changed, value, prev_value
end

local function generic_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		local currhp = gamemeta.gethp()
		local currlc = gamemeta.getlc()

		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if currhp < minhp or currhp > maxhp then
			return false
		end

		-- retrieve previous health and lives before backup
		local prevhp = data.prevhp
		local prevlc = data.prevlc

		data.prevhp = currhp
		data.prevlc = currlc

		-- Sometimes you will want to update hp and lives without triggering a swap (e.g., on swapping between characters).
		-- If a method is provided for swap_exceptions and its conditions are true, process the hp and lives but don't swap.
		if gamemeta.swap_exceptions and gamemeta.swap_exceptions(gamemeta) then
			return false
		end

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.hpcountdown ~= nil and data.hpcountdown > 0 then
			data.hpcountdown = data.hpcountdown - 1
			if data.hpcountdown == 0 and currhp > minhp then
				return true
			end
		end

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if prevhp ~= nil and currhp < prevhp then
			data.hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		if prevlc ~= nil and currlc < prevlc then
			return true
		end

		-- Sometimes you want to swap for things that don't cost hp or lives, like non-standard game overs.
		-- If a method is provided for other_swaps and its conditions are true, cue up a swap.
		if gamemeta.other_swaps then
			return gamemeta.other_swaps(gamemeta)
		end

		return false
	end
end

local function generic_state_swap(gamemeta)
	local hitstates = {}
	for _, state in ipairs(gamemeta.hitstates) do
		hitstates[state] = true
	end
	return function()
		local state_changed, state = update_prev("state", gamemeta.getstate())
		return state_changed and hitstates[state]
	end
end



local gamedata = {
	['mm1nes']={ -- Mega Man NES
		gethp=function() return memory.read_u8(0x006A, "RAM") end,
		getlc=function() return memory.read_u8(0x00A6, "RAM") end,
		maxhp=function() return 28 end,
	},
}



local function draw_debug_values()
	local msg = ""
	if SHOW_PREVDATA then
		for key, value in pairs(prevdata) do
			msg = msg .. string.format("%50s: %s\n", tostring(key), format_debug_value(key, value))
		end
	end
	if SHOW_GAMEMETA then
		for key, value in pairs(gamemeta) do
			if type(value) == "function" and not GAMEMETA_BLACKLIST[key] then
				local success, result = pcall(value, gamemeta)
				if not success and not result then result = "error" end
				msg = msg .. string.format("%50s: %s\n", tostring(key), format_debug_value(key, result))
			end
		end
	end
	if dump_values then
		for key, value in pairs(dump_values) do
			msg = msg .. string.format("%50s: %s\n", tostring(key), format_debug_value(key, value))
		end
		dump_values = nil
	end
	if msg ~= "" then
		gui.text(DISPLAY_X, DISPLAY_Y, msg, nil, DISPLAY_ANCHOR)
	end
end

local function get_game_tag()
	return HASH_DB[gameinfo.getromhash()] or
	       NAME_DB[string.format("%s %s", gameinfo.getromname(), emu.getsystemid())]
end

function plugin.on_setup()
	if UNLOAD_MODULE then
		package.loaded["plugins.damage-debug"] = nil
	end
end

function plugin.on_game_load()
	prevdata = PRINT_CHANGES and LoggingData() or {}
	swap_scheduled = false
	frames_since_restart = 0
	shouldSwap = function() return false end

	prev_framecount = emu.framecount()

	local tag = get_game_tag()

	if tag ~= nil and tag ~= NO_MATCH then
		log_console('Damage Shuffler Debugger: recognized as %s', tag)
		gamemeta = gamedata[tag]
		local func = gamemeta.func or generic_swap
		shouldSwap = func(gamemeta)
	elseif tag == nil then
		log_console('Damage Shuffler Debugger: unrecognized ROM "%s %s" (%s)',
			gameinfo.getromname(), emu.getsystemid(), gameinfo.getromhash())
		gamemeta = {}
	end

	if SHOW_PREVDATA or SHOW_GAMEMETA then
		-- shuffler disables OSD messages which annoying also hides gui.text
		client.displaymessages(true)
	end
	if DISPLAY_PADDING then
		client.SetClientExtraPadding((unpack or table.unpack)(DISPLAY_PADDING))
	end
end

function plugin.on_frame()
	frames_since_restart = frames_since_restart + 1

	-- Detect resets, savestate load or rewind (or turbo if "Run lua scripts when turboing" is disabled)
	local inputs = joypad.get()
	local new_framecount = emu.framecount()
	is_rewinding = new_framecount == prev_framecount - 1
	if inputs.Reset or inputs.Power or new_framecount ~= prev_framecount + 1 then
		prevdata = PRINT_CHANGES and LoggingData() or {} -- reset prevdata to avoid swaps
	end
	prev_framecount = new_framecount

	if swap_scheduled then
		swap_scheduled = swap_scheduled - 1
		if swap_scheduled > 0 then
			return
		else
			swap_scheduled = false
		end
	end

	local schedule_swap, delay = shouldSwap(prevdata)
	draw_debug_values()
	if schedule_swap and frames_since_restart > MIN_FRAMES_SINCE_RESTART then
		swap_scheduled = delay or DEFAULT_DELAY
		log('Damage detected, would swap in %d frames', swap_scheduled)
		gui.addmessage("Damage detected")
		-- simulate fresh plugin start
		prevdata = PRINT_CHANGES and LoggingData() or {}
		frames_since_restart = 0
		if PAUSE_ON_SWAP then
			client.pause()
		end
	end
end

return plugin
