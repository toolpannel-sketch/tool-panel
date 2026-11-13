import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

describe("Lua source exposure policy", () => {
  it("does not expose any reusable or merged Lua download route through the panel", () => {
    const source = readFileSync(resolve(process.cwd(), "server/licenseRoutes.ts"), "utf8");
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    expect(source).not.toContain("/api/download/");
    expect(source).not.toContain("BRPlayerCharacterBase-Reusable.lua");
    expect(home).not.toContain("BR Character Reusable");
    expect(home).not.toContain("/api/download/");
    expect(source).not.toContain("/api/download/BRPlayerCharacterBase.lua");
    expect(source).not.toContain("/api/download/features.lua");
    expect(source).not.toContain("/api/download/bot.py");
  });
});

describe("isolated server maintenance boundaries", () => {
  it("uses the existing Super Owner gate for maintenance configuration without altering owner identity checks", () => {
    const router = readFileSync(resolve(process.cwd(), "server/routers.ts"), "utf8");
    expect(router).toContain("maintenance: superOwnerProcedure.query");
    expect(router).toContain("updateMaintenance: superOwnerProcedure.input");
    expect(router).not.toContain("maintenance: adminProcedure");
    expect(router).not.toContain("maintenance: protectedProcedure");
  });

  it("exposes isolated public Announcement and Maintenance state routes while leaving the canonical validation route unchanged", () => {
    const routes = readFileSync(resolve(process.cwd(), "server/licenseRoutes.ts"), "utf8");
    const canonicalStart = routes.indexOf('app.post("/api/license/validate"');
    const canonical = routes.slice(canonicalStart, routes.indexOf("\n  });", canonicalStart) + 5);
    expect(routes).toContain('app.get("/api/announcement/active"');
    expect(routes).toContain('app.post("/api/announcement/active"');
    expect(routes).toContain("getActiveSystemAnnouncement()");
    expect(routes).toContain('app.get("/api/maintenance/active"');
    expect(routes).toContain('app.post("/api/maintenance/active"');
    expect(routes).toContain("getActiveServerMaintenance()");
    expect(canonical).toContain("validateCanonicalLicense(key, deviceId)");
    expect(canonical).not.toContain("maintenance");
  });

  it("uses the Android bridge's documented POST path only for isolated post-validation status reads and keeps key-entry diagnostics key-free", () => {
    const merged = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-Merged.lua"), "utf8");
    expect(merged).toContain('RequestForLua(MAINTENANCE_URL, "POST", headers, request_body, 0, 0)');
    expect(merged).not.toContain('RequestForLua(MAINTENANCE_URL, "GET"');
    expect(merged).toContain('local request_body = "{}"');
    expect(merged).toContain('presentation_request(ANNOUNCEMENT_URL, {}, function(response)');
    expect(merged).toContain('self.UIRoot.Text_Name.GetText');
    expect(merged).toContain('self.on_submit(submitted_key, { source = input_source, length = #submitted_key })');
    expect(merged).toContain('"ACCESS_GRANTED input_source=" .. trace_source .. " input_length=" .. tostring(trace_length) .. " validation_status=valid"');
    expect(merged).not.toContain('write_status, key');
    expect(merged).not.toContain('write_status, device');
  });

  it("keeps separate Super Owner maintenance controls outside the existing announcement form", () => {
    const systemControl = readFileSync(resolve(process.cwd(), "client/src/pages/SystemControl.tsx"), "utf8");
    expect(systemControl).toContain("trpc.superOwner.maintenance.useQuery");
    expect(systemControl).toContain("trpc.superOwner.updateMaintenance.useMutation");
    expect(systemControl).toContain("Server maintenance");
    expect(systemControl).toContain("({message.length}/300)");
    expect(systemControl).toContain("saved and evaluated as UTC");
  });
});

describe("Super Owner control-page navigation", () => {
  it("adds only the requested sibling routes and cards while leaving the Global Review route unchanged", () => {
    const app = readFileSync(resolve(process.cwd(), "client/src/App.tsx"), "utf8");
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    expect(app).toContain('path="/system-control"');
    expect(app).toContain('path="/announcement-control"');
    expect(app).toContain('path="/super-owner"');
    expect(home).toContain('href="/super-owner"');
    expect(home).toContain('href="/system-control"');
    expect(home).toContain('href="/announcement-control"');
  });

  it("reuses existing feature procedures behind active Super Owner presentation guards", () => {
    const systemControl = readFileSync(resolve(process.cwd(), "client/src/pages/SystemControl.tsx"), "utf8");
    const announcementControl = readFileSync(resolve(process.cwd(), "client/src/pages/AnnouncementControl.tsx"), "utf8");
    expect(systemControl).toContain('identity.data?.role === "super_owner" && identity.data.accessStatus === "active"');
    expect(systemControl).toContain("trpc.superOwner.updateMaintenance.useMutation");
    expect(announcementControl).toContain('identity.data?.role === "super_owner" && identity.data.accessStatus === "active"');
    expect(announcementControl).toContain("trpc.superOwner.updateAnnouncement.useMutation");
    expect(announcementControl).toContain("TelegramExtensionCard");
    expect(announcementControl).not.toContain("updateMaintenance");
  });
});

describe("post-redemption username onboarding", () => {
  it("opens the username prompt only after the server reports that a redeemed account needs one", () => {
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    const routerSource = readFileSync(resolve(process.cwd(), "server/routers.ts"), "utf8");
    expect(routerSource).toContain("setUsername: protectedProcedure");
    expect(home).toContain("const redeem = trpc.referrals.redeem.useMutation");
    expect(home).toContain("if (data.needsUsername)");
    expect(home).toContain("setUsernameDialogOpen(true)");
  });

  it("keeps the signed-in account ID read-only while requiring the chosen username", () => {
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    expect(home).toContain("signed-in ID");
    expect(home).toContain("readOnly");
    expect(home).toContain("saveUsername.mutate({ username: usernameInput })");
    expect(home).toContain("trpc.users.changeUsername.useMutation");
    expect(home).toContain("server-enforced 72-hour cooldown");
  });

  it("exposes Super Owner-only global overview procedures and navigation without widening ordinary dashboard scope", () => {
    const routerSource = readFileSync(resolve(process.cwd(), "server/routers.ts"), "utf8");
    const overview = readFileSync(resolve(process.cwd(), "client/src/pages/SuperOwnerOverview.tsx"), "utf8");
    const service = readFileSync(resolve(process.cwd(), "server/license.ts"), "utf8");
    expect(routerSource).toContain("seasonCounts: superOwnerProcedure");
    expect(routerSource).toContain("allKeysOverview: superOwnerProcedure");
    expect(routerSource).toContain("referralOverview: superOwnerProcedure");
    expect(routerSource).toContain("deleteAllKeys: superOwnerProcedure");
    expect(routerSource).toContain("deleteAllReferrals: superOwnerProcedure");
    expect(overview).toContain("Delete <span className=\"text-pink-200\">{count}</span>");
    expect(overview).toContain("Every current license key and its device bindings will be removed.");
    expect(service).toContain('action: "all_keys_deleted"');
    expect(service).toContain('action: "all_referrals_deleted"');
  });
});

describe("Super Owner key visibility boundaries", () => {
  it("uses the creator-scoped key query on Home and retains the existing panel-wide query for Global Review", () => {
    const routerSource = readFileSync(resolve(process.cwd(), "server/routers.ts"), "utf8");
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    const overview = readFileSync(resolve(process.cwd(), "client/src/pages/SuperOwnerOverview.tsx"), "utf8");
    expect(routerSource).toContain("homeKeys: adminProcedure.query");
    expect(home).toContain("trpc.dashboard.homeKeys.useQuery");
    expect(home).toContain("YOUR KEY REGISTRY");
    expect(home).toContain("Keys you generated");
    expect(home).not.toContain("trpc.superOwner.deleteAllKeys.useMutation");
    expect(home).not.toContain("DELETE ALL PANEL KEYS?");
    expect(overview).toContain("trpc.superOwner.allKeysOverview.useQuery");
  });

  it("keeps the panel-wide destructive action in Global Review, confirmation-gated, and isolated from ordinary Home deletion", () => {
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    const overview = readFileSync(resolve(process.cwd(), "client/src/pages/SuperOwnerOverview.tsx"), "utf8");
    const service = readFileSync(resolve(process.cwd(), "server/license.ts"), "utf8");
    expect(overview).toContain("CONFIRM GLOBAL DELETE");
    expect(overview).toContain("YES, DELETE ${count}");
    expect(overview).toContain("deleteKeys.mutate()");
    expect(overview).toContain("utils.dashboard.homeKeys.invalidate()");
    expect(home).not.toContain("deleteAllKeys.mutate()");
    expect(service).toContain("await tx.delete(deviceBindings);");
    expect(service).toContain("await tx.delete(licenses);");
    expect(service).toContain('action: "all_keys_deleted"');
  });
});

describe("Home and Global Review key registry placement", () => {
  it("keeps the legacy dedicated route absent while Global Review owns the all-key registry", () => {
    const app = readFileSync(resolve(process.cwd(), "client/src/App.tsx"), "utf8");
    const overview = readFileSync(resolve(process.cwd(), "client/src/pages/SuperOwnerOverview.tsx"), "utf8");
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    expect(app).not.toContain("/super-owner/all-keys");
    expect(overview).not.toContain("ALL KEY REVIEW");
    expect(overview).toContain("ALL KEYS");
    expect(overview).toContain("creator");
    expect(home).toContain("trpc.dashboard.homeKeys.useQuery");
    expect(home).not.toContain("YES, DELETE ALL KEYS");
  });

  it("retains the existing Super Owner-only global delete procedure on Global Review", () => {
    const home = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");
    const overview = readFileSync(resolve(process.cwd(), "client/src/pages/SuperOwnerOverview.tsx"), "utf8");
    const routerSource = readFileSync(resolve(process.cwd(), "server/routers.ts"), "utf8");
    expect(overview).toContain("DELETE ALL KEYS");
    expect(overview).toContain("CONFIRM GLOBAL DELETE");
    expect(overview).toContain("deleteKeys.mutate()");
    expect(home).not.toContain("DELETE ALL KEYS");
    expect(routerSource).toContain("deleteAllKeys: superOwnerProcedure.mutation");
  });
});

describe("public transport diagnostic", () => {
  it("provides a side-effect-free GET transport ping distinct from validation", () => {
    const source = readFileSync(resolve(process.cwd(), "server/licenseRoutes.ts"), "utf8");
    expect(source).toContain('app.get("/v1/transport-ping"');
    expect(source).toContain('app.post("/v1/transport-ping"');
    expect(source).toContain('send(\'{"ok":true,"service":"lua-license-panel"}\')');
    expect(source).toContain('req.body?.test !== "ping"');
    expect(source).toContain('send(\'{"ok":true,"test":"ping"}\')');
    expect(source).toContain('app.post("/v1/validate"');
  });

  it("provides a correlated key-free ping record without retaining sensitive request values", () => {
    const source = readFileSync(resolve(process.cwd(), "server/licenseRoutes.ts"), "utf8");
    const diagnosticSection = source.slice(source.indexOf('app.post("/ping", transportPingLimiter'), source.indexOf('app.post("/v1/validate"'));
    expect(source).toContain('app.post("/ping", transportPingLimiter');
    expect(source).toContain('req.get("X-Transport-Probe-Id")');
    expect(source).toContain('requestReceived: true');
    expect(source).toContain('requestBodyReceived: true');
    expect(source).toContain('responseGenerated: true');
    expect(source).toContain('res.once("finish"');
    expect(source).toContain('app.get("/ping/diagnostic/:requestId"');
    expect(diagnosticSection).not.toContain('device_id');
    expect(diagnosticSection).not.toContain('licenseKey');
  });

  it("keeps the matching GET probe key-free and contract-bound", () => {
    const probe = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-HttpManagerGetProbe.lua"), "utf8");
    expect(probe).toContain("http_manager:Get(API_URL, headers, \"\", nil");
    expect(probe).toContain("/v1/transport-ping");
    expect(probe).toContain("HTTP_MANAGER_GET_CALLBACK");
    expect(probe).not.toContain("key.json");
    expect(probe).not.toContain("loadstring");
  });

  it("keeps the successful POST ping probe key-free and uses the documented Post contract", () => {
    const probe = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-HttpManagerPostPingProbe.lua"), "utf8");
    expect(probe).toContain("http_manager:Post(API_URL, headers, body, nil");
    expect(probe).toContain("/v1/transport-ping");
    expect(probe).toContain("local body = '{\"test\":\"ping\"}'");
    expect(probe).toContain("data_matches_expected");
    expect(probe).toContain("content_matches_expected");
    expect(probe).toContain("HTTP_MANAGER_POST_PING_CALLBACK");
    expect(probe).not.toContain("key.json");
    expect(probe).not.toContain("loadstring");
  });

  it("keeps the correlated direct-wrapper ping probe key-free and within the documented bridge", () => {
    const probe = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-HttpWrapperCorrelatedPingProbe.lua"), "utf8");
    expect(probe).toContain("slua_GameFrontendHUD:GetHttpWrapper()");
    expect(probe).toContain('http_wrapper:RequestForLua(API_URL, "POST", headers, REQUEST_BODY, PRIORITY, QUEUE_TYPE)');
    expect(probe).toContain('["X-Transport-Probe-Id"] = REQUEST_ID');
    expect(probe).toContain("HTTP_WRAPPER_CORRELATED_PING_CALLBACK");
    expect(probe).not.toContain("key.json");
    expect(probe).not.toContain("device_id");
    expect(probe).not.toContain("loadstring");
  });

  it("exposes the canonical license validation route with rate limiting and JSON-only responses", () => {
    const source = readFileSync(resolve(process.cwd(), "server/licenseRoutes.ts"), "utf8");
    expect(source).toContain('app.post("/api/license/validate", canonicalValidationLimiter');
    expect(source).toContain('limit: 20');
    expect(source).toContain('res.set("Cache-Control", "no-store")');
    expect(source).toContain('status: "not_registered"');
    expect(source).toContain('status: "invalid"');
    expect(source).toContain('validateCanonicalLicense(key, deviceId)');
    const service = readFileSync(resolve(process.cwd(), "server/license.ts"), "utf8");
    expect(service).toContain('"device_max_reached"');
    expect(service).toContain('isDeviceLimitReached(bindingCount, lockedRow.maxDevices)');
    expect(service).toContain('expiresAt?: string');
    expect(service).toContain('getActivationTransition(lockedRow)');
    expect(service).toContain('activation.expiresAt ? { expiresAt: activation.expiresAt.toISOString() } : {}');
  });

  it("prevents the SPA fallback from serving HTML to unmatched POST API requests", () => {
    const source = readFileSync(resolve(process.cwd(), "server/_core/vite.ts"), "utf8");
    expect(source).toContain('req.method !== "GET" && req.method !== "HEAD"');
    expect(source).toContain('res.status(404).json({ success: false, status: "not_registered", message: "API endpoint not found." })');
  });
});

export {};

// Legacy source downloads are intentionally absent; Lua artifacts are delivered outside the panel.
