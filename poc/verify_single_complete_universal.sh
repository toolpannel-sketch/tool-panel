#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
file="LuaLicense-Universal-Complete.lua"

[[ $(grep -c 'MAIN LUA — PASTE FULL CODE HERE' "$file") -eq 1 ]]
[[ $(grep -c 'BEGIN MAIN LUA' "$file") -eq 1 ]]
[[ $(grep -c 'END MAIN LUA' "$file") -eq 1 ]]
[[ $(grep -c 'local function run_authorized_main_once' "$file") -eq 1 ]]
[[ $(grep -c 'local function run_authorized_main(LICENSE_SESSION, validated_key, match_number)' "$file") -eq 1 ]]

grep -Fq 'local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"' "$file"
grep -Fq 'RequestForLua(API_URL, "POST"' "$file"
grep -Fq 'Client.GetPhoneDeviceID' "$file"
grep -Fq 'device_mismatch' "$file"
grep -Fq 'device_max_reached' "$file"
grep -Fq 'gate_server_maintenance(json, response, key, on_authorized)' "$file"
grep -Fq 'fetch_active_announcement(validated_key)' "$file"
grep -Fq 'PREMIUM_LUA_UNIVERSAL.OnMatchStart' "$file"
grep -Fq 'PREMIUM_LUA_UNIVERSAL.OnMatchEnd' "$file"
grep -Fq 'PREMIUM_LUA_UNIVERSAL.IsAuthorized' "$file"

luac5.3 -p "$file"
expected_merged='bcc37a7ac09f603f456dd2ac0fb8ec837a2ac018b32bb0e7a24fe1a4773b3948'
expected_failclose='83c4022769315f8f56b20a47b28b9a397a20c0640cd6bc40514cb7d93c1b4480'
[[ "$(sha256sum /home/ubuntu/pinned-lua-references/BRPlayerCharacterBase-Merged.lua | awk '{print $1}')" == "$expected_merged" ]]
[[ "$(sha256sum /home/ubuntu/pinned-lua-references/FailClose-NoRestriction.lua | awk '{print $1}')" == "$expected_failclose" ]]

echo 'SINGLE_MAIN_INSERTION_POINT=PASS'
echo 'CANONICAL_VALIDATION_FLOW_MARKERS=PASS'
echo 'LIFECYCLE_BRIDGE_MARKERS=PASS'
echo 'LUA_SYNTAX=PASS'
echo 'OLD_REFERENCE_HASHES=PASS'
