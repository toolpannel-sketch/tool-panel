-- b2.lua — Lua License Control Panel loader
-- Panel API: https://luapanel-8355ybgt.manus.space/v1/validate
--
-- Required runtime adapters:
--   HTTP_POST(url, json_body) -> status_code, response_body
--   json.decode(text), json.encode(table)
-- Optional:
--   getPersistentDeviceId() or getDeviceId() -> stable app/device ID
--
-- Put this file in the same Lua project as your main script, or copy its loader
-- logic into your entry Lua file. Keep main_features.lua in KEY_DIR.

local API_URL = "https://luapanel-8355ybgt.manus.space/v1/validate"
local KEY_DIR = "/storage/emulated/0/Android/data/lua-license"
local KEY_FILE = KEY_DIR .. "/key.json"
local DEVICE_FILE = KEY_DIR .. "/.device_id"
local MAIN_SCRIPT = KEY_DIR .. "/main_features.lua"

local function stop(message)
  error("[LICENSE] " .. tostring(message), 0)
end

local function read_file(path)
  local file, err = io.open(path, "rb")
  if not file then return nil, err end
  local data = file:read("*a")
  file:close()
  return data
end

local function write_file(path, data)
  local file, err = io.open(path, "wb")
  if not file then return false, err end
  file:write(data)
  file:close()
  return true
end

local function get_json()
  local decoder = rawget(_G, "json") or rawget(_G, "cjson")
  if decoder and decoder.decode and decoder.encode then return decoder end

  local ok, module = pcall(require, "cjson.safe")
  if ok and module then return module end
  ok, module = pcall(require, "cjson")
  if ok and module then return module end

  stop("JSON adapter unavailable: expose json.decode/json.encode or provide cjson")
end

local function get_device_id()
  local provider = rawget(_G, "getPersistentDeviceId") or rawget(_G, "getDeviceId")
  if type(provider) == "function" then
    local value = provider()
    if type(value) == "string" and #value > 0 then return value end
  end

  local existing = read_file(DEVICE_FILE)
  if existing and #existing > 0 then
    return existing:gsub("%s+$", "")
  end

  math.randomseed(os.time() + math.floor(os.clock() * 100000))
  local alphabet = "0123456789abcdef"
  local chars = {}
  for i = 1, 32 do
    local n = math.random(#alphabet)
    chars[i] = alphabet:sub(n, n)
  end
  local generated = table.concat(chars)
  local ok, err = write_file(DEVICE_FILE, generated)
  if not ok then
    stop("cannot save device identity at " .. DEVICE_FILE .. ": " .. tostring(err))
  end
  return generated
end

local function post_json(url, body)
  local bridge = rawget(_G, "HTTP_POST")
  if type(bridge) == "function" then
    return bridge(url, body)
  end

  local ok_http, http = pcall(require, "socket.http")
  local ok_ltn12, ltn12 = pcall(require, "ltn12")
  if ok_http and ok_ltn12 then
    local response = {}
    local code = http.request({
      url = url,
      method = "POST",
      headers = {
        ["content-type"] = "application/json",
        ["content-length"] = tostring(#body),
      },
      source = ltn12.source.string(body),
      sink = ltn12.sink.table(response),
    })
    return tonumber(code) or 0, table.concat(response)
  end

  stop("HTTP adapter unavailable: expose HTTP_POST or provide LuaSocket/ltn12")
end

local function read_key(json)
  local raw, err = read_file(KEY_FILE)
  if not raw then stop("key file not found at " .. KEY_FILE) end
  raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
  if #raw == 0 then stop("key file is empty") end

  if raw:sub(1, 1) == "{" then
    local parsed = json.decode(raw)
    if type(parsed) == "table" and type(parsed.key) == "string" then
      return parsed.key
    end
    stop("key.json must contain a string field named key")
  end
  return raw
end

local function validate()
  local json = get_json()
  local payload = json.encode({
    key = read_key(json),
    device_id = get_device_id(),
  })

  local status, body = post_json(API_URL, payload)
  local response = body and json.decode(body) or nil
  if tonumber(status) == 200 and response and response.ok == true then
    print("[LICENSE] login success; expires " .. tostring(response.expiresAt or "unknown"))
    return response
  end

  local code = response and response.error or "invalid_key"
  local messages = {
    invalid_key = "key is invalid",
    key_banned = "key has been banned",
    key_expired = "key has expired",
    device_limit_reached = "device limit reached",
    device_already_bound = "device is already bound to another key",
  }
  stop(messages[code] or ("license validation failed: " .. tostring(code)))
end

validate()

local loader, load_error = loadfile(MAIN_SCRIPT)
if not loader then
  stop("license valid, but main script could not load from " .. MAIN_SCRIPT .. ": " .. tostring(load_error))
end

return loader()
