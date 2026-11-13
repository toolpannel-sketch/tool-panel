--[=[
  PREMIUM LUA SYSTEM — UNIVERSAL LIFECYCLE TEMPLATE
  RELEASE TYPE: SEPARATE, ROLLBACK-SAFE INTEGRATION TEMPLATE

  IMPORTANT BOUNDARY
  ------------------
  This file is intentionally transport-agnostic. It does not implement or
  rewrite HTTP, HTTP watchers, transport, server connection, canonical server
  validation, host device identity, key/status parsing, Telegram, Announcement,
  or Server Maintenance. Those existing production functions must be supplied
  unchanged through the adapter contract below.

  SUPPORTED MAIN MODES
  --------------------
  merged:
    main.initialize(session_id)
    main.on_match_start(session_id, match_number)
    optional main.on_match_end(session_id, match_number)

  module:
    main.register(session_id)
    main.on_match_start(session_id, match_number)
    optional main.on_match_end(session_id, match_number)

  SECURITY/LIFECYCLE CONTRACT
  ---------------------------
  * validate_once is invoked once for this runtime object only.
  * Main Lua cannot start unless validate_once returns true.
  * Authorization remains active across match boundaries.
  * Match start is idempotent per match number.
  * Match end invokes optional cleanup once per match number.
  * app_restart clears authorization and all per-runtime guards.
  * A new runtime object is required for a new application process.
]=]

local UniversalLua = {}
UniversalLua.__index = UniversalLua

local VALID_MODES = { merged = true, module = true }

local function require_function(value, label)
  assert(type(value) == "function", label .. " must be supplied by the integration adapter")
end

local function require_table(value, label)
  assert(type(value) == "table", label .. " must be a table")
end

function UniversalLua.new(adapter)
  require_table(adapter, "adapter")
  assert(VALID_MODES[adapter.mode] == true, "adapter.mode must be 'merged' or 'module'")
  require_function(adapter.validate_once, "adapter.validate_once")
  require_table(adapter.main, "adapter.main")

  local self = setmetatable({
    mode = adapter.mode,
    validate_once = adapter.validate_once,
    main = adapter.main,
    state = {
      authorization_active = false,
      validation_attempted = false,
      validation_count = 0,
      main_initialized = false,
      session_id = nil,
      active_match = nil,
      started_matches = {},
      ended_matches = {},
    },
    trace = {},
  }, UniversalLua)

  return self
end

function UniversalLua:_trace(event)
  self.trace[#self.trace + 1] = event
end

function UniversalLua:_validate_once()
  if self.state.validation_attempted == true then
    self:_trace("VALIDATION_SKIPPED_DUPLICATE")
    return self.state.authorization_active == true
  end

  self.state.validation_attempted = true
  self.state.validation_count = self.state.validation_count + 1
  self:_trace("VALIDATION_REQUESTED")

  local ok, result = pcall(self.validate_once)
  if ok ~= true or result ~= true then
    self.state.authorization_active = false
    self:_trace("VALIDATION_REJECTED")
    return false
  end

  self.state.authorization_active = true
  self.state.session_id = "universal-runtime-session"
  self:_trace("VALIDATION_ACCEPTED")
  return true
end

function UniversalLua:_initialize_main_once()
  if self.state.main_initialized == true then
    self:_trace("MAIN_INITIALIZATION_SKIPPED_DUPLICATE")
    return true
  end

  if self.mode == "merged" then
    require_function(self.main.initialize, "adapter.main.initialize")
    self.main.initialize(self.state.session_id)
    self:_trace("MAIN_INITIALIZED_MERGED")
  else
    require_function(self.main.register, "adapter.main.register")
    self.main.register(self.state.session_id)
    self:_trace("MAIN_REGISTERED_MODULE")
  end

  self.state.main_initialized = true
  return true
end

function UniversalLua:start_application()
  self:_trace("APP_START")
  if self.state.authorization_active ~= true then
    if self:_validate_once() ~= true then
      self:_trace("MAIN_BLOCKED_NO_AUTHORIZATION")
      return false
    end
  else
    self:_trace("AUTHORIZATION_ALREADY_ACTIVE")
  end

  return self:_initialize_main_once()
end

function UniversalLua:start_match(match_number)
  assert(type(match_number) == "number", "match_number must be numeric")
  if self.state.authorization_active ~= true then
    self:_trace("MATCH_BLOCKED_NO_AUTHORIZATION")
    return false
  end

  if self.state.started_matches[match_number] == true then
    self:_trace("MATCH_START_SKIPPED_DUPLICATE_" .. tostring(match_number))
    return true
  end

  require_function(self.main.on_match_start, "adapter.main.on_match_start")
  self.state.started_matches[match_number] = true
  self.state.active_match = match_number
  self.main.on_match_start(self.state.session_id, match_number)
  self:_trace("MAIN_RAN_MATCH_" .. tostring(match_number))
  return true
end

function UniversalLua:end_match(match_number)
  assert(type(match_number) == "number", "match_number must be numeric")
  if self.state.authorization_active ~= true then
    self:_trace("MATCH_END_IGNORED_NO_AUTHORIZATION")
    return false
  end

  if self.state.ended_matches[match_number] == true then
    self:_trace("MATCH_END_SKIPPED_DUPLICATE_" .. tostring(match_number))
    return true
  end

  self.state.ended_matches[match_number] = true
  if type(self.main.on_match_end) == "function" then
    self.main.on_match_end(self.state.session_id, match_number)
    self:_trace("MAIN_CLEANUP_MATCH_" .. tostring(match_number))
  end

  if self.state.active_match == match_number then
    self.state.active_match = nil
  end
  self:_trace("MATCH_ENDED_" .. tostring(match_number))
  return true
end

function UniversalLua:restart_application()
  self:_trace("APP_RESTART")
  self.state = {
    authorization_active = false,
    validation_attempted = false,
    validation_count = 0,
    main_initialized = false,
    session_id = nil,
    active_match = nil,
    started_matches = {},
    ended_matches = {},
  }
  self.trace = { "APP_RESTART", "AUTHORIZATION_RESET" }
end

function UniversalLua:is_authorized()
  return self.state.authorization_active == true
end

function UniversalLua:get_validation_count()
  return self.state.validation_count
end

return UniversalLua
