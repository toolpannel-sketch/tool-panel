import { CircleDotDashed, Fingerprint, Radar, ShieldAlert, TriangleAlert, Zap } from "lucide-react";

type SpectrumStats = {
  totalKeys?: number;
  activeKeys?: number;
  totalDeviceBindings?: number;
} | undefined;

export function PremiumSpectrumOverview({ stats }: { stats: SpectrumStats }) {
  const totalKeys = stats?.totalKeys ?? 0;
  const activeKeys = stats?.activeKeys ?? 0;
  const bindings = stats?.totalDeviceBindings ?? 0;

  return <section className="premium-spectrum" aria-label="Premium Lua System visual spectrum overview">
    <div className="premium-spectrum-copy"><p className="premium-kicker">SPECTRUM OVERVIEW // VISUAL TELEMETRY</p><h2>CONTROL <em>SPECTRUM</em></h2><p>Three restrained color lanes distinguish protected access, attention surfaces, and critical visual states without changing existing panel behavior.</p><div className="premium-spectrum-readouts"><span className="readout-green"><Zap /> ACTIVE KEYS <b>{String(activeKeys).padStart(2, "0")}</b></span><span className="readout-yellow"><CircleDotDashed /> LICENSE REGISTRY <b>{String(totalKeys).padStart(2, "0")}</b></span><span className="readout-red"><Fingerprint /> DEVICE BINDINGS <b>{String(bindings).padStart(2, "0")}</b></span></div></div>
    <div className="premium-spectrum-radar" aria-hidden="true"><div className="spectrum-grid" /><div className="spectrum-sweep" /><div className="spectrum-core"><Radar /><span>CONTROL<br />CORE</span></div><span className="spectrum-node spectrum-node-green"><Zap /> ACTIVE</span><span className="spectrum-node spectrum-node-yellow"><TriangleAlert /> TELEMETRY</span><span className="spectrum-node spectrum-node-red"><ShieldAlert /> GUARD</span></div>
  </section>;
}
