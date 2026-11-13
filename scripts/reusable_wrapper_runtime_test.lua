local wrapper_path = "BRPlayerCharacterBase-Reusable.lua"
local real_io_open = io.open
local real_print = print
local real_require = require

local function run_case(files, expected_fragment, without_http)
  local fake_files = files
  io.open = function(path, mode)
    local filename = path:match("([^/]+)$")
    local content = fake_files[filename]
    if content == nil and mode == "rb" then
      return nil, "not found"
    end

    local closed = false
    local handle = {}
    function handle:read(kind)
      assert(kind == "*a")
      return content or ""
    end
    function handle:write(_) return true end
    function handle:close() closed = true end
    return handle
  end

  _G.json = {
    encode = function(_) return "{}" end,
    decode = function(raw)
      if raw == "{not-valid-json}" then return nil end
      return { key = "VALID-KEY" }
    end,
  }
  _G.getPersistentDeviceId = function() return "test-device" end
  if without_http then
    _G.HTTP_POST = nil
  else
    _G.HTTP_POST = function() error("HTTP_POST must not run for this case") end
  end
  _G.print = function(_) end

  local ok, err = pcall(dofile, wrapper_path)
  io.open = real_io_open
  _G.json = nil
  _G.getPersistentDeviceId = nil
  _G.HTTP_POST = nil
  _G.print = real_print

  assert(not ok, "wrapper unexpectedly continued")
  assert(tostring(err):find(expected_fragment, 1, true), "unexpected error: " .. tostring(err))
end

local function run_socket_http_only_case()
  local requested
  local fake_files = { ["key.txt"] = "VALID-KEY" }
  io.open = function(path, mode)
    local filename = path:match("([^/]+)$")
    local content = fake_files[filename]
    if content == nil and mode == "rb" then
      return nil, "not found"
    end
    local handle = {}
    function handle:read(kind)
      assert(kind == "*a")
      return content or ""
    end
    function handle:write(_) return true end
    function handle:close() end
    return handle
  end

  _G.json = {
    encode = function(payload)
      assert(payload.key == "VALID-KEY")
      assert(payload.device_id == "test-device")
      return "{\"key\":\"VALID-KEY\"}"
    end,
    decode = function(raw)
      if raw == "{\"ok\":true}" then
        return { ok = true, expiresAt = "2099-01-01T00:00:00Z" }
      end
      return { key = "VALID-KEY" }
    end,
  }
  _G.getPersistentDeviceId = function() return "test-device" end
  _G.HTTP_POST = nil
  _G.print = function(_) end
  _G.require = function(name)
    if name == "socket.http" then
      return {
        request = function(options)
          requested = options
          assert(options.method == "POST")
          assert(options.headers["content-type"] == "application/json")
          assert(options.headers["content-length"] == tostring(#options.source()))
          return "{\"ok\":true}", 200, {}, "HTTP/1.1 200 OK"
        end,
      }
    end
    if name == "ltn12" then
      error("ltn12 intentionally unavailable")
    end
    return real_require(name)
  end

  local ok, session = pcall(dofile, wrapper_path)
  io.open = real_io_open
  _G.require = real_require
  _G.json = nil
  _G.getPersistentDeviceId = nil
  _G.print = real_print

  assert(ok, "LuaSocket-only wrapper execution failed: " .. tostring(session))
  assert(type(session) == "table" and session.ok == true, "unexpected license session")
  assert(requested ~= nil, "socket.http request was not called")
end

local function run_socket_failure_case(status_code, response_body, expected_fragment)
  local fake_files = { ["key.txt"] = "VALID-KEY" }
  io.open = function(path, mode)
    local filename = path:match("([^/]+)$")
    local content = fake_files[filename]
    if content == nil and mode == "rb" then return nil, "not found" end
    local handle = {}
    function handle:read(kind) assert(kind == "*a"); return content or "" end
    function handle:write(_) return true end
    function handle:close() end
    return handle
  end

  _G.json = {
    encode = function(_) return "{}" end,
    decode = function(raw)
      if raw == "{}" then return {} end
      return { key = "VALID-KEY" }
    end,
  }
  _G.getPersistentDeviceId = function() return "test-device" end
  _G.HTTP_POST = nil
  _G.print = function(_) end
  _G.require = function(name)
    if name == "socket.http" then
      return {
        request = function(_) return response_body, status_code, {}, "HTTP/1.1" end,
      }
    end
    if name == "ltn12" then error("ltn12 intentionally unavailable") end
    return real_require(name)
  end

  local ok, err = pcall(dofile, wrapper_path)
  io.open = real_io_open
  _G.require = real_require
  _G.json = nil
  _G.getPersistentDeviceId = nil
  _G.print = real_print

  assert(not ok, "wrapper unexpectedly continued on failed HTTP response")
  assert(tostring(err):find(expected_fragment, 1, true), "unexpected HTTP failure: " .. tostring(err))
end

run_case({
  ["key.json"] = "{not-valid-json}",
  ["key.txt"] = "VALID-KEY",
}, "key.json must contain a string field named key")

run_case({}, "key file not found; tried key.json, key.txt, key.in, and key.ini")
run_case({
  ["key.ini"] = "VALID-INI-KEY",
}, "HTTP adapter unavailable", true)
run_socket_http_only_case()
run_socket_failure_case(503, "{}", "key is invalid")
run_socket_failure_case(200, "", "key is invalid")

print("reusable wrapper runtime cases passed")
