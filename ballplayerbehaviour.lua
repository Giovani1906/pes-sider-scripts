--[[
=========================
BallPlayerBehaviour module
Research done by: AobaSuzukaze and Giovani1906 
Requires: sider.dll
Requires PES 2021 version 1.01.00
=========================
--]]

version = "1.0.0"
local settings

local RESTORE_KEY = 0x38
local PREV_PROP_KEY = 0x39
local NEXT_PROP_KEY = 0x30
local PREV_VALUE_KEY = 0xbd
local NEXT_VALUE_KEY = 0xbb

local delta = 0
local frame_count = 0

local overlay_curr = 1

local overlay_states = {
    { ui = "Unknown 00: %s", prop = "unknown_00", decr = -1.0, incr = 1.0 },
	{ ui = "Unknown 01: %s", prop = "unknown_01", decr = -1.0, incr = 1.0 },
	{ ui = "Unknown 02: %s", prop = "unknown_02", decr = -1.0, incr = 1.0 },
	{ ui = "Unknown 03: %s", prop = "unknown_03", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 04: %s", prop = "unknown_04", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 05: %s", prop = "unknown_05", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 06: %s", prop = "unknown_06", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 07: %s", prop = "unknown_07", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 08: %s", prop = "unknown_08", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 09: %s", prop = "unknown_09", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 10: %s", prop = "unknown_10", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 11: %s", prop = "unknown_11", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 12: %s", prop = "unknown_12", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 13: %s", prop = "unknown_13", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 14: %s", prop = "unknown_14", decr = -1.0, incr = 1.0 },
    { ui = "Unknown 15: %s", prop = "unknown_15", decr = -1.0, incr = 1.0 },
}

local ui_lines = {}

local bases = {
	ballplayer_addr = 0x142BEF098,
}

local game_info = {
    unknown_00 = { base = "ballplayer_addr", offs = 0x00, format = "f", len = 4, def = 60.0 },
    unknown_01 = { base = "ballplayer_addr", offs = 0x04, format = "f", len = 4, def = 40.0 },
    unknown_02 = { base = "ballplayer_addr", offs = 0x08, format = "f", len = 4, def = 30.0 },
    unknown_03 = { base = "ballplayer_addr", offs = 0x0C, format = "f", len = 4, def = 20.0 },
    unknown_04 = { base = "ballplayer_addr", offs = 0x10, format = "f", len = 4, def = 10.0 },
    unknown_05 = { base = "ballplayer_addr", offs = 0x14, format = "f", len = 4, def = 0.0 },
	unknown_06 = { base = "ballplayer_addr", offs = 0x18, format = "f", len = 4, def = 0.0 },
    unknown_07 = { base = "ballplayer_addr", offs = 0x1C, format = "f", len = 4, def = 0.0 },
    unknown_08 = { base = "ballplayer_addr", offs = 0x20, format = "f", len = 4, def = 40.0 },
    unknown_09 = { base = "ballplayer_addr", offs = 0x24, format = "f", len = 4, def = 30.0 },
    unknown_10 = { base = "ballplayer_addr", offs = 0x28, format = "f", len = 4, def = 20.0 },
    unknown_11 = { base = "ballplayer_addr", offs = 0x2C, format = "f", len = 4, def = 10.0 },
    unknown_12 = { base = "ballplayer_addr", offs = 0x30, format = "f", len = 4, def = 5.0 },
	unknown_13 = { base = "ballplayer_addr", offs = 0x34, format = "f", len = 4, def = 0.0 },
	unknown_14 = { base = "ballplayer_addr", offs = 0x38, format = "f", len = 4, def = 0.0 },
    unknown_15 = { base = "ballplayer_addr", offs = 0x3C, format = "f", len = 4, def = 0.0 },
}


local function sort_alphabetical(a, b)
    return a:lower() < b:lower()
end

local function load_ini(ctx, filename)
    local t = {}
    -- initialize with defaults
    for prop, info in pairs(game_info) do
        t[prop] = info.def
    end
    -- now try to read ini-file, if present
    local f, err = io.open(ctx.sider_dir .. "\\" .. filename)
    if not f then
        return t
    end
    f:close()
    for line in io.lines(ctx.sider_dir .. "\\" .. filename) do
        local name, value = string.match(line, "^([%w_]+)%s*=%s*([-%w%d.]+)")
        if name and value then
            value = tonumber(value) or value
            t[name] = value
            log(string.format("Using setting: %s = %s", name, value))
        end
    end
    return t
end


local function save_ini(ctx, filename)
    local f, err = io.open(ctx.sider_dir .. "\\" .. filename, "wt")
    if not f then
        log(string.format("PROBLEM saving settings: %s", tostring(err)))
        return
    end
    f:write(string.format(";BallPlayer Behaviour settings\n"))
    if settings then
    	table.sort(settings, sort_alphabetical)
    	for name, value in pairs(settings) do
    		f:write(string.format("%s = %s\n", name, value))
    	end
    else
    	table.sort(game_info, sort_alphabetical)
    	for name, value in pairs(game_info) do
    		f:write(string.format("%s = %s\n", name, value.def))
    	end
    end
    f:close()
end


local function tlog(...)
    local msg = string.format(...)
    log(string.format("%s | %s", os.date("%Y-%m-%d %H:%M:%S"), msg))
end


local function apply_settings(ctx, log_it, save_it)
	for name, value in pairs(settings) do
        local entry = game_info[name]
        if entry then
            local base = bases[entry.base]
            if base then
                local addr = base + entry.offs
                local old_value, new_value
                old_value = memory.unpack(entry.format, memory.read(addr, entry.len))
                memory.write(addr, memory.pack(entry.format, value))
                new_value = memory.unpack(entry.format, memory.read(addr, entry.len))
                if log_it then
                    log(string.format("%s: changed at %s: %s --> %s",
                        name, hex(addr), old_value, new_value))
                end
            end
        end
    end
    if (save_it) then
        save_ini(ctx, "modules\\ballplayerbehaviour.ini")
    end
end


function overlay_on(ctx)	
    -- construct ui text
    for i,v in ipairs(overlay_states) do
        local s = overlay_states[i]
        local setting = string.format(s.ui, settings[s.prop])
        if i == overlay_curr then
            ui_lines[i] = string.format("\n---> %s <---", setting)
        else
            ui_lines[i] = string.format("\n     %s", setting)
        end
    end
    return string.format([[version %s
[9][0] - choose variable, [-][+] - modify value, [8] - restore defaults
Gamepad: RS up/down - choose variable, RS left/right - modify value,
%s]], version, table.concat(ui_lines))
end


function key_down(ctx, vkey)
    if vkey == NEXT_PROP_KEY then
        if overlay_curr < #overlay_states then
            overlay_curr = overlay_curr + 1
        end
    elseif vkey == PREV_PROP_KEY then
        if overlay_curr > 1 then
            overlay_curr = overlay_curr - 1
        end
    elseif vkey == NEXT_VALUE_KEY then
        local s = overlay_states[overlay_curr]
        if s.incr ~= nil then
            settings[s.prop] = settings[s.prop] + s.incr
        elseif s.nextf ~= nil then
            settings[s.prop] = s.nextf(settings[s.prop])
        end
        apply_settings(ctx, false, true)
    elseif vkey == PREV_VALUE_KEY then
        local s = overlay_states[overlay_curr]
        if s.decr ~= nil then
            settings[s.prop] = settings[s.prop] + s.decr
        elseif s.prevf ~= nil then
            settings[s.prop] = s.prevf(settings[s.prop])
        end
        apply_settings(ctx, false, true)
    elseif vkey == RESTORE_KEY then
        for i,s in ipairs(overlay_states) do
            settings[s.prop] = game_info[s.prop].def
        end
        apply_settings(ctx, false, true)
    end
end

function gamepad_input(ctx, inputs)
    local v = inputs["RSy"]
    if v then
        if v == -1 and overlay_curr < #overlay_states then -- moving down
            overlay_curr = overlay_curr + 1
        elseif v == 1 and overlay_curr > 1 then -- moving up
            overlay_curr = overlay_curr - 1
        end
    end

    v = inputs["RSx"]
    if v then
        if v == -1 then -- moving left
            local s = overlay_states[overlay_curr]
            if s.decr ~= nil then
                settings[s.prop] = settings[s.prop] + s.decr
                -- set up the repeat change
                delta = s.decr
                frame_count = 0
            elseif s.prevf ~= nil then
                settings[s.prop] = s.prevf(settings[s.prop])
            end
            apply_settings(ctx, false, false) -- apply
        elseif v == 1 then -- moving right
            local s = overlay_states[overlay_curr]
            if s.decr ~= nil then
                settings[s.prop] = settings[s.prop] + s.incr
                -- set up the repeat change
                delta = s.incr
                frame_count = 0
            elseif s.nextf ~= nil then
                settings[s.prop] = s.nextf(settings[s.prop])
            end
            apply_settings(ctx, false, false) -- apply
        elseif v == 0 then -- stop change
            delta = 0
            apply_settings(ctx, false, true) -- apply and save
        end
    end
end


function init(ctx)
	settings = load_ini(ctx, "modules\\ballplayerbehaviour.ini")	
	ctx.register("overlay_on", overlay_on)
	ctx.register("key_down", key_down)
	ctx.register("gamepad_input", gamepad_input)
end

return {init = init}
