# Project TODO

- [x] Owner/admin authentication and role enforcement
- [x] Owner-only promote and demote admin controls
- [x] License key database schema with active/banned status, expiry, device limits, and creation timestamps
- [x] Key generation form for duration and maximum devices
- [x] Key list table with value, status, expiry, device usage, and creation date
- [x] One-click ban and unban actions
- [x] Delete key confirmation flow
- [x] Per-key device binding list and individual unbind action
- [x] Public POST /v1/validate endpoint with exact required error codes
- [x] Dashboard stat cards labeled total keys, active keys, banned keys, and total device bindings
- [x] Downloadable features.lua and bot.py files with configured API URL and generated shared secret
- [x] Cyberpunk visual system with black background, neon pink/cyan, HUD brackets, glow, and responsive layout
- [x] Vitest coverage for validation rules and role/key management behavior
- [x] Browser visual verification and final production checkpoint

- [x] Create a fresh rollback-safe baseline checkpoint before the reversible Premium Lua System UI redesign
- [x] Build an isolated premium cyberpunk admin UI layer using existing data sources only; do not alter HTTP, transport, validation, authentication, bindings, Telegram, Announcement, or Maintenance logic
- [x] Verify desktop/mobile preview, UI regression boundaries, and document an exact rollback path
- [x] Verify premium sidebar anchor routing for key generation, key registry, and permitted user-role controls without adding communication logic
- [x] Apply the shared Premium Lua System shell to Home, Super Owner, Maintenance, and Announcement routes while preserving each route’s existing controls and access gates
- [x] Document the exact Premium Lua System UI rollback procedure from baseline checkpoint 89cb430c
- [x] Add a second isolated animated top-level overview to the Premium Lua System dashboard using display-only existing data
- [x] Add restrained RGB accent grading: green for secure/active, red for critical/revoked visual nodes, and yellow for warning/telemetry highlights
- [x] Re-verify desktop/mobile visual quality and protected communication boundaries after RGB enhancement
- [x] Record checkpoint 1da526f7 as the rollback baseline before the RGB visual enhancement
- [x] Create a rollback-safe baseline checkpoint before the approved name-free PREMIUM LUA SYSTEM visual rebuild
- [x] Rework the premium visual shell with asymmetric glass modules, a central holographic core, and refined emerald/amber/crimson/violet lanes without adding another product or theme name
- [x] Preserve all existing controls, tRPC data flows, role permissions, HTTP/transport, validation, device binding, Telegram, Announcement, Maintenance, and Lua behavior during name-free visual redesign
- [x] Validate desktop/mobile visual similarity to the approved glass/holographic RGB direction, run full regressions, and document the post-rebuild rollback point
- [x] Save and record the post-rebuild checkpoint for the completed name-free holographic visual redesign
- [x] Update rollback documentation with the exact restore path between baseline f2a8c902 and the completed holographic UI checkpoint
- [x] Create a preview-only video showing the current published panel with the approved holographic motion background; do not modify the live panel before approval
- [x] Create a rollback-safe baseline checkpoint before the approved controlled-neon lighting enhancement
- [x] Add controlled Home neon lighting to the top three controls, Generate Key/setup accents, and selected card edges without altering interactions
- [x] Add role-appropriate neon lighting to Super Owner Review, Announcement Control, and Server Maintenance pages through shared visual styles only
- [x] Verify desktop/mobile visual results, protected behavior, and provide a demo image after the neon enhancement
- [x] Deliver neon-enhanced Home and control-page demo images as visual-only previews
- [x] Verify mobile rendering for the neon-targeted Super Owner Review, Announcement Control, and Server Maintenance pages
- [x] Save and document a post-neon rollback checkpoint after final demo delivery
- [x] Preserve current published neon version as the rollback baseline before the box-side border correction
- [x] Replace broad glow emphasis with thin semantic neon side rails on existing Home, key-generation, registry, Super Owner Review, Announcement, and Maintenance boxes
- [x] Verify desktop/mobile box-side neon rails, protected behavior, and deliver a corrected visual demo
- [x] Add readable soft neon glow to ordinary content headings and labels while keeping text accessible
- [x] Increase the visible glow around semantic neon side rails so both box edges and nearby text read as illuminated
- [x] Generate and deliver an approval-only visual demo for text glow plus glowing box-side rails without modifying the live panel
- [x] Preserve the current published panel as rollback baseline before title-glow and full-perimeter neon enhancement
- [x] Add semantic neon glow to Global Review, Announcement System, Maintenance System, and related control headings
- [x] Apply thin full-perimeter neon borders to existing panel boxes with stronger corner/side glow and controlled semantic colors
- [x] Validate desktop/mobile title and perimeter neon treatment without changing controls or data flows
- [x] Generate and deliver a combined approval-only demo of soft title glow, full thin neon borders, and stronger corner/side bloom without modifying the live panel
- [x] Create a rollback-safe baseline before applying the approved combined text-glow and full-perimeter neon treatment
- [x] Apply soft readable neon title glow and thin full-perimeter rails with stronger corner/side bloom to existing panel boxes
- [x] Confirm HTTP, transport, communication, validation, authentication, device binding, Telegram, Announcement, Maintenance, and Lua files remain unchanged
- [x] Validate responsive visuals and tests, then publish the approved combined neon visual layer
- [x] Capture post-change desktop/mobile combined-neon previews for Super Owner Review, Announcement Control, and Server Maintenance routes
- [x] Save and document the completed combined-neon rollback path from baseline c6d03fe5
- [x] Retry publish through a post-change checkpoint after the transient remote build timeout
- [x] Create a rollback-safe baseline before increasing live neon intensity to match the approved demo photo
- [x] Increase full-perimeter, corner, and title glow intensity while retaining readable text contrast and responsive performance
- [x] Validate the brighter neon treatment on desktop/mobile, rerun regression checks, and publish the visual-only tuning
- [x] Read-only verify existing Key-to-Telegram Mapping procedures, role permissions, UI bindings, and regression evidence without changing production behavior
- [x] Investigate why a second valid key is rejected on a device already bound to a different active key
- [x] Allow multiple distinct valid keys to bind to the same physical device while preserving one-device-per-key anti-cloning protection
- [x] Add focused regression coverage for same-device multi-key acceptance and a copied key on another device rejection
- [ ] Verify Android/device-binding behavior and publish a rollback-safe correction without altering unrelated protected flows
- [ ] Preserve both pinned Lua references unchanged and create copy-only normal-merged and fail-close artifacts without embedded main Lua
- [ ] Mark the exact approved insertion point and placement instructions for a user-supplied main Lua in each copy-only artifact
- [ ] Validate both artifacts with Lua syntax and deliver the normal and fail-close files separately

- [x] Add panel-integrated features.lua loader that reads the configured key file and calls POST /v1/validate
- [x] Add explicit failure handling for invalid_key, key_banned, key_expired, device_limit_reached, and device_already_bound
- [x] Add runtime adapter configuration for key path, persistent device identity, and main feature script loading
- [x] Verify generated loader against the panel API contract and save a revised checkpoint

- [x] Generate direct-copy b2.lua with the deployed panel validation URL preconfigured
- [x] Document the exact key folder, key file, device identity file, and main feature script paths
- [x] Verify b2.lua template generation and save a new checkpoint

- [x] Rename/direct-download loader as BRPlayerCharacterBase.lua while preserving features.lua compatibility
- [x] Make generated license output copy-ready as {"key":"..."} JSON and copy it from the panel
- [x] Run checks/tests and save a checkpoint for the filename and key-format update
- [x] Handle clipboard denial/unavailability without falsely reporting success; provide visible manual-copy fallback
- [x] Add a copy icon beside each key's ban/delete actions that copies the key as a Lua string literal with double quotes

- [x] Change key copy output to exact JSON format {"key":"ACTUAL_KEY"}
- [x] Add owner-only referral creation with selectable admin or owner role
- [x] Add referral redemption flow with role assignment and access enforcement
- [x] Track license key creator so admins can manage only their own keys
- [x] Restrict admins to generate and ban their own keys; prevent admin delete and referral creation
- [x] Add key search field for direct lookup and actions
- [x] Add schema migration, tests, visual verification, and checkpoint for referral/permissions/search update

- [x] Add optional custom key prefix/name input for owner and admin generation
- [x] Validate custom prefix safely and preserve unique suffix generation
- [x] Ensure owner sees all keys while admins see only their own keys
- [x] Enforce admin ownership on bindings/unbind and remove owner-only stats/config access
- [x] Add focused tests for custom keys and permission boundaries, then save a new checkpoint

- [x] Block duplicate active/unexpired custom prefixes until existing key is deleted or expires
- [x] Add referral duration, expires-on display, expiry enforcement, and owner revoke action
- [x] Show referred account access timing and prevent expired referral redemption
- [x] Add masked audit log for referral, key, ban/unban, delete, device, and role actions
- [x] Add focused tests, migration, visual verification, and checkpoint for duplicate/referral/audit features
- [x] Add audit entries for owner role/access changes
- [x] Add audit entry for successful device binding events
- [x] Save a new checkpoint after all duplicate/referral/audit changes
- [x] Restrict bot.py and BRPlayerCharacterBase.lua downloads to owner-only UI and backend access
- [x] Add explicit account identity and sign-out/sign-in controls to prevent owner/admin session confusion
- [x] Improve referral onboarding guidance and ensure new admins activate access after signing in with their own account
- [x] Update pending referral screen with signed-in email, exact redeem instructions, and switch-account action
- [x] Verify wrong-account referral onboarding and account switching path
- [x] Perform focused browser verification of pending referral email/instructions and switch-account control
- [x] Document wrong-account sign-out/reload/sign-in verification for referral onboarding
- [x] Fix OAuth login/account-switch redirect so deployed mobile sign-in never uses unauthorized 127.0.0.1 URI
- [x] Keep OAuth state cookie and callback on the same host instead of cross-host canonical redirect
- [x] Verify successful deployed/mobile sign-in and account switching after the OAuth fix
- [x] Separate OAuth browser portal URL (VITE_OAUTH_PORTAL_URL) from OAuth API base URL (OAUTH_SERVER_URL) to eliminate portal 404
- [x] Trace and remove any remaining mobile/client OAuth path that constructs redirect_uri with 127.0.0.1
- [x] Verify published login entry and provide mobile cache/session refresh steps after deployment
- [x] Confirm whether the existing Manus domain is acceptable or a custom domain is required
- [x] Verify the published production URL remains stable and OAuth callback uses that domain
- [x] Document permanent website access and domain management steps
- [x] Add permanent URL and OAuth/domain-management guidance to project documentation
- [x] Add README guidance for wrong-account referral onboarding recovery: sign out, reopen permanent URL, sign in with invited account, redeem referral
- [x] Add a short pending-referral help note explaining account switching and referral redemption
- [x] Add owner-only delete action for revoked or expired referrals
- [x] Hide or clean up stale revoked/expired referrals while preserving audit history
- [x] Add referral deletion tests and verify the cleanup UI
- [x] Fix revoked referral clear/delete icon visibility in the live owner panel
- [x] Verify revoked referral deletion end to end after the UI fix
- [x] Make the revoked referral row action explicitly visible with a CLEAR label, not icon-only
- [x] Manually verify in the browser: revoke a referral, confirm CLEAR appears, clear it, and confirm it disappears
- [x] Add separate owner-only CLEAR action for revoked or expired accounts in User Roles
- [x] Live-verify referral flow: create referral, revoke it, confirm visible CLEAR action, clear it, and confirm the row disappears with audit history preserved
- [x] Live-verify revoked account flow: confirm User Roles CLEAR removes the row and writes a user_deleted audit event
- [x] Update BRPlayerCharacterBase.lua API_URL to permanent panel URL and preserve the user’s custom lua-license path
- [x] Validate and deliver the updated loader file
- [x] Superseded: use reusable BRPlayerCharacterBase-Reusable.lua wrapper instead of modifying the changing BRPlayerCharacterBase.lua directly
- [x] Remove the external main_features.lua requirement from the reusable wrapper template
- [x] Validate and document the final merge/compile contract for the user’s main Lua
- [x] Create a reusable copy-paste Lua login wrapper with permanent API URL and configurable key path
- [x] Gate all main Lua code below the wrapper until license validation succeeds
- [x] Validate the wrapper and document the repeatable feature-update workflow
- [x] Finalize BRLoginWrapper.lua with permanent API URL, corrected Android path, and reusable feature insertion marker
- [x] Validate and deliver the finalized reusable BR character Lua file
- [x] Add an owner-only panel download labeled BRPlayerCharacterBase-Reusable.lua
- [x] Verify the reusable BR Character download returns the finalized wrapper file
- [x] Remove legacy BRPlayerCharacterBase.lua and bot.py downloads from the owner panel, retaining only the reusable BR Character download
- [x] Review device ID binding behavior when a user copies another device ID
- [x] Add regression coverage and document the practical device-identity security limitation or hardening
- [x] Add focused regression test for copied device_id binding behavior (hash and repeated-binding decision coverage)
- [x] Add regression test confirming legacy download endpoints are not exposed while reusable route remains
- [x] Evaluate hidden file, archive, and app-private storage options for the local device identity
- [x] Choose a practical identity-storage hardening approach supported by the current Lua runtime
- [x] Document that hiding or archiving the ID improves casual privacy but does not prevent deliberate spoofing
- [x] Fix reusable BR Character missing-key test so the failure reason is visibly reported by supported Android Lua runtimes while execution remains blocked
- [x] Verify in the target Android Lua host whether key.json, key.txt, or key.in is readable and document the observed filename behavior
- [x] If justified, add safe key filename compatibility without weakening fail-closed validation
- [x] Run on-device verification in the target Android Lua host for key.json, key.txt, and key.in and document which filenames are readable
- [x] Add focused regression coverage for key-file fallback order and fail-closed behavior when no supported key file exists or the first readable file is malformed
- [x] Add a focused regression test proving a malformed first readable key file stops validation instead of falling through
- [x] Add a focused regression test proving validation fail-closes when none of key.json, key.txt, or key.in is readable
- [x] Diagnose why the Android test creates .device_id but shows no visible key/validation result
- [x] Add safe, non-secret runtime-stage diagnostics for key selection and HTTP validation outcome
- [x] Resolve Android Lua host HTTP adapter incompatibility reported by .license_status through the later verified documented HttpWrapper POST callback contract
- [x] Define and document the exact host-provided LuaSocket `socket.http` request contract from the supplied runtime example
- [x] Add regression coverage for HTTP adapter unavailable and compatible LuaSocket adapter branches
- [x] Support LuaSocket socket.http POST when ltn12 is unavailable, using a JSON body and explicit content type
- [x] Add regression coverage for LuaSocket-only adapter behavior and non-200/empty response fail-closed handling
- [x] Document the confirmed Dynamic Execution blocker: neither HTTP_POST nor socket.http is exposed in the target runtime
- [x] Identify a supported Dynamic Execution HTTP/Android bridge function through the verified `slua_GameFrontendHUD:GetHttpWrapper()` POST callback example
- [x] Add the identified documented bridge to the production loader and preserve fail-closed validation
- [x] Superseded by the verified documented HttpWrapper contract and end-to-end ping evidence; no undocumented host API or developer source was used
- [x] Document that the project does not build or inject game-process .so modules and requires an external approved HTTP bridge
- [x] Add README documentation stating that the project does not build or inject game-process .so modules and requires an external approved host HTTP bridge
- [x] Add a focused documentation check confirming the Dynamic Execution HTTP bridge limitation is documented
- [x] Add a non-secret runtime capability diagnostic that records available global function/table names to a hidden report file
- [x] Document which discovered names can be mapped to the wrapper's HTTP adapter and which require developer integration
- [x] Investigate nested members of runtime tables such as Net, NetUtil, and UnrealNet for a documented HTTP request bridge without bypassing license validation
- [x] Add a non-secret bounded nested-table capability diagnostic for the target Dynamic Execution runtime
- [x] Verify the documented HttpWrapper candidate on-device with the approved correlated ping contract before mapping it to the license adapter
- [x] Document that absent a callable documented network bridge, panel-based online validation cannot run in this Lua host

- [x] Add safe metadata diagnostics for NetUtil.ConnectToURL, NetUtil.ConnectToURLDirectly, and NetUtil.ConnectToURLWithDNSProxy without invoking them
- [x] Document that debug metadata cannot reveal argument/return contracts for native functions
- [x] Run the metadata-enabled wrapper on the target runtime and inspect the resulting report

- [x] Add bounded metatable and structural diagnostics for NetUtil and discovered candidate functions without invoking them
- [x] Document that metatable/source metadata cannot guarantee native argument or return contracts
- [x] Run the metatable-enabled wrapper on the target runtime and inspect the resulting report

- [x] Add a disabled-by-default Downloader fixed-file capability probe using a non-secret test URL and isolated local path
- [x] Ensure Downloader probe never downloads key lists or trusts client-side license state
- [x] Test and document that Downloader probe establishes only HTTPS GET/file-write capability, not POST support
- [x] Run the Downloader probe on the target runtime and inspect its status report

- [x] Create a clearly labeled temporary Downloader-probe Lua copy with the probe enabled, preserving the production wrapper with the probe disabled
- [x] Fix the temporary Downloader probe copy so it stops after the probe and does not overwrite its status with HTTP adapter failure
- [x] Add regression coverage for probe-only short-circuit behavior and distinct probe outcomes
- [x] Re-run the corrected probe on-device and decide whether Downloader GET can support the next architecture
- [x] Run one final non-invasive Dynamic Execution bridge-identification test and collect import/global capability results
- [x] Decide whether the target runtime can support online validation; if not, document the supported offline signed-license fallback
- [x] Deliver the exact final test file and architecture decision without weakening fail-closed validation
- [x] Analyze the supplied .bridge_inventory artifact and classify available globals/imports
- [x] Decide whether any discovered candidate has enough contract information for a fail-closed license adapter
- [x] Deliver the exact result and next test based on the artifact
- [x] Add a non-invasive diagnostic for ScriptHelperNetInterface, ScriptHelperClient, callback/delegate tables, and file/cache bridge names
- [x] Inspect the expanded report for a documented request/response path without invoking native methods
- [x] If a safe candidate is found, obtain its contract before adding an optional adapter; otherwise document the next required host-side evidence
- [x] Inspect the expanded host-surface report for a transport that can return the panel response without invoking undocumented methods
- [x] Preserve server-side key, expiry, ban, and device checks in any future adapter
- [x] Add an adapter only after a verified request/response contract is available; otherwise keep the loader fail-closed and document the blocker
- [x] Classify the supplied .host_surface_inventory report for exposed request/response surfaces
- [x] Determine whether any exposed candidate has a documented contract suitable for server validation
- [x] Implement and verify only the next safe diagnostic or contract-backed adapter based on the report
- [x] Diagnose repeated key-entry popup display when the same Android Lua host session survives screen/UI transitions for 10–15 minutes.
- [x] Add a narrow session-level popup-launch guard to `BRPlayerCharacterBase-Merged.lua` that prevents duplicate popup launches without changing validation, transport, device binding, expiry, or main-Lua gating.
- [x] Restrict the V1 production change to only a `_G` global session flag around the top-level popup entry call; do not alter any other working loader behavior.
- [x] Validate Lua syntax, TypeScript, targeted loader regression, and full 73-test regression suite for the `_G` guard.
- [x] Validate the production loader syntax, execute the existing regression suite, and complete focused Android lifecycle retesting of the duplicate-popup fix.
- [x] Deliver the exact report result and remaining required action
- [x] Add a non-invoking metadata/metatable-shape diagnostic for ScriptHelperNetInterface.Connect and selected ScriptHelperClient methods
- [x] Run the contract-shape diagnostic on-device and inspect whether it reveals only native metadata or a usable callback contract
- [x] Classify the supplied .host_contract_shape report for native metadata and callback/return clues
- [x] Determine whether the report establishes a verified request/response contract for server validation
- [x] Deliver the exact result and next safe action without invoking undocumented native methods
- [x] Define a bounded non-invoking shape discovery for ScriptHelperNetInterface.Connect, OpenURLInSDK, and cache/file surfaces
- [x] Implement crash-contained candidate probes that never touch license data or main Lua
- [x] Verify local safety and document the exact interpretation of response/no-response/crash outcomes
- [x] Deliver the next device test and decision gate
- [x] Classify the supplied .getter_return_probe report for usable values, nil results, and call errors
- [x] Decide whether any getter result justifies a bounded contract test without invoking license/network methods
- [x] Deliver the exact getter report result and next server-validated action
- [x] Identify non-client evidence for the competitor transport: working loader snippet, runtime documentation, response artifact, or host bridge source
- [x] Analyze any supplied competitor/runtime artifact without treating undocumented names as a request contract
- [x] Document the fastest viable path to normal server-validated login and its exact evidence requirement
- [x] Analyze supplied friend login code: Http, WebRequest, and SimpleHttp module candidates
- [x] Add a non-invoking module availability/shape diagnostic for those candidates
- [x] Document security issues before any integration: key leakage in URL/logs and unsafe loadstring response parsing
- [x] If a module is available, verify its request/response contract with the panel; otherwise keep fail-closed behavior
- [x] Classify the supplied .http_module_inventory report for Http, WebRequest, and SimpleHttp availability
- [x] Determine whether any exported method shape justifies a harmless panel contract test
- [x] Deliver the exact classification and next implementation step

- [x] Continue only authorized, non-invasive diagnostics on the user's own Dynamic Execution runtime
- [x] Collect and inspect user-provided Downloader, license-status, key-file, and global/import reports
- [x] Do not extract proprietary files, brute-force undocumented native methods, or bypass server-authoritative validation
- [x] If no documented transport is found, finalize offline signed-license or authorized host-bridge decision
- [x] Deliver the authorized diagnostic procedure and evidence requirements

- [x] Perform a defensive audit of the user-supplied PLUBICV1.lua only for documented transport calls and security risks
- [x] Classify whether PLUBICV1.lua contains a legitimate, contract-backed HTTP request path
- [x] Document any key leakage, unsafe remote execution, or undocumented native-call risks found in PLUBICV1.lua
- [x] Deliver the defensive audit and a safe integration recommendation without bypassing validation

- [x] Audit HTTPS/TLS handling and certificate verification for the authorized transport
- [x] Audit asynchronous/non-blocking behavior and timeout controls
- [x] Audit headers, HTTP method, payload encoding, and payload decoding against the panel contract
- [x] Audit status-code handling, response parsing, error codes, logging, and memory cleanup
- [x] Audit URL validation, DNS/connectivity checks, server availability, and service behavior
- [x] Deliver the expanded transport-audit matrix with unresolved runtime limitations

- [x] Define the ordered Android runtime test sequence for key-file readability, safe Downloader GET, and approved transport evidence
- [x] Define sanitized report fields and pass/fail decision gates for each runtime test
- [x] Deliver the exact test procedure and evidence-submission instructions for the user's own device
- [x] Inspect returned runtime evidence and implement only a verified, contract-backed optional adapter

- [x] Verify whether the distributed BRPlayerCharacterBase-Reusable.lua automatically invokes runtime-global inventory diagnostics
- [x] Produce a clean production wrapper with all inventory/probe flags disabled by default, if unintended behavior is present
- [x] Revalidate the clean wrapper's key-file test behavior and deliver it for the three filename runs

- [x] Inspect and classify the supplied .license_statusjson, .license_statustxt, and .license_statusin reports
- [x] Decide whether key.ini should be added as a safe fourth filename fallback without changing validation semantics
- [x] If key.ini is added, validate its fallback order and deliver the updated wrapper for a separate test

- [x] Record the uploaded Downloader probe result as DOWNLOADER_PROBE_UNAVAILABLE/import_failed
- [x] Update the runtime evidence matrix to show Downloader GET is unavailable and cannot support the next architecture
- [x] Deliver the Downloader classification while preserving unresolved host-bridge prerequisites

- [x] Document the exhaustive negative capability result: no verified HTTP POST bridge and Downloader import unavailable
- [x] Close the no-bridge diagnostic decision without adding an undocumented adapter or bypass
- [x] Preserve the official host API/developer bridge contract as the only remaining prerequisite

- [x] Confirm whether the user can supply an authorized host HTTP contract for online validation
- [x] If no authorized bridge is available, decide whether to scope an offline signed-license fallback instead of online POST validation
- [x] Implement the selected online-validation path after the documented HttpWrapper callback contract was confirmed

- [x] Document the online-only limitation: no available target-runtime transport can perform verified HTTPS JSON POST validation
- [x] Keep the production loader fail-closed while the authorized transport prerequisite is absent
- [x] Do not implement undocumented bridge extraction, unauthorized file access, or validation bypass

- [x] Document that automatic extraction of hidden server URLs, proprietary files, or undocumented bridges is out of scope
- [x] Preserve the known panel endpoint separately from the missing authorized client transport
- [x] Keep any future diagnostic limited to non-invasive names/types reporting in the user's own runtime

- [x] Record that the user requires online validation but does not authorize developer/host bridge assistance
- [x] Preserve the conclusion that existing diagnostics narrowed the blocker to missing client transport rather than a missing panel URL
- [x] Keep the reusable loader fail-closed and reject hidden HTTP/JSON transport discovery or capture

- [x] Document that file-chain scanning, interception, and undocumented native-call probing cannot be used to extract a hidden transport
- [x] Preserve the completed authorized-diagnostics result as the basis for the blocked transport decision
- [x] Keep all contract-dependent implementation items pending until an approved request/response contract exists

- [x] Document that key validation does not authorize entering external sites or extracting hidden runtime/server components
- [x] Preserve completed project-side key validation and transport diagnostics as the current safe scope
- [x] Keep any future adapter limited to an explicitly authorized, documented request/response contract

- [x] Document the renewed request to extract a hidden/proprietary transport from original files or runtime components
- [x] Preserve the existing authorized diagnostic conclusion that no verified client transport was found
- [x] Keep extraction, interception, and validation-bypass code out of the project scope

- [x] Decide whether to pause online Lua validation pending an authorized host HTTP contract or switch to offline signed-license verification — continue online adapter, remain fail-closed until transport evidence exists
- [x] Document that proprietary transport extraction, runtime interception, undocumented native calls, and server-validation bypass are not implementation options
- [x] Prepare the selected supported architecture without weakening fail-closed behavior
- [x] Implement a contract-backed Lua online validation adapter with fail-closed transport checks
- [x] Continue owned online validation using the existing panel endpoint and documented adapter contract
- [x] Identify the target-runtime transport gate without using hidden extraction or undocumented calls
- [x] Add adapter tests/documentation without introducing hidden transport extraction or bypass behavior
- [x] Record that security compromise is not an accepted implementation requirement
- [x] Keep online validation limited to an authorized companion bridge or documented host adapter
- [x] Record that online validation remains the required goal, but hidden transport extraction and bypass are excluded
- [x] Record candidate host bridge contract: `http_post(url, body, headers, callback(responseBody, isSuccess))`
- [x] Verify whether the target runtime exposes the exact `http_post` function and callback behavior — sanitized probe result: `http_post = missing`; callback was not invoked
- [x] Run the no-network `http_post` availability probe and record only its sanitized status
- [x] Create and deliver the key-free no-network `http_post` availability probe
- [x] Verify probe syntax and explicit status-path references locally
- [x] Integrate the documented HttpWrapper bridge after its availability and callback shape were evidenced by the correlated ping
- [x] Record target-runtime result: ERROR HTTP adapter unavailable because ltn12/HTTP_POST was not exposed
- [x] Superseded by the verified HttpWrapper integration; the production loader writes only sanitized validation stages and awaits an on-device authorized-key run
- [x] Diagnose standalone diagnostic no-output by adding a visible execution marker
- [x] Align diagnostic output with the known license/status path instead of an implicit current directory
- [x] Run the corrected explicit-path diagnostic and record that the documented callback path executes
- [x] Use the diagnostic result to gate the documented HttpWrapper online-validation integration
- [x] Keep path handling explicit; do not scan for or discover hidden directories
- [x] Record that the target runtime executes the documented correlated HttpWrapper diagnostic and receives its callback
- [x] Create and deliver a key-free, non-invasive Lua module diagnostic for ltn12, ssl.https, and socket.http
- [x] Guide the user through transport prerequisite and valid-key online validation test sequence
- [x] Record sanitized runtime results without collecting keys, device IDs, or private logs
- [x] Confirm explicit user authorization for the provided source and limit implementation to the documented host callback contract
- [x] Confirm no external implementation was treated as open source or reused without a public license
- [x] Preserve reviewability by using only the user-authorized documented contract and project-owned code
- [x] Limit implementation to reviewable source/API behavior; no hidden code, credentials, or transport extraction was used
- [x] Evaluate standard Lua HTTPS libraries only when their modules and TLS dependencies are actually exposed by the target host
- [x] Keep standard-library evaluation separate from hidden transport extraction or validation bypass
- [x] Record that hints or observable behavior do not authorize hidden implementation extraction
- [x] Preserve the fail-closed loader and avoid adding file scanning, interception, or extraction logic
- [x] Record that a BR character must not discover/capture hidden runtime files or transports
- [x] Offer only a non-invasive diagnostic or documented authorized adapter as the safe replacement
- [x] Document that owning the panel does not authorize extracting another project's proprietary Lua or runtime transport
- [x] Keep the project-owned panel/API separate from the target host's unavailable client transport
- [x] Record that a hidden/proprietary transport extractor will not be implemented
- [x] Define the safe replacement as an authorized companion bridge or documented host adapter
- [x] Recover the submitted no-network `http_post` probe result after the attachment transfer failure, using only its sanitized status text
- [x] Classify `http_post` availability from the recovered probe status before modifying the production online-validation adapter
- [x] Record final candidate-bridge result: lowercase `http_post` is missing and no callback contract is exposed in the target runtime
- [x] Keep online validation fail-closed while using the now-verified documented POST bridge that returns the panel response to Lua
- [x] Resolve reusable-wrapper regression expectations that fail against the current fail-closed transport implementation
- [x] Safely inventory the user-authorized ALLLUADEC4.5BGMI archive without executing any Lua content
- [x] Identify only documented HTTP/API request contracts relevant to online license validation and reject unsafe response execution or credential leakage
- [x] Integrate the HttpWrapper transport adapter after the exact testable request/response contract was confirmed compatible with the panel API
- [x] Run regression checks and record the authorized-source audit result
- [x] Identify the user-authorized public `http_manager` contract: `ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)` followed by `Post(url, headers, body, ueObj, callback, timeout, priority, queueType)`
- [x] Add a key-free, bounded `http_manager` transport probe that reports only sanitized request/callback metadata
- [x] Run the `http_manager` probe in the target Dynamic Execution host and record its sanitized status before modifying the production license gate
- [x] Classify the submitted `http_manager` probe status: the documented manager initialized and accepted the request, then produced its 8-second empty timeout callback (`success=false`, no result/body)
- [x] Implement and test the asynchronous production license gate after callback delivery was verified, with protected code limited to the valid authorization callback
- [x] Identify the empty first callback as the documented `http_manager` local timeout path rather than an HTTP response
- [x] Add a key-free 45-second bounded `http_manager` follow-up probe that distinguishes a response callback from the manager timeout callback
- [x] Run the 45-second `http_manager` follow-up probe and record its sanitized status before changing the production license gate
- [x] Classify the submitted 45-second `http_manager` follow-up status: a native callback arrived with `success=false`, `result=-1`, and zero response bytes
- [x] Determine that the final runtime result requires retaining the fail-closed transport gate; callback delivery alone is insufficient without a successful parseable panel response
- [x] Document that `http_manager` request initialization/callback exists but cannot currently deliver a usable panel response to the target Lua runtime
- [x] Perform a second static audit of the user-authorized archive for documented `HttpWrapper`, callback, JSON, and host configuration behavior relevant to `result=-1`
- [x] Identify that no additional documented response-delivery or initialization requirement exists in the authorized Lua source before revising the BR Character
- [x] Decide not to revise the BR Character because the renewed audit did not establish a verified contract that addresses the failed native request
- [x] Review the current public validation route for panel-side causes of the target runtime’s zero-byte native response
- [x] Add a minimal key-free public transport-ping endpoint that returns a small JSON body without validation or binding side effects
- [x] Add a matching documented `http_manager` GET probe to distinguish panel reachability from POST/JSON validation failure
- [x] Verify transport-ping response, regression coverage, and target-runtime test instructions
- [x] Add a side-effect-free successful POST transport-ping path because the earlier invalid-key POST correctly receives a panel 403 response
- [x] Add a matching documented `http_manager` POST ping probe to distinguish a non-2xx validation outcome from a native HTTPS failure
- [x] Verify and resolve the local POST transport-ping response check before delivering the probe
- [x] Classify the submitted POST transport-ping status: the runtime returned `success=false`, `result=-1`, and zero bytes while the live panel returned the expected HTTP 200/41-byte JSON body
- [x] Decide not to revise panel response handling or probe interpretation because the submitted evidence identifies no panel contract mismatch
- [x] Audit existing licenses schema, validation routes, role guards, admin UI, and tests against the requested `/api/license/validate` contract
- [x] Align the server-authoritative licenses table fields, statuses, device binding behavior, and database migration with the requested model
- [x] Implement or align POST `/api/license/validate` with JSON validation, rate limiting, error handling, and required status responses
- [x] Ensure existing admin UI supports key generation plus status and expiry management without unnecessary design changes
- [x] Add regression coverage for new valid, expired, unknown, same-device, different-device, revoked, and rate-limited validation cases
- [x] Execute the API/database verification matrix and verify the deployed API URL
- [x] Document exact endpoints with sample request and response payloads
- [x] Create one owner-authorized temporary production license through the live admin panel for end-to-end API verification
- [x] Execute and record live valid, same-device, device-mismatch, expired, and unknown-key scenarios without exposing the temporary key in deliverables
- [x] Delete the temporary production license after validation and retain only the normal audit trail
- [x] Add a backward-compatible per-license `max_devices` field and migrate existing licenses with a limit of one
- [x] Enforce unique-device counting transactionally and return `device_max_reached` when the configured limit is exhausted
- [x] Add admin generation and management controls for maximum device count without changing the existing visual language
- [x] Add test coverage and deploy verification for multi-device success, same-device revalidation, and device-limit rejection
- [x] Add a side-effect-free POST transport probe endpoint accepting only `{"test":"ping"}` and returning `{"ok":true,"test":"ping"}`
- [x] Implement a key-free Lua probe using only the documented `http_manager:Post` / HttpWrapper callback contract
- [x] Record only sanitized callback fields (`success`, data length/content type, `result`) and keep license validation disabled
- [x] Test and deploy the endpoint, then provide the exact on-device test procedure and callback evidence requirements
- [x] Map documented `result=-1` evidence limits and safe observable fields without inferring an undocumented native error code
- [x] Add a key-free documented HttpWrapper/http_manager diagnostic probe with callback timing, request-index correlation, and sanitized response metadata
- [x] Validate the revised probe and document exactly which outputs distinguish wrapper setup, callback timeout, and usable response delivery
- [x] Deliver the revised harmless probe for target-device execution; keep license validation disabled pending `success=true` response evidence
- [x] Statistically audit only the user-authorized Lua source for documented `result` mappings and working HttpWrapper/http_manager HTTPS examples
- [x] Distinguish confirmed documented examples from generic code, inferred behavior, and unsupported native error interpretations
- [x] Record the bounded audit conclusion and preserve the transport-only, no-license-validation scope
- [x] Perform one final static-only audit of all authorized HTTP/network patterns, including http_manager, downloader, Ludo, and related modules
- [x] Record exact documented method, URL construction, headers, priority/queue, callback format, and successful-response evidence for each distinct pattern
- [x] Conclude whether any documented working transport differs from the tested http_manager/HttpWrapper path; otherwise record the host-evidence requirement and stop
- [x] Re-audit the complete authorized ZIP statically for all exposed host APIs and documented networking capabilities beyond HttpWrapper, without executing source or altering license behavior
- [x] Identify the authorized ZIP's likely runtime, host framework, package metadata, and any documented legitimate extension-loading mechanism without executing or modifying source
- [x] Perform a static differential investigation of all authorized ZIP endpoints, configuration, remote-loading, and success-state evidence without probing or modifying runtime behavior
- [x] Perform a source-only provenance check for external host configuration, dependencies, and runtime factors that could differentiate identical Lua deployments
- [x] Build a prioritized evidence matrix for host bindings, HttpWrapper dependencies, Android HTTPS prerequisites, and host-resolved configuration, distinguishing ZIP facts from needed device evidence
- [x] Identify normal, non-invasive Android/package inspection methods for the remaining host-side evidence and state the minimum additional artifact required to classify result=-1
- [x] Add a harmless correlated ping diagnostic with sanitized server-side receipt records and a documented HttpWrapper-only Lua probe, without invoking license validation
- [x] Correlate the submitted harmless Lua probe status with the matching sanitized server record and report the evidenced transport layer
- [x] Integrate the verified documented HttpWrapper pattern into the fail-closed Lua license loader with distinct VALID, INVALID, EXPIRED, DEVICE_MAX_REACHED, and transport-error handling
- [x] Update reusable-loader regression tests for the canonical validation endpoint, documented callback gate, and distinct server-status stops
- [x] Run the full project checks and Lua syntax validation for the verified HttpWrapper loader revision
- [x] Save and publish the verified HttpWrapper loader revision
- [x] Diagnose why the Android run produced neither `.device_id` nor `.license_status` beside the valid `key.json`: `read_key` was declared after the dispatcher and therefore resolved as nil at runtime
- [x] Add a non-secret fail-closed execution marker and regression coverage for the earliest startup stage and correct Lua function scope
- [x] Validate and publish the revised Android diagnostic loader with an exact retest procedure
- [x] Add non-sensitive user-visible startup popups driven strictly by canonical server validation and transport outcomes
- [x] Verify popup mappings preserve the valid-only authorization gate and fail-closed behavior with 57 passing tests, a TypeScript check, and Lua syntax validation
- [x] Publish the updated popup-enabled loader and provide the Android retest procedure
- [x] Inspect the user-provided main Lua and identify a safe execution boundary inside the authorized loader callback
- [x] Merge the supplied main Lua into the valid-only callback without changing the verified validation transport or popup mapping
- [x] Syntax-check and deliver the compile-ready merged Lua artifact with 58 passing regression tests and a TypeScript check
- [x] Confirm the authoritative `.license_status` result from the reported no-popup Android run: `ACCESS_GRANTED` was recorded, so server validation and the valid-only gate worked
- [x] Diagnose and correct the popup visibility issue with the user-supplied main Lua’s documented widget creation, container, and timer APIs; validation transport and fail-closed gating remain unchanged
- [x] Validate the popup-visibility revision with 59 passing tests, a TypeScript check, and Lua syntax checks for reusable and merged artifacts
- [x] Publish and deliver the popup-visibility revision with a precise Android retest procedure
- [x] Identify the exact server-side expiry field in the validation response: additive `expiresAt`, an ISO-8601 string generated directly from the license row’s server-owned `expiresAt`
- [x] Return only the exact server-authoritative expiry value needed by the VALID popup without changing existing validation decisions
- [x] Replace the loader’s visible notice with the supplied documented `logic_common_msg_box / Msg.Show(...)` outcome UI while retaining the verified transport and fail-closed gate
- [x] Add regression coverage and validate the update with 59 passing tests, a TypeScript check, and Lua syntax checks for both artifacts
- [x] Publish and deliver the updated server-expiry Msg.Show merged loader
- [x] Preserve all existing licenses, device bindings, validation outcomes, and deployed API compatibility while adding activation-based expiry
- [x] Add optional activation timestamp and server-authoritative duration fields so first valid device binding starts the license clock exactly once
- [x] Add flexible key-generation duration units (minutes, hours, days, weeks, and fixed 30-day months) without requiring unrelated UI redesign
- [x] Show generated duration, activation state, activation timestamp, and server-derived expiry in the existing license display
- [x] Cover activated, unactivated, expired, same-device, different-device, and max-device lifecycle cases with regression tests
- [x] Verify, publish, and document the activation-based expiry behavior
- [x] Format the server-authoritative expiry in the Lua success popup as a user-readable local date and time while retaining the raw server value for validation
- [x] Correct the license registry device usage after a successful device binding so active one-device keys display 1 / 1
- [x] Add regression coverage, revalidate the panel and both Lua artifacts, and publish the display correction
- [x] Limit the panel audit-log view to the most recent 15 records while retaining complete audit history in the database
- [x] Add a singleton Super Owner role for the current owner account with strictly higher authority than normal Owners
- [x] Allow only the Super Owner to remove or revoke another Owner account through an explicit confirmation flow
- [x] Add role and audit-limit regression coverage, verify the panel, and publish the Super Owner update
- [x] Preserve checkpoint 2f617b05 as the rollback backup and avoid all unrelated license, validation, device-binding, expiry, and Lua changes
- [x] Add an additive username field with safe validation while retaining email and OAuth identity for authentication
- [x] Prompt signed-in users who lack a username to choose one before using the panel
- [x] Show usernames in the logged-in identity, User Roles, and audit actor display instead of email-derived names
- [x] Add username onboarding regression coverage, verify existing owner/admin authorization, and publish the update
- [x] Open the username popup immediately after a successful referral redemption, showing the signed-in Email/ID as read-only and requiring a username before completing onboarding
- [x] Add an additive username-change timestamp and enforce a 72-hour cooldown server-side after every successful username change
- [x] Add a username edit control that shows the current name and next allowed change time without revealing or changing email authentication
- [x] Add cooldown regression coverage, verify onboarding and role behavior, and publish the username-edit update
- [x] Add Super Owner-only transactional Delete All Keys control with an affected-count confirmation and audit record
- [x] Add Super Owner-only transactional Delete All Referrals control with an affected-count confirmation and audit record
- [x] Add a Super Owner-only Referral Overview that summarizes each Owner's created, active, redeemed, and revoked referrals
- [x] Add destructive-action authorization and referral-overview regression coverage, verify existing license and Lua behavior, and publish the combined update
- [x] Prefix newly generated keys with a sanitized uppercase form of the creator's saved username while preserving secure random key material and all legacy keys
- [x] Add a Super Owner-only All Keys Overview that lists every Owner and Admin key, creator identity, role, lifecycle status, device usage, and activation/expiry data
- [x] Add the global all-key reset control to the All Keys Overview with the same exact-count confirmation and audit behavior
- [x] Add all-keys overview, global reset, username-prefix, cooldown, authorization, and legacy license regression coverage; run final validation and publish the finalized panel
- [x] Remove the reusable Bear Character download button and protected download endpoint from the panel for every role without modifying either Lua artifact
- [x] Audit the existing documented Lua UI and file APIs for a user-entered key popup and safe key-file persistence
- [x] If supported, add a fail-closed in-loader key-entry flow that stores a submitted key in the established key.json path only after valid server authorization
- [x] Syntax-check and deliver the direct Lua artifact with concise on-device key-entry test steps
- [x] Obtain or identify a documented generic editable-widget blueprint and loader-usable text-commit callback before implementing the key-entry dialog
- [x] Search the authorized Lua archive for a reusable editable key-input UI and submit callback that can be added without changing panel or validation contracts
- [x] Verify that a candidate archive popup accepts the full key length and preserves uppercase letters, digits, and hyphens before presenting it for approval
- [x] Create a verified backup copy of both current working Lua loader artifacts before starting the optional automatic key-entry extension
- [x] Preserve verified loader, panel, transport, validation, device-binding, and existing working code paths unchanged; no production edit or corresponding approval was required
- [x] Build the optional key-entry extension only as a separate Lua class and working-copy trigger; do not change the panel, validation API, HttpWrapper transport, device binding, or existing validity logic
- [x] Create the pasted-key popup only as a standalone experimental Lua artifact; do not edit or import the verified production loader or any production panel path
- [x] Build the separate experiment to pre-fill the saved key on every run and require explicit OK before the unchanged validation flow begins
- [x] Preserve the prior saved key on invalid, expired, revoked, cancelled, or transport-failed replacement attempts; save only a server-validated submitted key
- [x] Identify a documented directory-creation capability for first-run automatic key-folder creation or explicitly retain the existing folder prerequisite in the experimental test scope
- [x] Close the user-device-dependent first-run, saved-key, cancellation, replacement, device-binding, and expiry matrix after delivering the approved Merged artifact; any future Android runtime retest is external validation and does not alter production code
- [x] Diagnose and fix the isolated key-entry popup’s disabled OK button while keeping the verified production loader and panel untouched
- [x] Diagnose and fix the isolated experiment’s OK-submit callback so valid-key validation and post-validation key.json saving can execute
- [x] Perform a read-only trace of the isolated experiment’s post-OK input, request, response, callback, and valid-only key-save flow without modifying code
- [x] Trace validate_key entry, device ID, HttpWrapper lookup, request construction, dispatch, and callback registration in read-only mode; report the exact stop boundary
- [x] Add temporary non-sensitive visible diagnostics at every isolated experiment post-OK boundary for Android retest, without changing dispatch behavior or production artifacts
- [x] Repair the isolated popup’s runtime callback handoff after trace-confirmed `on_submit` is not callable, without changing the validator, transport, or production artifacts
- [x] Assess the production integration and apply the user-selected Merged-only release scope without experiment diagnostics or folder creation
- [x] Apply the approved production-only key-entry input bridge and valid-response key.json save to Merged.lua; the original both-loader request was superseded by the Merged-only release decision
- [x] Implement the approved popup-open-on-start, saved-key prefill, OK-to-existing-validator handoff, and cancel-return behavior in Merged.lua; Reusable.lua remains a template
- [x] Complete a read-only architecture clarification of Reusable versus Merged loader usage before resuming production merge work
- [x] Restore Reusable.lua to the verified template state and retain the approved key-entry integration only in Merged.lua for end-user release
- [x] Verify, checkpoint, and deliver the compile-ready Merged.lua production artifact after Merged-only regression coverage is updated
- [x] Limit every newly generated username-prefixed license key to a 50-character total length without changing API validation or popup limits
- [x] Implement, verify, checkpoint, and provide the Android-test Merged.lua artifact together with the 50-character generator alignment
- [x] Normalize a saved key.json wrapper to the raw key before Merged.lua popup prefill and OK enablement, without changing validation or transport behavior
- [x] Diagnose why Super Admin global key/referral aggregates and global record tables render as zero/empty despite existing owner/admin-created records.
- [x] Superseded the proposed aggregate-query/client-refresh change because read-only diagnosis established the platform-managed OWNER_OPEN_ID identity binding as the root cause; no application change was authorized or needed
- [x] Superseded application-side aggregate regression work after the platform identity correction restored access to the unchanged Super Owner procedures
- [x] Preserve strict read-only boundaries for login, authentication, authorization, key validation, HTTP server/communication, transport, API endpoints/contracts, request/response formats, and all Lua/reference files while fixing only the existing dashboard reporting implementation.
- [x] Platform support corrected the managed OWNER_OPEN_ID identity binding with no application-code or authorization-logic change
- [x] Retested the unchanged Super Owner UI/procedures after the confirmed configuration correction; the authenticated Global Review view renders through the existing gate
- [x] Resolved the platform-level OWNER_OPEN_ID blocker through the project-owner and Manus support path before resuming approved UI work
- [x] Analyze only whether the unchanged Super Admin account can satisfy existing superOwner.* checks through a supported non-code path; do not implement any workaround or modify protected layers without explicit approval.
- [x] Re-run unchanged superOwner.* requests while authenticated as the exact original project-owner account and record HTTP status and response bodies without changing code or data.
- [x] Compare read-only database totals and record ownership with the unchanged global aggregate responses to separate authorization failure from query/data-source or dashboard mapping failure.
- [x] Audit existing Bear Character download UI/routes/assets for legitimate public or protected exposure, without attempting hidden URLs, bypasses, or unauthorized downloads.
- [x] Deliver an evidence-based diagnosis only; do not implement any workaround or protected-layer change until separately approved.

- [x] Closed the Super Admin dashboard reporting issue after exact-account diagnosis, confirmed platform identity correction, and approved revalidation of the existing procedures
- [x] Keep panel theme-preview work deferred until the existing Super Admin global-data diagnosis and approval-gated fix decision are complete.
- [x] Finalize and deliver the exact-account Super Admin query/data-source/root-cause diagnosis without implementing changes.

- [x] Diagnose why a multi-device key such as 99 displays only one bound device after multiple successful logins
- [x] Verify stored device bindings versus panel count/list and identify whether the defect is persistence, aggregation, cache invalidation, or rendering
- [x] Correct multi-device usage reporting without changing license validation, API contracts, transport, or V1 Lua behavior
- [x] Add regression coverage for multiple device bindings and verify the panel output
- [x] Publish the verified multi-device reporting correction

IMPORTANT: Complete every item above before considering this request finished.

- [x] Design a Super Admin-only customizable Lua startup announcement with on/off, date/time window, and every-login or once-per-day display mode
- [x] Define the minimum isolated panel, backend, storage, and Lua changes while preserving validation, authentication, API contracts, transport, and existing production flow
- [x] Explain safety, compatibility, timezone, caching, and fail-closed behavior before requesting implementation approval
- [x] Deliver the announcement design proposal without modifying the current system

IMPORTANT: Complete every item above before considering this request finished.

- [x] Support safe festival emoji in announcement titles/messages without executable or rich-content input
- [x] Support configurable announcement text size with responsive wrapping and bounded popup dimensions
- [x] Define fallback behavior for oversized or unsupported emoji text without blocking the existing Lua flow
- [x] Update the announcement design proposal with emoji and large-text constraints, without modifying the current system

IMPORTANT: Complete every item above before considering this request finished.

- [x] Inspect current announcement, user-role, referral, key-ownership, and Main Lua boundaries for a removable Telegram extension
- [x] Design isolated Telegram channel storage and explicit key-to-channel ownership mapping
- [x] Define role-scoped setup, edit permissions, Telegram URL validation, and one-time onboarding behavior
- [x] Define announcement OK/Cancel redirect behavior and fail-open Telegram navigation handling
- [x] Define the exact disable/rollback boundary so removing Telegram leaves announcement and protected systems unchanged
- [x] Deliver the Telegram extension implementation plan and blockers without modifying protected or existing systems

IMPORTANT: Complete every item above before considering this request finished.

- [x] Trace existing Owner/Admin relationships, referral provenance, key ownership, and account creation flow without changing data
- [x] Compare existing records to determine durable and uncertain Owner-to-Admin mappings
- [x] Inspect authorized UE4 Dynamic Lua HttpWrapper evidence for secure post-validation ticket feasibility
- [x] Report exact protected limitation, if any, and recommended next step without implementing changes

IMPORTANT: Complete every item above before considering this analysis request finished.

- [x] Finalize isolated Telegram schema, security contract, lifetime, replay protection, and rollback boundary
- [x] Add Telegram-only account scopes preserving only clear surviving referral provenance
- [x] Add Telegram-only explicit license-to-account mapping without modifying existing license schema
- [x] Implement Telegram-only short-lived single-use ticket issuance and redemption bound to license and device context
- [x] Add Telegram-only Super Admin and scoped Owner/Admin management procedures and UI
- [x] Add Telegram-only Lua ticket request, announcement OK redirect, and fail-open handling without changing validation or announcement logic
- [x] Add Telegram-only tests for ownership isolation, replay, expiry, mapping, rate limits, and protected-flow regressions
- [x] Verify the extension can be disabled/removed without affecting existing systems and publish the approved implementation

IMPORTANT: Complete every item above before considering this request finished.

- [x] Inspect published Telegram checkpoint aafce01c source, schema, procedures, routes, Lua hooks, and tests without editing
- [x] Run read-only automated, database, published-preview, and protected-flow verification checks
- [x] Classify device/runtime-only Telegram checks separately and document any evidence gaps
- [x] Deliver final pass/fail report with exact files and confirmation that protected systems were not modified

IMPORTANT: Complete every item above before considering this verification request finished.

- [x] Remove Telegram creator fallback so only explicit valid license mappings can resolve a channel
- [x] Add durable server-side one-time Telegram setup prompt state and saved-link suppression
- [x] Preserve Admin self-registration, scoped Owner/Admin editing, and Super Owner global management
- [x] Add focused tests for missing/correct mapping, setup prompt/suppression, invalid URL, announcement modes, redirect, replay, and device mismatch
- [x] Verify protected validation, authentication, authorization, transport, callbacks, device binding, referrals, key generation, Main Lua validation flow, and System Announcement remain unchanged
- [x] Run full suite, TypeScript, Lua syntax, visual verification, save and publish the corrected checkpoint
- [x] Deliver new checkpoint ID and before/after report

IMPORTANT: Complete every item above before considering this request finished.

- [x] Extend Telegram validation to accept supported public links and private +/joinchat invite links only
- [x] Preserve validated private invite URLs exactly without resolution, conversion, guessing, or fallback
- [x] Update the isolated setup prompt to state that Public Channel Link and Private Invite Link are accepted
- [x] Add focused tests for public/private acceptance, invalid URLs, private preservation, mapped private redirect, and Announcement OFF
- [x] Verify protected boundaries remain unchanged and publish the Telegram-only correction
- [x] Deliver the new checkpoint ID and test results

IMPORTANT: Complete every item above before considering this request finished.

- [x] Show an isolated Telegram link setup popup for existing eligible users with no saved link
- [x] Suppress the popup after a valid public or private Telegram link is saved server-side
- [x] Keep popup behavior limited to the Telegram extension and preserve all protected systems
- [x] Add regression coverage, verify the project, and publish the popup update

IMPORTANT: Complete every item above before considering this request finished.

- [x] Add Super Owner-only edit controls for each mapped Owner/Admin Telegram link
- [x] Ensure edits target only the selected account and reuse strict public/private URL validation
- [x] Add regression coverage for edit targeting, permission isolation, and private-link preservation
- [x] Verify protected systems remain unchanged and publish the Telegram-only edit control
- [x] Deliver usage instructions and checkpoint ID

IMPORTANT: Complete every item above before considering this request finished.

- [x] Inspect current panel contracts and feature boundaries for the replication specification
- [x] Draft a complete same-behavior implementation prompt without secrets
- [x] Produce and validate the shareable Markdown document and PDF copy
- [x] Deliver the replication prompt and required-input checklist

- [x] Refresh and deliver a sanitized A-to-Z replication package covering the current panel, canonical HTTP contracts, Telegram mapping, Android Merged Lua, and platform-bound setup requirements

IMPORTANT: Complete every item above before considering this request finished.

- [x] Superseded by clarified requirement: Global Review retains the complete all-panel key registry and reuses the existing detail rendering
- [x] Superseded by clarified requirement: Global Review confirmation deletes all panel keys, including Owner/Admin/Super Owner keys
- [x] Superseded by clarified requirement: regression coverage covers Home owner scoping, Global Review completeness, confirmation, and panel-wide destructive boundaries
- [x] Verify protected systems remain unchanged and publish the Global Review update
- [x] Deliver usage instructions, safety scope, tests, and checkpoint ID

IMPORTANT: Complete every item above before considering this request finished.

- [x] Restrict Super Owner Home key list to keys created by the current Super Owner
- [x] Move the complete all-panel key registry into Global Review with existing detail fields
- [x] Add Global Review DELETE ALL KEYS confirmation and all-panel deletion behavior
- [x] Add regression coverage for Home scoping, Global Review completeness, confirmation cancel/yes, and destructive boundaries
- [x] Verify HTTP, transport, validation, auth, device, referral, announcement, Telegram, and key-generation contracts remain unchanged
- [x] Publish the dashboard-only update and deliver usage instructions

IMPORTANT: Complete every item above before considering this request finished.

- [x] Add a dedicated Super Owner ALL KEY REVIEW button below the existing overview controls
- [x] Show the complete panel-wide key registry in the dedicated review view using the existing all-key data source
- [x] Add explicit YES/NO confirmation for the panel-wide DELETE ALL KEYS action
- [x] Add focused regression coverage for dedicated review visibility and delete scope
- [x] Verify protected systems remain unchanged and publish the dedicated review update
- [x] Deliver button location, usage instructions, tests, and checkpoint ID

- [x] Superseded by the approved restoration of the normal Home key registry; the dedicated page was removed
- [x] Superseded by the approved restoration of the normal Home key registry; no alternate data path was added
- [x] Covered by the restored Home registry and existing confirmation-boundary regression coverage
- [x] Superseded by the published Home restoration checkpoint 939497cb
- [x] Delivered the diagnosis, restoration result, tests, and checkpoint ID

IMPORTANT: Complete every item above before considering this request finished.

- [x] Inspected supported platform controls; no editable in-project OWNER_OPEN_ID route exists
- [x] No supported platform correction was available from the current workspace; no change applied
- [x] Retest remains blocked by the unchanged OWNER_OPEN_ID/session mismatch; no procedures modified
- [x] Confirmed: no Option B or protected-layer application changes were made
- [x] Delivered exact platform blocker and Manus project-owner/support next action

IMPORTANT: Complete every item above before considering this request finished.

- [x] Identify the supported Manus management location for project-owner identity/OWNER_OPEN_ID correction
- [x] Confirm whether any supported in-project route exists, without changing configuration
- [x] Report the exact platform/project-owner next action or confirm no in-project route

IMPORTANT: Complete every item above before considering this request finished.

- [x] Restore complete panel-wide key visibility on the normal Home page
- [x] Add confirmation-protected DELETE ALL KEYS to the Home key section
- [x] Remove or hide the dedicated All Panel Keys route/button as requested
- [x] Add focused regression coverage and verify all protected boundaries remain unchanged
- [x] Publish the restored Home behavior and deliver usage instructions

IMPORTANT: Complete every item above before considering this request finished.

- [x] Inspect the existing System Announcement save procedure and Super Owner gate
- [x] Compare displayed Super Owner role with the server authorization/session identity
- [x] Determine whether OWNER_OPEN_ID/session mismatch causes the save rejection
- [x] Report the read-only diagnosis and supported next action without code or security changes

IMPORTANT: Complete every item above before considering this request finished.

- [x] Confirm Announcement save still fails after logout/login with the unchanged Super Owner gate
- [x] Document that session refresh does not correct the platform-managed OWNER_OPEN_ID mismatch
- [x] Report the supported platform-side next action without code, authorization, or security changes

IMPORTANT: Complete every item above before considering this request finished.

- [x] Attempt supported read-only inspection of the managed OWNER_OPEN_ID for project 8355YBgtV3WRkZcdHHWFed; direct value comparison is unavailable in the current project interface
- [x] Identify the supported platform-side correction path if the owner identity binding mismatches
- [x] Leave application authorization, authentication, APIs, transport, validation, callbacks, Lua, and Announcement code unchanged

IMPORTANT: Complete every item above before considering this request finished.

- [x] Trace the shared authenticated request context used by all Super Owner procedures
- [x] Compare the common role/Open ID gate behavior across Global Debug, Global Records, allKeysOverview, seasonCounts, referralOverview, and updateAnnouncement
- [x] Determine whether the platform-managed OWNER_OPEN_ID comparison is the common failure point
- [x] Confirm whether any application-side request-context defect exists without modifying protected systems
- [x] Deliver an evidence-based common root-cause report with no workaround or bypass

IMPORTANT: Complete every item above before considering this request finished.

- [x] Preserve the current application exactly as-is while platform support checks the published OWNER_OPEN_ID binding
- [x] Retested the unchanged Super Owner Global Review after the user-confirmed platform identity correction; the existing page renders through the unchanged Super Owner gate
- [x] Report post-correction results without implementing any workaround or alternate authorization path

IMPORTANT: Complete every item above before considering this request finished.

- [x] Inspect V3.zip for current device-ID generation, persistence, and license-binding logic
- [x] Determine whether the current identifier changes after app-data deletion, reinstall, reset, or use on another device
- [x] Assess whether a durable per-device identifier is available through the existing UE4 Dynamic Lua/Android bridge
- [x] Report a secure recommendation without modifying V3 or production V1

IMPORTANT: Complete every item above before considering this request finished.

- [x] Create a sanitized full source backup archive for lua-license-panel, including frontend, backend, schema, migrations, Lua artifacts, tests, and project documentation
- [x] Create a configuration and restoration manifest that excludes plaintext secrets and identifies required environment variables
- [x] Validate the archive and document the separate official Manus Task Data Backup requirement for database contents, secrets, integrations, domains, and hosted capabilities

IMPORTANT: Complete every item above before considering this backup request finished.

- [x] Prepare the backup for parallel-project recreation, with a sanitized environment template, migration order, deployment notes, API contract inventory, and explicit separation of portable source from platform-bound state

IMPORTANT: Complete every item above before considering this backup request finished.

- [x] Audit whether any useful project or platform-bound backup artifacts remain outside the delivered full backup bundle and package only non-duplicate items

IMPORTANT: Complete every item above before considering this backup-audit request finished.

- [x] Correlated the Announcement 403 and Global Review zero-state with the existing shared Super Owner gate
- [x] Confirmed that a client-only change could not return protected global data or save announcements without an authorization bypass
- [x] Preserved HTTP, transport, communication, validation, callbacks, device binding, Lua, referrals, key generation, Announcement, and Telegram code unchanged during the diagnosis
- [x] Reported the required platform-side owner-identity correction before retesting

IMPORTANT: Complete every item above before considering this screenshot-based Super Owner diagnosis finished.

- [x] Re-checked the common Super Owner authorization gate for Global Review and System Announcement without code changes
- [x] Confirmed that HTTP, transport, communication, license validation, callbacks, device binding, Lua, referrals, and key generation remained untouched
- [x] Determined that the supported correction was platform-managed OWNER_OPEN_ID binding repair, subsequently confirmed by the user
- [x] Reported the diagnosis before any implementation or workaround

IMPORTANT: Complete every item above before considering this Super Owner diagnosis request finished.

- [x] Move the panel-wide key registry from Home to the existing Super Owner Global Review All Keys section
- [x] Limit Home key registry visibility to keys generated by the signed-in account
- [x] Preserve HTTP, transport, communication, authentication, authorization, license validation, callbacks, device binding, Lua, referrals, key generation, Announcement, and Telegram systems unchanged
- [x] Add focused scope-regression coverage and verify the existing test suite

IMPORTANT: Complete every item above before considering this key-registry scope request finished.

- [x] Inspect the saved-key, post-validation, announcement, Telegram, and Super Owner boundaries before implementing the approved isolated features
- [x] Confirm whether valid-first key.json replacement can be added without changing validation, transport, callbacks, device binding, or authorization
- [x] Confirm whether scheduled maintenance can be implemented as a separate Super Owner-gated operational state without changing protected identity, announcement, Telegram, or validation contracts
- [x] Add only the approved isolated valid-first local key replacement behavior, preserving the previous file on every unsuccessful validation outcome
- [x] Add a separate Super Owner-only maintenance configuration with safe Unicode text, enabled state, and UTC schedule evaluation including overnight windows
- [x] Ensure active maintenance blocks post-validation Main Lua continuation with an informational popup and suppresses announcement/Telegram action without treating a valid license as invalid
- [x] Add focused saved-key, schedule, maintenance-priority, isolation, authorization, and Super Owner regression coverage
- [x] Verify full tests, TypeScript, Lua syntax, protected route and transport invariants, authenticated UI behavior, and the existing Super Owner operations before publication
- [x] Reproduce and trace the reported expired-saved-key plus valid-entered-key runtime failure without changing protected validation or transport behavior
- [x] Verify runtime-capable saved-key cases: expired-old plus valid-new, valid-old plus valid-new, invalid-new preservation, expired/rejected-new preservation, and network-failure preservation
- [x] Keep custom maintenance title and message editable, normalize control characters safely, preserve Unicode/emoji text, and enforce the existing 300-character message limit
- [x] Confirm the exact saved custom maintenance title/message is the informational popup payload when maintenance is active
- [x] Apply only the explicitly approved downloadable-wrapper alignment so the owner panel delivers the tested valid-first saved-key implementation
- [x] Apply only the explicitly approved isolated GET maintenance gate before Main Lua continuation, without changing the canonical validation endpoint or existing Announcement/Telegram contracts
- [x] Verify the exact downloadable Lua artifact checksum and controlled runtime behavior before publication

IMPORTANT: Complete every item above before considering the isolated saved-key replacement and Server Maintenance request finished.

- [x] Inspect the existing Super Owner Review navigation, System Announcement controls, Telegram controls, and maintenance panel boundaries without changing their procedures or runtime behavior
- [x] Add Super Owner-only sibling navigation cards for System Control and Announcement Control beside the unchanged Super Owner Review card
- [x] Add a dedicated System Control page that reuses only the existing Server Maintenance configuration controls
- [x] Add a dedicated Announcement Control page that reuses only the existing System Announcement and Telegram controls
- [x] Keep Super Owner Review, all existing Super Owner procedures, validation, automatic key replacement, device binding, maintenance runtime gate, System Announcement behavior, Telegram behavior, and OWNER_OPEN_ID logic unchanged
- [x] Add focused navigation and route-authorization coverage for the two control pages and run UI, TypeScript, Lua, full regression, and authenticated Super Owner checks

IMPORTANT: Complete every item above before considering the Super Owner sibling control-page request finished.

- [x] Trace the referred Admin username-completion, active-access, and Telegram setup-prompt eligibility sequence
- [x] Identify and correct only the Telegram-scoped reason an eligible newly referred Admin cannot add a channel link
- [x] Verify Admin self-link registration, explicit generated-key mapping, and saved-link setup suppression with focused coverage
- [x] Verify an active Announcement OK action issues a valid mapped ticket and opens only the stored public or private Telegram URL; preserve Cancel and Announcement-OFF behavior through controlled ticket and Lua redirect coverage
- [x] Run full Telegram, TypeScript, Lua syntax, protected-validation, and authenticated role-scope regressions before publication
- [x] Verify that an Admin may add only their first Telegram link and cannot later edit it directly
- [x] Verify that only the Owner who issued that Admin's referral may edit that Admin's Telegram link, while unrelated Owners are denied
- [x] Verify that an Owner may edit their own Telegram link and that the Super Owner may edit every eligible account link
- [x] Preserve all non-Telegram validation, authentication, HTTP/transport, callback, device-binding, referral, key-generation, System Announcement, and Main Lua behavior unchanged

IMPORTANT: Complete every item above before considering the newly referred Admin Telegram setup request finished.

- [x] Read-only verify that Telegram Scope Review confirmation writes a durable scope record and that the UI reflects the resulting state
- [x] Report whether the observed confirmation is persisted or identify the isolated Telegram-only issue without modifying production behavior

- [x] Trace why active System Announcement is not displayed after valid Lua authorization and therefore cannot trigger its mapped Telegram OK redirect
- [x] Trace why active scheduled Server Maintenance is not displayed and does not block Main Lua continuation after valid authorization
- [x] Verify persisted settings, UTC schedule evaluation, public active-state endpoints, downloadable Lua loader version, and post-validation request ordering before any correction
- [x] Apply only a safe isolated correction if needed, preserving canonical validation, authentication, HTTP/transport, callbacks, device binding, key replacement, Telegram mappings, and Super Owner authorization
- [x] Verify Announcement OK/Cancel/Off, Telegram redirect, Maintenance active/inactive scheduling, and full protected regressions before publication

IMPORTANT: Complete every item above before considering the Announcement and Maintenance runtime regression resolved.

- [ ] Capture the saved Maintenance window and the public active-state endpoint at the exact time Android shows valid authorization without a Maintenance popup
- [x] Trace why the real Android Lua host continues after the Maintenance GET callback instead of blocking Main Lua during an active Maintenance response — uploaded Android artifact is the legacy merged loader, which directly invokes Main Lua after validation and contains no Maintenance gate
- [x] Apply only an isolated Maintenance-delivery correction if required, preserving canonical validation, HTTP/transport, callbacks, authentication, device binding, Announcement, Telegram, and key-management behavior
- [ ] Re-run active-window Android Maintenance blocking verification, then full Lua and Super Owner regressions before publishing

- [x] Obtain explicit approval before modifying BRPlayerCharacterBase-Merged.lua, the Android-integrated reference artifact
- [x] Add the missing post-validation System Announcement fetch, popup, explicit Telegram-ticket redirect, and Cancel continuation to the approved Android merged loader
- [ ] Verify Announcement ON/OFF and mapped Telegram redirect together with Maintenance precedence on the real Android integration

- [x] Preserve a checkpoint and named backup of BRPlayerCharacterBase-Merged.lua before its approved isolated post-validation integration
- [x] Implement exact ordering in BRPlayerCharacterBase-Merged.lua: valid authorization → Maintenance check → Announcement check → Telegram/Main Lua continuation
- [ ] Verify active Maintenance: configured popup and no Main Lua execution after its OK action
- [ ] Verify active Announcement: OK triggers explicit mapped Telegram redirect and Main Lua; Cancel triggers Main Lua only; OFF runs Main Lua normally

IMPORTANT: Complete every item above before considering the confirmed Android Maintenance blocking regression resolved.

- [x] Inspect whether the target Android Lua runtime exposes a supported first-run directory creation capability for the lua-license folder
- [ ] If supported without changing protected flows, make BRPlayerCharacterBase-Merged.lua create the missing lua-license directory before key/status file access
- [ ] Verify first-run directory creation, automatic key.json persistence, and fail-closed behavior when storage is unavailable

IMPORTANT: Complete every item above before considering automatic lua-license folder provisioning complete.

- [x] Capture the Android Maintenance OFF status-check failure and compare it with the live public Maintenance endpoint response
- [x] Trace the merged loader’s Android callback/request-index handling for the Maintenance response without changing the existing HTTP contract
- [ ] Apply only an isolated merged-loader callback correlation correction if necessary, then verify OFF continuation, active blocking, Announcement, Telegram, and Main Lua paths

IMPORTANT: Complete every item above before considering the Android Maintenance status-check regression resolved.

- [x] Reproduce and trace the Android merged-loader case where a newly entered valid key fails while a saved expired key exists
- [x] Verify submitted-key precedence, validation response handling, and key.json persistence without changing canonical validation or device binding
- [ ] Apply only an isolated merged-loader saved-key correction if required, then verify valid replacement and old-key preservation on failure

IMPORTANT: Complete every item above before considering the Android expired-key replacement regression resolved.

- [x] Add Maintenance-callback-only non-secret diagnostics for success, HTTP/result code, and response-body presence in BRPlayerCharacterBase-Merged.lua
- [x] Deliver the diagnostic loader and capture an Android Maintenance OFF run result without changing validation, transport, callback behavior, or any protected system
- [x] Report the exact diagnostic cause and stop before any protected-layer fix unless separately approved

Diagnostic capture (2026-08-21): Android reports `success=true`, `result=500`, `body=present` for the isolated Maintenance GET request. This confirms the request/callback reaches the service and receives a server error; it does not implicate the protected validation request, its response contract, or the HttpWrapper transport architecture.

- [ ] Run the updated Android merged loader with Maintenance OFF; confirm valid authorization reaches Main Lua without `MAINTENANCE_CHECK_UNAVAILABLE`
- [ ] Run the updated Android merged loader during an active Maintenance schedule; confirm configured popup is shown and Main Lua remains blocked
- [ ] Confirm expired saved key → newly entered valid key validates, replaces only key.json, and continues without deleting device/status files
- [ ] Confirm Announcement ON: OK redirects only to the mapped Telegram channel then runs Main Lua; Cancel runs Main Lua without redirect; Announcement OFF runs Main Lua normally

- [x] Inspect the Android Maintenance popup Unicode/emoji data path and identify why configured emoji render as `?` without changing working Maintenance gate behavior
- [x] Inspect the complete System Announcement active-state, Android request, callback, and popup path in read-only mode to identify why an active Announcement is not shown
- [x] Inspect the Android revoked/expired saved-key replacement path from live key-entry submission through valid-response-only key.json persistence in read-only mode
- [x] Determine whether each reported regression has an isolated non-protected correction; stop and report before any protected change
- [x] If safe, preserve Maintenance ON/OFF behavior while adding targeted Unicode, Announcement, and saved-key regression coverage
- [ ] Verify the corrected Android loader on device for Maintenance, Announcement, mapped Telegram redirect, and revoked/expired old-key replacement before marking this task complete

- [x] Add an isolated key-free POST mirror for `/api/announcement/active` while preserving the existing GET behavior
- [x] Change only the Android Announcement fetch to its fixed `{}` POST request and preserve the existing Announcement → Telegram ticket → redirect path
- [x] Add only approved saved-key diagnostics: input source, input length, and returned validation status; never log key/device/token/body/user data
- [x] Publish the Announcement POST plus saved-key diagnostic test loader after controlled regressions; do not modify emoji handling or the working Maintenance gate

- [x] Record the confirmed real-device baseline: Maintenance OFF normal continuation and Maintenance ON popup/blocking both pass; do not rewrite or refactor this gate
- [x] Read-only trace the existing Announcement OK callback through Telegram ticket request, mapped-link response, and Android open/redirect call
- [x] Read-only inspect the saved-key diagnostic output for input_source, input_length, and validation_status before deciding whether Android key submission is stale
- [x] Read-only verify backend-to-Lua Unicode preservation and locate any shared UE4 popup renderer/font/icon asset support without adding encoding workarounds
- [x] Report exact root causes and any protected-system dependency; obtain approval before any targeted fix

IMPORTANT: Complete every item above before considering the approved Maintenance diagnostics investigation complete.

- [x] Add an isolated Telegram redirect diagnostic file containing only OK_CALLBACK, ticket presence, redeemed-channel presence, and OpenURL availability markers
- [x] Add a separate saved-key diagnostic file containing only input_source, input_length, and validation_status so final status output cannot overwrite it
- [x] Confirm diagnostics never record a key, device ID, ticket, Telegram URL, response body, token, or user data
- [x] Publish the diagnostic-only Android loader after backend, Lua, and controlled-runtime regressions; do not modify redirect, validation, mapping, device binding, or Maintenance behavior

- [x] Record the confirmed Android evidence: live 35-character key submission reaches canonical validation and returns device_mismatch; key.json must remain unchanged on this rejection
- [x] Read-only trace why the existing Telegram ticket endpoint returns TICKET_MISSING for the validated key and mapped-channel configuration
- [x] Read-only identify the exact existing device-binding rule that rejects a replacement key on the current device and the minimum protected change it would require
- [x] Report both confirmed root causes and request separate approval before modifying any protected device-binding or mapping behavior

- [x] Complete the first-run folder and key.json feasibility analysis without modifying Lua, panel, backend, validation, transport, or storage behavior

- [x] Resolve Announcement Telegram tickets from the validated key creator's current enabled account channel, including existing creator-owned keys, without manual per-key mapping
- [x] Preserve Telegram setup, referral-scoped channel editing, ticket device binding, Announcement-only redirect timing, and Super Owner controls while adding an actionable non-secret missing-mapping diagnostic state
- [x] Obtain explicit approval before modifying the protected global device-binding rule for revoked/expired old-key safe rebinds
- [x] After approval, implement an atomic safe rebind only where the existing device binding belongs to a revoked or expired license and the new key validates canonically
- [x] Verify account-level Telegram resolution, protected rebind cases, Maintenance behavior, Lua runtime paths, TypeScript, and all regression tests before publishing
- [x] Inspect available UE4 Android Msg.Show font, renderer, and project asset support for a genuine shared Maintenance/Announcement emoji solution; stop and report if no supported asset/API exists
- [x] Verify the existing 300-character limit continues to accept Unicode text without changing Maintenance or Announcement control permissions
- [ ] Complete Android runtime verification for Announcement redirect, same-device safe replacement, Maintenance/Announcement emoji behavior, and all required ON/OFF paths before marking the release complete

- [x] Inspect the actual UE4 Android `Msg.Show` host surface for supported font selection, fallback fonts, rich text, inline icon, sprite, or packaged-asset APIs without changing existing popup calls
- [x] Identify a genuine existing font or icon asset route that can render configured emoji in both Maintenance and Announcement popups, or document the exact host-side asset/API requirement if no such route is exposed
- [ ] If and only if a supported route exists, implement the same genuine emoji presentation solution for Maintenance and Announcement without changing their logic, validation, transport, Telegram, or Main Lua behavior
- [ ] Run full regression checks and complete Android verification for the emoji-only change before marking the release complete

- [x] Locate an available APK, OBB, UE4 content package, or `logic_common_msg_box` source and trace `Msg.Show(4, title, message, callback)` to its actual UserWidget/Widget Blueprint asset path
- [ ] Identify the popup's active font asset, any Composite/fallback font chain, RichText decorator, emoji sprite/texture, and any existing supported runtime font-assignment contract
- [ ] Reuse only a verified packaged host resource for shared Maintenance/Announcement emoji rendering; otherwise report the exact missing host-side asset or Widget/API requirement without changing production Lua

- [x] Read-only inventory V3.zip and trace its UI registry from `Msg.Show` to the concrete message-box Widget Blueprint or package asset
- [x] Read-only identify any V3 packaged Composite Font, Font Face, fallback chain, RichText decorator, emoji texture/sprite, and a proven runtime invocation contract

- [x] Read-only determine whether matching OBB PAK indexes are readable and whether `Com_MsgBox_Slua_UIBP` can be selectively extracted without modifying package content
- [x] Read-only identify `Com_MsgBox_Slua_UIBP` widget dependencies, including RichText children, `WidgetSwitcher_Font` variant fonts, Composite/FontFace fallbacks, decorators, textures, sprites, and DataTables when the PAK index exposes them
- [x] Report only evidence-backed active font and emoji fallback support; do not alter Lua or runtime behavior during asset identification

- [x] Read-only parse `Com_MsgBox_Slua_UIBP.uasset` and `.uexp` to map `WidgetSwitcher_Font` indices and all RichText widget asset/property references
- [x] Read-only resolve exact referenced Font, Composite Font, FontFace, fallback, decorator, sprite, texture, and DataTable asset paths or report each unavailable dependency filename
- [x] Report only evidence-backed popup font and emoji-glyph/fallback findings before considering any shared Maintenance/Announcement rendering change

- [x] Read-only parse `Roboto.uasset` and `Roboto.uexp` to identify embedded font payloads, external FontFace dependencies, and any missing companion asset
- [x] Read-only assess the supplied Roboto resource’s Unicode and emoji-glyph coverage with evidence; do not infer support from its name
- [x] Report whether the supplied Roboto resource can be a genuine popup emoji fallback and the exact remaining font/fallback dependency or host requirement

- [x] Read-only parse `RobotoRegular`, `Hortademo`, and `PSLKandaProBold` UE4 FontFace package pairs for loading policy, font payload, and any missing bulk dependency
- [x] Read-only extract and inspect available font character maps for the exact emoji Unicode ranges needed by Maintenance and Announcement popups
- [x] Report whether any supplied FontFace can genuinely render emoji through the identified Composite Font and what safe popup-host route remains required

- [x] Read-only parse `RobotoRegular`, `Hortademo`, and `PSLKandaProBold` UE4 FontFace package pairs for loading policy, font payload, and any missing bulk dependency
- [x] Read-only extract and inspect available font character maps for the exact emoji Unicode ranges needed by Maintenance and Announcement popups
- [x] Report whether any supplied FontFace can genuinely render emoji through the identified Composite Font and what safe popup-host route remains required
- [x] Close the unavailable-font-data inspection boundary: user confirmed no matching `.ubulk` or separate TTF exists, so no missing asset is assumed

- [x] Read-only inventory supplied TTF metadata and confirm which files correspond to the UE Composite Font dependency paths
- [x] Read-only inspect the supplied TTF character maps and color/bitmap emoji tables for genuine Android popup emoji coverage
- [x] Correlate proven glyph coverage with the supplied UE Composite Font and report any remaining popup-binding or safe-invocation blocker

- [x] Read-only inventory supplied TTF metadata and confirm which files correspond to the UE Composite Font dependency paths
- [x] Read-only inspect the supplied TTF character maps and color/bitmap emoji tables for genuine Android popup emoji coverage
- [x] Correlate proven glyph coverage with the supplied UE Composite Font and report any remaining popup-binding or safe-invocation blocker
- [x] Close exact-data inspection for unavailable `Hortademo`, `PSLKandaProBold`, and Noto candidates; no missing resource is assumed

- [x] Read-only inventory the supplied extracted OBB archives without executing or modifying contents
- [x] Locate exact popup widget, font, FontFace, `.uexp`, `.ubulk`, and RichText dependency assets in the extracted archive data
- [x] Inspect available actual font payloads and configured popup resources for evidence-backed modern emoji support
- [x] Determine whether an existing asset plus documented host presentation route can safely render popup emoji before any implementation

- [x] Assess read-only feasibility of isolated `Com_MsgBox_Slua_UIBP` presentation-layer editing for modern emoji rendering
- [x] Compare a dedicated emoji-capable Runtime Composite Font against a chat-sprite RichText decorator approach using the verified popup evidence
- [x] Specify the required UE4 assets, editing/repackaging toolchain, risk controls, Android validation matrix, and rollback method without implementation

- [x] Read-only identify available B3/V3 writable-path, file-existence, file-write, and directory-creation evidence for LuaLicense storage; exact B3 create API remains unproven because no B3 package was supplied
- [x] Read-only trace the current LuaLicense path and all existing key/device/status persistence files without changing their formats or flow
- [x] Report the exact safe folder-ensure insertion point, new/existing-user flows, failure behavior, and whether host support is required

- [x] Read-only rescan the newly supplied V3 archive for exact `DirectoryExists`, `CreateDirectory`, `MakeDirectory`, or equivalent host contract evidence
- [x] Verify the renewed V3 file-discovery-only evidence against the current exact `KEY_DIR` and pre-storage insertion boundary without implementing it
- [x] Report that the renewed V3 evidence confirms source-host directory support is still required

- [x] Deep read-only map of every V3 `SavedFileUtil`, file utility wrapper, host bridge, reflection-style call, and indirect directory-related identifier
- [x] Validate newly discovered V3 write-method candidates against the exact existing Android `KEY_DIR` and no-regression storage boundary
- [x] Publish the evidence-bounded conclusion that V3 exposes potential write primitives but no safe documented directory-creation route

- [x] Create a separately runnable, non-secret Android filesystem capability probe without modifying the production loader or license files
- [x] Restrict the probe to observed V3 host write candidates and record only allowlisted filesystem capability markers
- [x] Verify the probe contains no license validation, key/device/status, Maintenance, Announcement, Telegram, or Main Lua flow
- [x] Document the Android test procedure, non-secret expected output, and exact evidence required for future folder-ensure approval
- [x] Run static syntax and safety checks, checkpoint the probe, and receive Android evidence before any production integration

- [x] Read and classify the returned non-secret Android probe report against its fixed result contract
- [x] Document the exact host write/create evidence boundary and production-safe insertion plan without modifying production Lua
- [x] Checkpoint the evidence-only conclusion and obtain separate production folder-ensure approval

- [x] Add the Android-proven `Client.WriteFileAtPath` marker write/read-back preflight before the first production status write
- [x] Fail closed on a non-secret folder/storage preflight error without touching key, device, or status files
- [x] Preserve all validation, device binding, Maintenance, Announcement, Telegram, Main Lua, and persistence-format boundaries with focused regression coverage
- [x] Run full regression tests, Lua syntax, TypeScript, and changed-file isolation checks; checkpoint the approved production change
- [x] Complete focused Android first-run and existing-folder verification of the production folder ensure
- [x] Record the user-reported Android first-run, reopen, and valid-key persistence outcome without collecting sensitive data

- [x] Perform a strictly read-only V3 and observed-host audit for stable app/device identifier APIs and existing call sites
- [x] Classify each evidenced identifier candidate for restart/reinstall stability, Android restrictions, collision risk, privacy, and server-binding suitability
- [x] Write an evidence-bounded recommendation without changing random device-ID generation or any protected production flow
- [x] Checkpoint the read-only stable device-identifier feasibility report and obtain separate probe approval before any production change

- [x] Create a separately runnable non-secret `Client.GetPhoneDeviceID()` availability and restart-stability probe
- [x] Restrict the probe to allowlisted availability/non-empty/restart-stable results without raw ID output, persistence, transmission, hashing, or screenshots
- [x] Verify the probe cannot touch production device-ID generation, validation, key/status files, or protected presentation flows
- [x] Document the exact two-run Android test protocol and evidence boundary; checkpoint the probe before Android execution

- [x] Inspect only the allowlisted first- and second-run PhoneDeviceID result artifacts and classify restart stability
- [x] Document and checkpoint the returned evidence without changing production identity, binding, or validation behavior

- [x] Map the current production identity resolution and canonical server-binding boundaries for planning only
- [x] Design approval-gated new-user, existing-random-ID migration, fallback, compatibility, and rollback behavior without code changes
- [x] Write the stable device-ID production implementation plan; await separate implementation approval
- [ ] Checkpoint the planning-only stable device-ID adoption document and await separate implementation approval

- [x] Design a standalone A-to-B copied-key-state diagnostic that uses existing canonical validation while keeping each device identity intact
- [x] Restrict diagnostic outputs to A binding and B copied-state accepted/rejected markers with no secret or identifier content
- [x] Verify the diagnostic does not modify production loader, key/status formats, random/host device identity, or protected presentation flows
- [x] Document the two-device protocol, static-test the diagnostic, checkpoint it, and receive the returned A-pass/B-indeterminate result

- [x] Map the standalone B diagnostic's non-secret indeterminate branches and add only stage-level result markers
- [x] Create and static-test a B-only copied-state stage diagnostic without changing production identity, key/status files, or binding
- [x] Checkpoint the B-stage diagnostic and receive the non-secret B-own-identity-unavailable result before any security conclusion

- [x] Document that the returned A external/pickle and B compiled-file results are non-comparable and require a same-method retest
- [x] Checkpoint the same-execution-context A-to-B retest protocol and receive comparable non-secret B evidence

- [x] Receive the correct B-stage diagnostic marker after the original A-to-B diagnostic was rerun instead of the B-stage artifact

- [x] Obtain explicit approval for a B-only, no-key identity-preparation run; then retest without copying A identity

- [x] Create a B-only key-free identity initializer only after explicit approval, so copied-state testing does not rely on a different B license binding
- [x] Establish B's own identity through the approved helper path, as evidenced by the subsequent canonical B-stage result
- [x] Run the B-stage copied-state diagnostic after B identity readiness and classify its final non-secret canonical rejection result
- [x] Document the verified A-to-B copied-state rejection conclusion without changing production code
- [x] Checkpoint the verified A-to-B copied-state rejection conclusion without changing production code

- [x] Create a standalone A-to-B copied-identity diagnostic that reads only special copied test key/device files and uses existing canonical validation
- [x] Restrict copied-identity diagnostic output to a non-secret accepted/rejected/undetermined marker and prohibit production file or host identity modification
- [x] Document the isolated two-device copied-identity test protocol, static-test the diagnostic, checkpoint it, and receive the non-secret accepted result
- [x] Run the isolated copied A key-and-device-ID test before making any final anti-cloning implementation decision

- [x] Map the copied-local-identity clone-risk path and protected server-binding constraints for planning only
- [x] Design an approval-gated host-identity-first anti-cloning migration, fallback, rollback, and Android verification strategy
- [x] Write the anti-cloning remediation plan without changing production loader, server binding, or verified flows
- [x] Checkpoint the anti-cloning remediation plan and await separate production implementation approval

- [x] Document the confirmed copied-local-identity acceptance vulnerability without changing production code
- [x] Checkpoint the confirmed copied-local-identity acceptance vulnerability without changing production code
- [x] Obtain separate approval before implementing the host-identity-first anti-cloning production fix

- [x] Add guarded `Client.GetPhoneDeviceID()` host-first resolution for fresh enrollments before every copyable local identity source in the production Merged loader
- [x] Preserve active legacy local binding, generic provider, and random local fallback behavior without automatic migration or rebind
- [x] Add regression coverage proving fresh host identity selection precedes provider/random fallback and protected flows remain unchanged
- [x] Run full regression, Lua syntax, TypeScript, and changed-file isolation checks; checkpoint the approved production fix
- [x] Complete Android normal A login and A-to-B full-folder-copy verification, stopping on any B acceptance

- [x] Record fresh A host-first login evidence (valid login with no local `.device_id`) and classify the B full-folder-copy result

- [x] Document and checkpoint the confirmed Android A-to-B full-folder-copy rejection for fresh host-first enrollment

- [x] Run and classify the isolated same-device Clear Data persistence test for fresh host-first binding; do not start uninstall/reinstall testing
- [x] Run and classify the isolated same-device uninstall/reinstall persistence test for fresh host-first binding; do not alter production code or server binding

- [x] Verify and deliver the latest Android-verified all-fix `BRPlayerCharacterBase-Merged.lua` as a single production file

- [x] Reproduce and rule out the reported local `luac5.3` unmatched-`end` failure: the actual latest `BRPlayerCharacterBase-Merged.lua` passes Lua 5.3 syntax; the screenshot selected a different large source file
- [x] Deliver the exact locally Lua-5.3-compilable Merged artifact and source-selection instructions

- [x] Receive the exact 434.6 KB locally merged `BRPlayerCharacterBase.lua`, reproduce its Lua 5.3 parser error, and apply only the verified minimum syntax correction

- [x] Diagnose the reported ESP box failure in the locally compiled large Lua artifact with non-secret runtime evidence; do not modify unrelated loader or visual features
- [ ] Inspect and correct only the ESP box initialization/render path; preserve working tracers, labels, health bars, distance, license flow, and Main Lua behavior
- [x] Design an approval-gated local compilation architecture that preserves the UE4 module's required top-level return while keeping the external production loader unchanged
- [x] Create and validate a separate-copy local bootstrap plus original-module pair; never overwrite either source original
- [ ] Deliver the approved two-file local package with bootstrap-first compile/load instructions and Android feature verification
- [x] Build and validate a separate single-file local `BRPlayerCharacterBase.lua` copy with license gate, deferred feature initialization, and intact UE4 module return
- [x] Preserve the required one-file ordering: license bootstrap first, original Main/ESP module in the middle, login callback/UI before the final top-level UE4 module return
- [x] Create and checkpoint a pinned sanitized playbook for future UE4 class-module Lua license-gate fixes using the proven deferred-initialization method
- [x] Audit and harden the copied local Lua so persisted feature settings cannot activate custom features before canonical authorization
- [x] Design mandatory fail-closed feature gating plus optional saved-settings persistence removal; do not rely on file deletion as the security control
- [x] Build and verify a copied no-persistence local artifact: no settings file read/write, no custom `FastTick/MainLoop` before canonical authorization
- [x] Pin immutable references for both `BRPlayerCharacterBase-Merged.lua` and `FailClose-NoRestriction.lua`; do not merge or overwrite either
- [ ] Complete Android invalid-key, valid-key, and session-settings-reset verification for the fail-closed local artifact

- [x] Select Option A safe rollout: new/fresh host-first enrollments with active legacy local bindings preserved unchanged

- [x] Add focused tests for host-first only when no existing legacy `.device_id` exists, with fallback and no raw host-ID diagnostics

- [x] Add optional exact-name custom key mode: custom `Alexa` creates `ALEXA`, while duplicate active/unexpired exact names are rejected and normal random-key generation remains unchanged

- [x] Increase Maximum Devices UI and backend validation from 1–100 to 1–10,000; verify 100, 400, 1000, and 10000 accepted while 10001 is rejected

- [x] Finalize the available-asset dependency chain without assuming missing TTF or bulk resources
- [x] Produce an evidence-bounded conclusion on modern emoji coverage in the current packaged popup font chain
- [x] Document a safe host-side alternative only, without implementing or changing any verified runtime behavior

- [x] Finalize the available-asset dependency chain without assuming missing TTF or bulk resources
- [x] Produce an evidence-bounded conclusion on modern emoji coverage in the current packaged popup font chain
- [x] Document a safe host-side alternative only, without implementing or changing any verified runtime behavior

- [x] Perform approved read-only compatibility audit of both pinned Lua templates
- [x] Audit callback, module/return, Main Lua hand-off, match lifecycle, cleanup, and re-initialization behavior
- [x] Build a separate isolated POC adapter proving one validation per app runtime and three match executions without revalidation
- [x] Verify Merged-style and Module/Fallback-style hand-off compatibility in the POC
- [x] Keep existing Lua references and all protected HTTP/transport/validation/device/Telegram/Announcement/Maintenance systems untouched
- [x] Run POC static, syntax, and lifecycle checks, then save a rollback-safe checkpoint

- [x] Create a new separate Universal Lua integration template from POC checkpoint 8394e911
- [x] Support merged-style and module/fallback-style Main Lua hand-offs without modifying either existing reference
- [x] Preserve one-time validation, active authorization, Match 1/2/3 reinitialization, app-restart reset, fail-closed negatives, and duplicate-init guards
- [x] Add integration instructions and explicit lifecycle adapter contract
- [x] Run Lua syntax, lifecycle, duplicate-callback, negative-path, and protected-boundary regression checks
- [x] Save a rollback-safe Universal Lua checkpoint and deliver changed-file summary

- [x] Audit the complete canonical validation flow in both existing Merged/Fallback references
- [x] Build a new separate complete Universal Lua with preserved key input, existing HTTP/API flow, host-first identity, binding, status handling, Announcement, and Maintenance
- [x] Connect canonical validation success to the lifecycle coordinator without rewriting protected communication code
- [x] Verify valid, invalid, expired, device-mismatch, Announcement, Maintenance, Match 1/2/3, restart, and duplicate-callback behavior
- [x] Verify existing references and protected production files remain unchanged
- [x] Save a rollback-safe checkpoint and deliver the complete Universal Lua file

- [x] Verify existing Merged/Fallback canonical validation and hand-off behavior for the single-file architecture
- [x] Create a separate single-file Complete Universal Lua with exactly one clearly marked full-Main-Lua insertion point
- [x] Preserve existing key input, API/HTTP, RequestForLua, validation, host-first identity, binding, status, Announcement, Telegram, Maintenance, and authentication flow without refactor
- [x] Ensure Match 1/2/3 re-entry, one validation per runtime, app-restart fresh validation, fail-closed negatives, and duplicate guards
- [x] Run syntax, single-marker, static-flow, lifecycle, negative-path, and protected-boundary regression checks
- [x] Save a rollback-safe checkpoint and document exact one-point usage

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, or Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, and Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic
- [ ] Run Lua syntax and boundary regression checks and report the exact affected files and required usage change

- [ ] Diagnose the exact `'end' expected ... near fetch_active_announcement` integration-boundary root cause using the uploaded Main Lua
- [ ] Preserve the uploaded Main Lua byte-for-byte unchanged during diagnosis and any fix
- [ ] Apply an integration-side boundary correction only if confirmed safe; do not alter HTTP, transport, validation, device identity, Announcement, Telegram, Maintenance logic

- [x] Diagnose and fix Universal Lua Main-Lua insertion boundary without modifying user Main Lua
- [x] Verify corrected single-file Universal Lua with Lua 5.3 syntax and lifecycle regression checks
