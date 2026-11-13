-- ISOLATED POC TEST HARNESS ONLY.
-- No production endpoints, credentials, HTTP, transport, or server code.

local UniversalLifecyclePOC = dofile("poc/LuaLicense-Universal-Lifecycle-POC.lua")

local function run_mode(mode)
  local validation_calls = 0
  local main_runs = {}
  local cleanup_runs = {}

  local main = {
    initialize = function(session_id)
      assert(session_id == "runtime-session")
    end,
    register = function(session_id)
      assert(session_id == "runtime-session")
    end,
    on_match_start = function(session_id, match_number)
      assert(session_id == "runtime-session")
      main_runs[#main_runs + 1] = match_number
    end,
    on_match_end = function(session_id, match_number)
      assert(session_id == "runtime-session")
      cleanup_runs[#cleanup_runs + 1] = match_number
    end,
  }

  local runtime = UniversalLifecyclePOC.new({
    mode = mode,
    main = main,
    validate_once = function()
      validation_calls = validation_calls + 1
      return true
    end,
  })

  assert(runtime:start_application() == true)
  assert(runtime:is_authorized() == true)
  assert(validation_calls == 1)

  for match_number = 1, 3 do
    assert(runtime:start_match(match_number) == true)
    assert(runtime:end_match(match_number) == true)
  end

  assert(validation_calls == 1, mode .. ": validation repeated during matches")
  assert(#main_runs == 3, mode .. ": expected three Main Lua runs")
  assert(main_runs[1] == 1 and main_runs[2] == 2 and main_runs[3] == 3)
  assert(#cleanup_runs == 3, mode .. ": expected cleanup for all matches")
  assert(runtime:is_authorized() == true, mode .. ": authorization lost at match end")

  runtime:restart_application()
  assert(runtime:is_authorized() == false)
  assert(runtime.authorization.session_id == nil)

  assert(runtime:start_application() == true)
  assert(validation_calls == 2, mode .. ": app restart did not require fresh validation")
  assert(runtime:is_authorized() == true)

  return {
    mode = mode,
    validation_calls = validation_calls,
    main_runs = #main_runs,
    cleanup_runs = #cleanup_runs,
    restart_revalidation = validation_calls == 2,
    trace = runtime.trace,
  }
end

local merged = run_mode("merged")
local module_mode = run_mode("module")

print("POC_STATUS=PASS")
print("MERGED_VALIDATIONS=" .. tostring(merged.validation_calls))
print("MERGED_MATCH_RUNS=" .. tostring(merged.main_runs))
print("MERGED_CLEANUPS=" .. tostring(merged.cleanup_runs))
print("MERGED_RESTART_REVALIDATION=" .. tostring(merged.restart_revalidation))
print("MODULE_VALIDATIONS=" .. tostring(module_mode.validation_calls))
print("MODULE_MATCH_RUNS=" .. tostring(module_mode.main_runs))
print("MODULE_CLEANUPS=" .. tostring(module_mode.cleanup_runs))
print("MODULE_RESTART_REVALIDATION=" .. tostring(module_mode.restart_revalidation))
