import { motion } from "framer-motion";
import {
  Activity,
  CheckCircle2,
  Cpu,
  Database,
  Fingerprint,
  KeyRound,
  Shield,
  ShieldCheck,
  Zap,
} from "lucide-react";
import { CircularProgressGauge } from "@/components/CircularProgressGauge";
import { AnimatedCounter } from "@/components/AnimatedCounter";

type SystemStats = {
  totalKeys?: number;
  activeKeys?: number;
  totalDeviceBindings?: number;
  revokedKeys?: number;
} | undefined;

export function CosmicSystemOverview({ stats, isOwner }: { stats: SystemStats; isOwner: boolean }) {
  const total = stats?.totalKeys ?? 0;
  const active = stats?.activeKeys ?? 0;
  const bindings = stats?.totalDeviceBindings ?? 0;
  const revoked = stats?.revokedKeys ?? 0;
  const activeRate = total > 0 ? Math.round((active / total) * 100) : 100;

  const containerVariants = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.08,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 16 },
    show: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.45, ease: "easeOut" as const },
    },
  };

  return (
    <motion.section
      variants={containerVariants}
      initial="hidden"
      animate="show"
      className="space-y-6"
      aria-label="Cosmic System Overview"
    >
      {/* Top Banner: Telemetry Wave & Live Heartbeat (Inspired by Image 1 Top Row) */}
      <motion.div variants={itemVariants} className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Card 1: Live Status & Glowing Sine Wave */}
        <div className="lg:col-span-2 cosmic-card p-6 relative overflow-hidden flex flex-col justify-between">
          <div className="flex items-start justify-between relative z-10">
            <div>
              <div className="flex items-center gap-2 text-xs font-semibold tracking-wider text-sky-400 uppercase">
                <span className="w-2.5 h-2.5 rounded-full bg-sky-400 animate-ping" />
                <span>LICENSE CLOUD ENGINE // 24/7 ONLINE</span>
              </div>
              <h2 className="text-2xl sm:text-3xl font-extrabold font-outfit text-white mt-1.5">
                Active Telemetry & Key Mesh
              </h2>
              <p className="text-slate-400 text-xs mt-1 max-w-lg">
                Continuous hardware device-binding enforcement and real-time anti-cloning security.
              </p>
            </div>
            <div className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-purple-500/10 border border-purple-500/25 text-purple-300 text-xs font-semibold">
              <Zap className="w-3.5 h-3.5 text-purple-400" />
              <span>TiDB Singapore</span>
            </div>
          </div>

          {/* Animated Sine Wave Activity Graph (Exact match of Image 1 waveform) */}
          <div className="relative mt-6 pt-3">
            <svg
              className="w-full h-16 overflow-visible animate-wave-glow"
              viewBox="0 0 600 60"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <defs>
                <linearGradient id="waveGrad" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" stopColor="#38bdf8" />
                  <stop offset="45%" stopColor="#818cf8" />
                  <stop offset="100%" stopColor="#c084fc" />
                </linearGradient>
                <linearGradient id="waveFill" x1="0%" y1="0%" x2="0%" y2="100%">
                  <stop offset="0%" stopColor="#38bdf8" stopOpacity="0.22" />
                  <stop offset="100%" stopColor="#38bdf8" stopOpacity="0" />
                </linearGradient>
              </defs>
              <motion.path
                initial={{ pathLength: 0 }}
                animate={{ pathLength: 1 }}
                transition={{ duration: 1.8, ease: "easeInOut" }}
                d="M0 35 C 50 15, 80 50, 130 30 C 180 10, 210 45, 260 25 C 310 5, 340 40, 390 20 C 440 5, 470 38, 520 22 C 560 10, 580 30, 600 25"
                stroke="url(#waveGrad)"
                strokeWidth="3.5"
                strokeLinecap="round"
              />
              <path
                d="M0 35 C 50 15, 80 50, 130 30 C 180 10, 210 45, 260 25 C 310 5, 340 40, 390 20 C 440 5, 470 38, 520 22 C 560 10, 580 30, 600 25 L 600 60 L 0 60 Z"
                fill="url(#waveFill)"
              />
              {/* Pulsing data points */}
              <circle cx="130" cy="30" r="4.5" fill="#38bdf8" className="animate-pulse" />
              <circle cx="260" cy="25" r="4.5" fill="#818cf8" className="animate-pulse" />
              <circle cx="390" cy="20" r="4.5" fill="#c084fc" className="animate-pulse" />
              <circle cx="520" cy="22" r="4.5" fill="#38bdf8" className="animate-pulse" />
            </svg>
          </div>

          <div className="flex items-center justify-between text-[11px] text-slate-400 pt-3 border-t border-white/[0.06] mt-2">
            <span>Uptime: 99.98% • Zero Sleep Active</span>
            <span className="text-emerald-400 font-medium flex items-center gap-1">
              <CheckCircle2 className="w-3.5 h-3.5" /> All Services Operational
            </span>
          </div>
        </div>

        {/* Card 2: System Status Telemetry Gauge (Matching "System Status 92%" in Image 1) */}
        <div className="cosmic-card p-6 flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-slate-300">System Telemetry</span>
            <span className="text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-300 border border-emerald-500/20 font-semibold">
              OPTIMAL
            </span>
          </div>

          {/* Animated Circular Ring 100% Optimal */}
          <div className="flex items-center justify-center my-3">
            <CircularProgressGauge
              value={99}
              size={116}
              strokeWidth={8}
              gradientId="systemHealthGrad"
              startColor="#38bdf8"
              endColor="#10b981"
              glowColor="#38bdf8"
              centerLabel="Optimal"
              centerSublabel="Online"
            />
          </div>

          {/* Mini progress bars (Storage, Cloud, Ping) */}
          <div className="space-y-2 text-xs">
            <div className="flex items-center justify-between text-slate-300">
              <span className="flex items-center gap-1.5 text-slate-400">
                <Database className="w-3.5 h-3.5 text-sky-400" /> TiDB Cloud
              </span>
              <span className="font-semibold text-white">Connected</span>
            </div>
            <div className="w-full bg-white/[0.06] h-1.5 rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: "96%" }}
                transition={{ duration: 1, ease: "easeOut" }}
                className="bg-sky-400 h-full rounded-full"
              />
            </div>

            <div className="flex items-center justify-between text-slate-300 mt-2">
              <span className="flex items-center gap-1.5 text-slate-400">
                <Cpu className="w-3.5 h-3.5 text-purple-400" /> Keep-Alive 24/7
              </span>
              <span className="font-semibold text-white">Active (200 OK)</span>
            </div>
            <div className="w-full bg-white/[0.06] h-1.5 rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: "100%" }}
                transition={{ duration: 1.2, ease: "easeOut" }}
                className="bg-gradient-to-r from-purple-500 to-indigo-500 h-full rounded-full"
              />
            </div>
          </div>
        </div>
      </motion.div>

      {/* Row 2: 3 Circular Gauges ("jo round round hota he like kitna kya hua he" - Exact match of Image 1!) */}
      <motion.div variants={itemVariants} className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {/* Gauge 1: Active Licenses Ratio (like 78% Productivity in Image 1) */}
        <motion.div
          whileHover={{ y: -4, transition: { duration: 0.2 } }}
          className="cosmic-card p-6 flex items-center justify-between"
        >
          <div>
            <span className="text-[10px] uppercase font-bold tracking-widest text-sky-400">
              Active Ratio
            </span>
            <h3 className="text-xl font-bold font-outfit text-white mt-1">
              Active Licenses
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              <span className="text-white font-semibold">
                <AnimatedCounter value={active} />
              </span>{" "}
              of{" "}
              <span className="text-slate-300">
                <AnimatedCounter value={total} />
              </span>{" "}
              total keys
            </p>
            <div className="mt-3 inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-sky-500/10 border border-sky-500/20 text-sky-300 text-[11px] font-medium">
              <CheckCircle2 className="w-3 h-3 text-sky-400" />
              <span>Valid access</span>
            </div>
          </div>

          <CircularProgressGauge
            value={activeRate}
            size={116}
            strokeWidth={9}
            gradientId="activeLicensesGrad"
            startColor="#00f0ff"
            endColor="#8b5cf6"
            glowColor="#00f0ff"
            centerLabel="Active"
          />
        </motion.div>

        {/* Gauge 2: Hardware Device Security (like 25:00 Focus Timer in Image 1) */}
        <motion.div
          whileHover={{ y: -4, transition: { duration: 0.2 } }}
          className="cosmic-card p-6 flex items-center justify-between"
        >
          <div>
            <span className="text-[10px] uppercase font-bold tracking-widest text-amber-400">
              Hardware Shield
            </span>
            <h3 className="text-xl font-bold font-outfit text-white mt-1">
              Bound Devices
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              <span className="text-white font-semibold">
                <AnimatedCounter value={bindings} />
              </span>{" "}
              unique hardware IDs
            </p>
            <div className="mt-3 inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-amber-500/10 border border-amber-500/20 text-amber-300 text-[11px] font-medium">
              <Fingerprint className="w-3 h-3 text-amber-400" />
              <span>Anti-cloning locked</span>
            </div>
          </div>

          <CircularProgressGauge
            value={total > 0 ? Math.min(Math.round((bindings / Math.max(total, 1)) * 100), 100) : 100}
            size={116}
            strokeWidth={9}
            gradientId="deviceShieldGrad"
            startColor="#f59e0b"
            endColor="#f97316"
            glowColor="#f97316"
            customCenter={
              <div className="flex flex-col items-center">
                <span className="font-outfit text-2xl font-extrabold text-white">
                  <AnimatedCounter value={bindings} />
                </span>
                <span className="text-[10px] text-amber-300 uppercase tracking-wider font-semibold">
                  Devices
                </span>
              </div>
            }
          />
        </motion.div>

        {/* Gauge 3: Security & Revoked State */}
        <motion.div
          whileHover={{ y: -4, transition: { duration: 0.2 } }}
          className="cosmic-card p-6 flex items-center justify-between"
        >
          <div>
            <span className="text-[10px] uppercase font-bold tracking-widest text-rose-400">
              Access Guard
            </span>
            <h3 className="text-xl font-bold font-outfit text-white mt-1">
              Revoked / Blocked
            </h3>
            <p className="text-xs text-slate-400 mt-1">
              <span className="text-white font-semibold">
                <AnimatedCounter value={revoked} />
              </span>{" "}
              blocked records
            </p>
            <div className="mt-3 inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-rose-500/10 border border-rose-500/20 text-rose-300 text-[11px] font-medium">
              <Shield className="w-3 h-3 text-rose-400" />
              <span>Protection active</span>
            </div>
          </div>

          <CircularProgressGauge
            value={total > 0 ? Math.round((revoked / total) * 100) : 0}
            size={116}
            strokeWidth={9}
            gradientId="revokedGrad"
            startColor="#f43f5e"
            endColor="#e11d48"
            glowColor="#f43f5e"
            customCenter={
              <div className="flex flex-col items-center">
                <span className="font-outfit text-2xl font-extrabold text-white">
                  <AnimatedCounter value={revoked} />
                </span>
                <span className="text-[10px] text-rose-300 uppercase tracking-wider font-semibold">
                  Blocked
                </span>
              </div>
            }
          />
        </motion.div>
      </motion.div>

      {/* Row 3: 4 Metric Cards with Hover Physics (Animated Numbers) */}
      <motion.div variants={itemVariants} className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5">
        {/* Metric 1 */}
        <motion.div
          whileHover={{ y: -3, scale: 1.01 }}
          transition={{ duration: 0.2 }}
          className="cosmic-card p-5 flex items-center justify-between"
        >
          <div>
            <p className="text-[11px] font-semibold tracking-wider text-slate-400 uppercase">
              Active Licenses
            </p>
            <p className="text-3xl font-extrabold font-outfit text-white mt-1">
              <AnimatedCounter value={active} formatter={(n) => String(n).padStart(2, "0")} />
            </p>
            <p className="text-[11px] text-emerald-400 mt-1 font-medium">
              {activeRate}% of registry
            </p>
          </div>
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-emerald-500/20 to-teal-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 shadow-[0_0_20px_rgba(16,185,129,0.25)]">
            <ShieldCheck className="w-7 h-7" />
          </div>
        </motion.div>

        {/* Metric 2 */}
        <motion.div
          whileHover={{ y: -3, scale: 1.01 }}
          transition={{ duration: 0.2 }}
          className="cosmic-card p-5 flex items-center justify-between"
        >
          <div>
            <p className="text-[11px] font-semibold tracking-wider text-slate-400 uppercase">
              Bound Devices
            </p>
            <p className="text-3xl font-extrabold font-outfit text-white mt-1">
              <AnimatedCounter value={bindings} formatter={(n) => String(n).padStart(2, "0")} />
            </p>
            <p className="text-[11px] text-sky-400 mt-1 font-medium">
              Hardware locked
            </p>
          </div>
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-sky-500/20 to-blue-500/10 border border-sky-500/30 flex items-center justify-center text-sky-400 shadow-[0_0_20px_rgba(56,189,248,0.25)]">
            <Fingerprint className="w-7 h-7" />
          </div>
        </motion.div>

        {/* Metric 3 */}
        <motion.div
          whileHover={{ y: -3, scale: 1.01 }}
          transition={{ duration: 0.2 }}
          className="cosmic-card p-5 flex items-center justify-between"
        >
          <div>
            <p className="text-[11px] font-semibold tracking-wider text-slate-400 uppercase">
              Total Keys
            </p>
            <p className="text-3xl font-extrabold font-outfit text-white mt-1">
              <AnimatedCounter value={total} formatter={(n) => String(n).padStart(2, "0")} />
            </p>
            <p className="text-[11px] text-purple-400 mt-1 font-medium">
              Registered records
            </p>
          </div>
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-purple-500/20 to-indigo-500/10 border border-purple-500/30 flex items-center justify-center text-purple-400 shadow-[0_0_20px_rgba(168,85,247,0.25)]">
            <KeyRound className="w-7 h-7" />
          </div>
        </motion.div>

        {/* Metric 4 */}
        <motion.div
          whileHover={{ y: -3, scale: 1.01 }}
          transition={{ duration: 0.2 }}
          className="cosmic-card p-5 flex items-center justify-between"
        >
          <div>
            <p className="text-[11px] font-semibold tracking-wider text-slate-400 uppercase">
              Revoked / Muted
            </p>
            <p className="text-3xl font-extrabold font-outfit text-white mt-1">
              <AnimatedCounter value={revoked} formatter={(n) => String(n).padStart(2, "0")} />
            </p>
            <p className="text-[11px] text-rose-400 mt-1 font-medium">
              Access blocked
            </p>
          </div>
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-rose-500/20 to-pink-500/10 border border-rose-500/30 flex items-center justify-center text-rose-400 shadow-[0_0_20px_rgba(244,63,94,0.25)]">
            <Shield className="w-7 h-7" />
          </div>
        </motion.div>
      </motion.div>
    </motion.section>
  );
}
