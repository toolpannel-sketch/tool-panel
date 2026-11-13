-- BRPlayerCharacterBase-HttpPostProbe.lua
-- Safe, key-free, no-network host bridge probe.
-- It only checks whether the host exposes a global http_post function.
-- It does not call the function, send data, read license files, or scan directories.

local KEY_DIR = "/storage/emulated/0/Android/data/com.pubg.imobile/lua-license"
local STATUS_FILE = KEY_DIR .. "/.http_post_probe_status"

local function emit(line)
    pcall(function() print(line) end)
end

local function save(lines)
    local io_api = rawget(_G, "io")
    if type(io_api) ~= "table" or type(io_api.open) ~= "function" then
        return false
    end
    local ok, file = pcall(io_api.open, STATUS_FILE, "w")
    if not ok or not file then
        return false
    end
    for _, line in ipairs(lines) do
        file:write(line, "\n")
    end
    file:close()
    return true
end

local lines = { "HTTP_POST_PROBE_STARTED" }
emit(lines[1])

local bridge = rawget(_G, "http_post")
if type(bridge) == "function" then
    lines[#lines + 1] = "http_post = function"
else
    lines[#lines + 1] = "http_post = missing"
end

-- Presence alone does not prove callback semantics, so no invocation is made.
lines[#lines + 1] = "callback_contract = not_invoked"
lines[#lines + 1] = "HTTP_POST_PROBE_COMPLETE"

for i = 2, #lines do
    emit(lines[i])
end
save(lines)
