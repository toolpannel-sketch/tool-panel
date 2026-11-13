-- BRPlayerCharacterBase-TransportDiagnostic.lua
-- Safe, key-free runtime diagnostic.
-- It does not read license files, scan globals/files, invoke hidden bridges,
-- or make any network request. It only checks documented Lua module imports.

local function status_line(name, ok, detail)
    local state = ok and "loaded" or "missing"
    local line = name .. " = " .. state
    if detail and detail ~= "" then
        line = line .. " (" .. detail .. ")"
    end
    print(line)
    return line
end

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local STATUS_FILE = KEY_DIR .. "/.transport_status"
local lines = {}

-- Visible marker: confirms that this file itself executed.
local EXECUTION_MARKER = "TRANSPORT_DIAGNOSTIC_STARTED"
pcall(function() print(EXECUTION_MARKER) end)

local function check_module(name)
    local ok, result = pcall(require, name)
    local detail = ""
    if not ok and type(result) == "string" then
        -- Keep diagnostics sanitized: do not print paths, secrets, or full traces.
        detail = "module unavailable"
    end
    lines[#lines + 1] = status_line(name, ok, detail)
end

check_module("ltn12")
check_module("ssl.https")
check_module("socket.http")

local summary = "TRANSPORT_DIAGNOSTIC_COMPLETE"
print(summary)

-- Best-effort status file in the same explicit license directory used by the production wrapper.
-- Failure to write does not change the diagnostic result.
local function write_status_file()
    local io_api = rawget(_G, "io")
    if type(io_api) ~= "table" or type(io_api.open) ~= "function" then return end
    local ok_file, file = pcall(io_api.open, STATUS_FILE, "w")
    if not ok_file or not file then return end
    file:write(EXECUTION_MARKER, "\n")
    for _, line in ipairs(lines) do
        file:write(line, "\n")
    end
    file:write(summary, "\n")
    file:close()
end

pcall(write_status_file)
