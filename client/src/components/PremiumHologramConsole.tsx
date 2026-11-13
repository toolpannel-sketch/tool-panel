import { Activity, BadgeCheck, BellRing, Boxes, CalendarClock, Fingerprint, Gauge, KeyRound, Radar, ShieldCheck, Siren, Zap } from "lucide-react";

type SystemStats = {
  totalKeys?: number;
  activeKeys?: number;
  totalDeviceBindings?: number;
  revokedKeys?: number;
} | undefined;

function SignalRow({ label, value, tone, icon: Icon, detail }: { label: string; value: string; tone: "green" | "cyan" | "amber" | "red"; icon: typeof Activity; detail: string }) {
  return <div className={`holo-signal holo-signal-${tone}`}><div className="holo-signal-icon"><Icon /></div><div className="min-w-0 flex-1"><span>{label}</span><div className="holo-signal-line"><i /><i /><i /><i /><i /><i /><i /><i /></div><small>{detail}</small></div><b>{value}</b></div>;
}

export function PremiumHologramConsole({ stats, isOwner }: { stats: SystemStats; isOwner: boolean }) {
  const total = stats?.totalKeys ?? 0;
  const active = stats?.activeKeys ?? 0;
  const bindings = stats?.totalDeviceBindings ?? 0;
  const revoked = stats?.revokedKeys ?? 0;
  const activeRate = total > 0 ? Math.round((active / total) * 100) : 0;

  return <section className="premium-holo-console" aria-label="Premium Lua System command center">
    <div className="holo-top-grid">
      <div className="holo-intro"><p className="premium-kicker">PREMIUM LUA SYSTEM</p><h1>COMMAND <em>INTERFACE</em></h1><p>Unified control for licensed access, protected device binding, and approved control surfaces.</p><div className="holo-access-lane"><span>ACCESS LANE</span><b>READY</b><i /><small>EXISTING PANEL FLOW</small></div></div>
      <div className="holo-stage" aria-hidden="true"><div className="holo-stage-grid" /><div className="holo-stage-horizon" /><div className="holo-scan-cone" /><div className="holo-platform holo-platform-a" /><div className="holo-platform holo-platform-b" /><div className="holo-orbit holo-orbit-a" /><div className="holo-orbit holo-orbit-b" /><span className="holo-float-node node-green"><ShieldCheck /></span><span className="holo-float-node node-amber"><Gauge /></span><span className="holo-float-node node-red"><Siren /></span><div className="holo-core"><div><span>PL</span><Radar /></div></div></div>
      <aside className="holo-system-card"><div className="holo-card-title"><Radar /> SYSTEM OVERVIEW</div><SignalRow label="ACTIVE LICENSES" value={`${active}`} detail={`${activeRate}% of current registry`} tone="green" icon={BadgeCheck} /><SignalRow label="DEVICE BINDINGS" value={`${bindings}`} detail="server-authoritative" tone="cyan" icon={Fingerprint} /><SignalRow label="LICENSE REGISTRY" value={`${total}`} detail="existing key records" tone="amber" icon={KeyRound} /><SignalRow label="REVOKED KEYS" value={`${revoked}`} detail="auditable control state" tone="red" icon={Siren} /><div className="holo-card-footer"><i /> {isOwner ? "OWNER CONTROL SURFACE" : "ADMIN CONTROL SURFACE"}</div></aside>
    </div>
    <div className="holo-module-grid">
      <article className="holo-module holo-license-matrix"><div className="holo-module-title"><span><Boxes /> LICENSE MATRIX</span><b>LIVE VIEW</b></div><SignalRow label="ACTIVE ACCESS" value={`${active}`} detail="existing valid licenses" tone="green" icon={BadgeCheck} /><SignalRow label="DEVICE SHIELD" value={`${bindings}`} detail="tracked binding records" tone="cyan" icon={Fingerprint} /><SignalRow label="KEY REVIEW" value={`${revoked}`} detail="revoked visual state" tone="red" icon={Siren} /><div className="holo-module-foot green"><ShieldCheck /> Existing license controls preserved</div></article>
      <article className="holo-module holo-device-shield"><div className="holo-module-title"><span><ShieldCheck /> DEVICE SHIELD</span><b>PROTECTED</b></div><div className="holo-shield-visual"><div className="holo-shield-ring" /><ShieldCheck /><span>DEVICE<br />BINDING</span></div><div className="holo-shield-list"><p><i /> Canonical validation</p><p><i /> Host identity support</p><p><i /> Binding policy enforced</p></div><div className="holo-module-foot cyan"><Fingerprint /> Existing binding flow unchanged</div></article>
      <div className="holo-side-stack"><article className="holo-module holo-signal-module"><div className="holo-module-title"><span><BellRing /> ANNOUNCEMENT SIGNAL</span><b>CONTROL</b></div><div className="holo-mini-orbit"><BellRing /></div><div><strong>Announcement surface</strong><p>Existing announcement controls remain available through the protected panel flow.</p></div></article><article className="holo-module holo-maintenance-module"><div className="holo-module-title"><span><CalendarClock /> MAINTENANCE WINDOW</span><b>CONTROL</b></div><div className="holo-maintenance-orb"><span>SYS</span></div><div><strong>Maintenance surface</strong><p>Existing maintenance controls remain isolated and role-protected.</p></div></article></div>
    </div>
  </section>;
}
