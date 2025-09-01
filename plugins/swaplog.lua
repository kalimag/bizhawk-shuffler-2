local plugin = {}

plugin.name = "Swap Log"
plugin.author = "kalimag"
plugin.settings = {
	{ name = 'session_timestamp', type = 'boolean', label = 'Show session timestamp on start/resume', default = true },
	{ name = 'swap_sync_marker', type = 'boolean', label = 'Show sync marker for one frame on every swap' },
	{ name = 'swap_sync_timer', type = 'boolean', label = 'Show sync timer for one frame occasionally', default = true },
}

plugin.description =
[[
	Generate logs of precise timestamps of every swap.
]]

local FILE_VERSION = "1.0"
local FILE_EXTENSION = ".tsv"
local FILE_PATH = "swaplogs"
local FILE_DATE_FORMAT = "%Y-%m-%d %H-%M-%S"
local ISO_DATE_FORMAT = "%Y-%m-%dT%H:%M:%S%z"
local SYNC_TIMESTAMP_FRAMES = 60
local SYNC_MARKER_COLOR = 0xFF0066FF
local SYNC_MARKER_SURFACE = "client"
local SYNC_TIMER_TRESHOLD = 3600.0

local logfile
local log_timestamp
local session_timestamp_remaining
local last_sync_timer
local drawing_active
local clock_base
local game_start_clock
local game_complete

local function log_format(format, ...)
	logfile:write(string.format(format, ...))
	logfile:write("\n")
end

local function close_logfile()
	if io.type(logfile) == "file" then
		logfile:close()
		logfile = nil
	end
end

local function create_new_logfile()
	close_logfile()

	local name = os.date(FILE_DATE_FORMAT, log_timestamp) .. FILE_EXTENSION
	make_dir(FILE_PATH)
	logfile = assert(io.open(FILE_PATH..'/'..name, "w"))

	log_format("#BizHawk Shuffler timestamp log from %s", os.date())
	log_format("#version=%s", FILE_VERSION)
	log_format("#start=%s", os.date(ISO_DATE_FORMAT, log_timestamp))
	log_format("#clock=%s", os.clock())
	log_format("#Game\tStart\tEnd\tSwap Frames\tGame Frames\tGame Swaps\tTotal Swaps\tSystem\tDisplay\tFramerate\tComplete")

	log_console('Saving swap log as "%s"', name)
end

local function ensure_logfile_open()
	if io.type(logfile) ~= "file" then
		create_new_logfile()
	end
end

local function clear_drawings()
	if drawing_active then
		--gui.clearGraphics(SYNC_MARKER_SURFACE)
		-- drawings from previous frames stay on screen until something else is drawn
		-- doing this instead of clearGraphics potentially avoids clobbering drawings from other plugins
		gui.drawPixel(-1, -1, 0x01000000, SYNC_MARKER_SURFACE)
		drawing_active = false
	end
end

local function draw_session_timestamp()
	session_timestamp_remaining = session_timestamp_remaining - 1

	if session_timestamp_remaining > 0 then
		local str = string.format("%s F:%i", os.date(FILE_DATE_FORMAT, log_timestamp), config.frame_count)
		gui.drawString(client.screenwidth(), client.screenheight(), str, 0xFFFFFFFF, 0xFF000000, nil, nil, nil, "right", "bottom", SYNC_MARKER_SURFACE)
		drawing_active = true
	else
		clear_drawings()
	end
end

local function draw_sync_helpers(clock, settings)
	if settings.swap_sync_marker then
		gui.drawAxis(0, 0, 3, SYNC_MARKER_COLOR, SYNC_MARKER_SURFACE)
		gui.drawAxis(client.screenwidth() - 1, client.screenheight() - 1, 3, SYNC_MARKER_COLOR, SYNC_MARKER_SURFACE)
		drawing_active = true
	end
	if settings.swap_sync_timer and os.clock() >= last_sync_timer + SYNC_TIMER_TRESHOLD then
		local str = string.format("%s C:%.3f F:%i", os.date(FILE_DATE_FORMAT, log_timestamp), clock, config.frame_count)
		gui.drawString(client.screenwidth(), client.screenheight(), str, SYNC_MARKER_COLOR, 0xFF000000,
			nil, nil, nil, "right", "bottom", SYNC_MARKER_SURFACE)
		drawing_active = true
		last_sync_timer = os.clock()
	end
end

local function start_segment(settings)
	game_start_clock = os.clock()
	game_complete = false

	if not clock_base and settings.session_timestamp then
		session_timestamp_remaining = SYNC_TIMESTAMP_FRAMES + 1
		last_sync_timer = os.clock()
	else
		draw_sync_helpers(game_start_clock, settings)
	end

	if not clock_base then
		clock_base = game_start_clock
		log_timestamp = os.time()
	end
end

local function end_segment()
	if not game_start_clock then
		return
	end

	local game_end_clock = os.clock()

	ensure_logfile_open()

	-- "Game\tStart\tEnd\tSwap Frames\tGame Frames\tGame Swaps\tTotal Swaps\tSystem\tDisplay\tFramerate\tComplete"
	log_format("%s\t%.3f\t%.3f\t%i\t%i\t%i\t%i\t%s\t%s\t%i\t%s",
		config.current_game,
		game_start_clock - clock_base,
		game_end_clock - clock_base,
		frames_since_restart,
		config.game_frame_count[config.current_game],
		config.game_swaps[config.current_game],
		config.total_swaps,
		emu.getsystemid(),
		emu.getdisplaytype(),
		client.get_approx_framerate(),
		game_complete and "Complete" or ""
	)
	logfile:flush()

	game_complete = false
	game_start_clock = nil
end

local function on_exit()
	if game_start_clock and is_rom_loaded() then
		end_segment()
	end
	close_logfile()
	clear_drawings()
end

event.onexit(on_exit)
event.onconsoleclose(on_exit)

function plugin.on_setup()
	close_logfile()
	clock_base = nil
	log_timestamp = nil
	game_start_clock = nil
	last_sync_timer = 0
	session_timestamp_remaining = 0
	clear_drawings()
end

function plugin.on_frame(_, settings)
	if frames_since_restart <= 2 then
		if frames_since_restart == 1 then
			start_segment(settings)
		else
			clear_drawings()
		end
	end

	if session_timestamp_remaining > 0 then
		draw_session_timestamp()
	end
end

function plugin.on_game_save()
	end_segment()
end

function plugin.on_complete()
	game_complete = true
end

return plugin
