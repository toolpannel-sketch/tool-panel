--[=[
  ISOLATED PROOF OF CONCEPT ONLY
  This file is not wired into production and does not contain HTTP, transport,
  server, validation, device-ID, Telegram, Announcement, or Maintenance code.

  Purpose:
    * prove one injected validation per application runtime;
    * retain authorization across match transitions;
    * re-enter Main Lua for Match 1/2/3 without revalidation;
    * reset authorization when a new coordinator/runtime is created;
    * support two explicit Main Lua hand-off styles:
        1) merged-style: initialize(session), on_match_start(session)
        2) module-style: register(), on_match_start(session)

  The production universal template must adapt these boundaries to the host's
  real callbacks only after this POC is approved.
]=]

local UniversalLifecyclePOC = {}
UniversalLifecyclePOC.__index = UniversalLifecyclePOC

local function assert_function(value, label)
  assert(type(value) == "function", label .. " must be a function")
end

function UniversalLifecyclePOC.new(options)
  options = options or {}
  assert_function(options.validate_once, "validate_once")
  assert(options.mode == "merged" or options.mode == "module", "mode must be merged or module")
  assert(type(options.main) == "table", "main adapter must be a table")

  local self = setmetatable({
    mode = options.mode,
    validate_once = options.validate_once,
    main = options.main,
    authorization = {
      active = false,
      validation_count = 0,
      match_count = 0,
      session_id = nil,
    },
    trace = {},
  }, UniversalLifecyclePOC)

  return self
end

function UniversalLifecyclePOC:_record(event)
  self.trace[#self.trace + 1] = event
end

function UniversalLifecyclePOC:_authorize()
  if self.authorization.active then
    self:_record("VALIDATION_SKIPPED_ALREADY_AUTHORIZED")
    return true
  end

  self:_record("VALIDATION_REQUESTED")
  local ok, result = pcall(self.validate_once)
  self.authorization.validation_count = self.authorization.validation_count + 1

  if not ok or result ~= true then
    self:_record("VALIDATION_REJECTED")
    self.authorization.active = false
    return false
  end

  self.authorization.active = true
  self.authorization.session_id = "runtime-session"
  self:_record("VALIDATION_ACCEPTED")
  return true
end

function UniversalLifecyclePOC:_initialize_main()
  if self.mode == "merged" then
    assert_function(self.main.initialize, "merged main.initialize")
    self.main.initialize(self.authorization.session_id)
    self:_record("MAIN_INITIALIZED_MERGED")
    return
  end

  assert_function(self.main.register, "module main.register")
  self.main.register(self.authorization.session_id)
  self:_record("MAIN_REGISTERED_MODULE")
end

function UniversalLifecyclePOC:start_application()
  self:_record("APP_START")
  if not self:_authorize() then return false end
  self:_initialize_main()
  return true
end

function UniversalLifecyclePOC:start_match(match_number)
  assert(type(match_number) == "number", "match_number must be numeric")
  assert(self.authorization.active == true, "match cannot start without authorization")

  self.authorization.match_count = self.authorization.match_count + 1
  self:_record("MATCH_" .. tostring(match_number) .. "_START")

  if self.mode == "merged" then
    assert_function(self.main.on_match_start, "merged main.on_match_start")
    self.main.on_match_start(self.authorization.session_id, match_number)
    self:_record("MAIN_RAN_MATCH_" .. tostring(match_number) .. "_MERGED")
  else
    assert_function(self.main.on_match_start, "module main.on_match_start")
    self.main.on_match_start(self.authorization.session_id, match_number)
    self:_record("MAIN_RAN_MATCH_" .. tostring(match_number) .. "_MODULE")
  end

  return true
end

function UniversalLifecyclePOC:end_match(match_number)
  assert(type(match_number) == "number", "match_number must be numeric")
  assert(self.authorization.active == true, "match cannot end without authorization")
  self:_record("MATCH_" .. tostring(match_number) .. "_END")

  if type(self.main.on_match_end) == "function" then
    self.main.on_match_end(self.authorization.session_id, match_number)
    self:_record("MAIN_CLEANUP_MATCH_" .. tostring(match_number))
  end

  -- Authorization intentionally survives the match boundary.
  return self.authorization.active == true
end

function UniversalLifecyclePOC:restart_application()
  self:_record("APP_RESTART")
  self.authorization = {
    active = false,
    validation_count = 0,
    match_count = 0,
    session_id = nil,
  }
  self.trace = { "APP_RESTART", "AUTHORIZATION_RESET" }
end

function UniversalLifecyclePOC:is_authorized()
  return self.authorization.active == true
end

return UniversalLifecyclePOC
