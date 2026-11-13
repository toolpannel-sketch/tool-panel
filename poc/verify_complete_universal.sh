#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
file="LuaLicense-Universal-Complete.lua"

required=(
  'local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"'
  'RequestForLua(API_URL, "POST"'
  'Client.GetPhoneDeviceID'
  'device_mismatch'
  'device_max_reached'
  'gate_server_maintenance(json, response, key, on_authorized)'
  'fetch_active_announcement(validated_key)'
  'local function run_authorized_main_once'
  'local function run_authorized_main(LICENSE_SESSION, validated_key, match_number)'
  'PREMIUM_LUA_UNIVERSAL.OnMatchStart'
  'PREMIUM_LUA_UNIVERSAL.OnMatchEnd'
  'PREMIUM_LUA_UNIVERSAL.IsAuthorized'
  'validation_successes'
  'cleanup_universal_match'
)

for marker in "${required[@]}"; do
  grep -Fq "$marker" "$file" || { echo "MISSING_MARKER=$marker"; exit 1; }
done

# The original protected references must remain byte-for-byte unchanged.
expected_merged='bcc37a7ac09f603f456dd2ac0fb8ec837a2ac018b32bb0e7a24fe1a4773b3948'
expected_failclose='83c4022769315f8f56b20a47b28b9a397a20c0640cd6bc40514cb7d93c1b4480'
actual_merged=$(sha256sum /home/ubuntu/pinned-lua-references/BRPlayerCharacterBase-Merged.lua | awk '{print $1}')
actual_failclose=$(sha256sum /home/ubuntu/pinned-lua-references/FailClose-NoRestriction.lua | awk '{print $1}')
[[ "$actual_merged" == "$expected_merged" ]] || { echo "MERGED_REFERENCE_CHANGED"; exit 1; }
[[ "$actual_failclose" == "$expected_failclose" ]] || { echo "FAILCLOSE_REFERENCE_CHANGED"; exit 1; }

luac5.3 -p "$file"
echo 'COMPLETE_UNIVERSAL_STATIC=PASS'
echo 'CANONICAL_VALIDATION_MARKERS=PASS'
echo 'LIFECYCLE_BRIDGE_MARKERS=PASS'
echo 'PROTECTED_REFERENCE_HASHES=PASS'
