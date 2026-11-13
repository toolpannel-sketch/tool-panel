-- Isolated regression harness for LuaLicense-Universal-Template.lua.
-- No production endpoint, network, credential, or host bridge is used.

local UniversalLua = dofile("LuaLicense-Universal-Template.lua")

local function test_mode(mode)
  local validation_calls = 0
  local main_runs = {}
  local cleanups = {}

  local main = {
    initialize = function(session_id)
      assert(mode == "merged")
      assert(session_id == "universal-runtime-session")
    end,
    register = function(session_id)
      assert(mode == "module")
      assert(session_id == "universal-runtime-session")
    end,
    on_match_start = function(session_id, match_number)
      assert(session_id == "universal-runtime-session")
      main_runs[#main_runs + 1] = match_number
    end,
    on_match_end = function(session_id, match_number)
      assert(session_id == "universal-runtime-session")
      cleanups[#cleanups + 1] = match_number
    end,
  }

  local runtime = UniversalLua.new({
    mode = mode,
    main = main,
    validate_once = function()
      validation_calls = validation_calls + 1
      return true
    end,
  })

  assert(runtime:start_application() == true)
  assert(runtime:start_application() == true)
  assert(validation_calls == 1)

  for match_number = 1, 3 do
    assert(runtime:start_match(match_number) == true)
    assert(runtime:start_match(match_number) == true)
    assert(runtime:end_match(match_number) == true)
    assert(runtime:end_match(match_number) == true)
  end

  assert(validation_calls == 1)
  assert(#main_runs == 3)
  assert(main_runs[1] == 1 and main_runs[2] == 2 and main_runs[3] == 3)
  assert(#cleanups == 3)
  assert(runtime:is_authorized() == true)

  runtime:restart_application()
  assert(runtime:is_authorized() == false)
  assert(runtime:start_match(4) == false)
  assert(runtime:start_application() == true)
  assert(validation_calls == 2)
  assert(runtime:is_authorized() == true)

  return true
end

local function test_rejected_validation()
  local calls = 0
  local runs = 0
  local runtime = UniversalLua.new({
    mode = "merged",
    validate_once = function()
      calls = calls + 1
      return false
    end,
    main = {
      initialize = function() runs = runs + 1 end,
      on_match_start = function() runs = runs + 1 end,
    },
  })

  assert(runtime:start_application() == false)
  assert(runtime:start_application() == false)
  assert(runtime:start_match(1) == false)
  assert(calls == 1)
  assert(runs == 0)
  assert(runtime:is_authorized() == false)
end

assert(test_mode("merged"))
assert(test_mode("module"))
test_rejected_validation()

print("UNIVERSAL_POC_STATUS=PASS")
print("MERGED_AND_MODULE_HANDOFF=PASS")
print("ONE_TIME_VALIDATION_PER_RUNTIME=PASS")
print("MATCH_1_2_3_REINITIALIZATION=PASS")
print("DUPLICATE_CALLBACK_GUARDS=PASS")
print("INVALID_VALIDATION_FAIL_CLOSE=PASS")
print("APP_RESTART_FRESH_VALIDATION=PASS")
