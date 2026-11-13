import { useEffect, useState } from "react";
import { useAuth } from "@/_core/hooks/useAuth";
import { COOKIE_NAME } from "@shared/const";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { trpc } from "@/lib/trpc";
import { Link, useLocation } from "wouter";
import { motion, AnimatePresence } from "framer-motion";
import {
  Cable,
  Database,
  KeyRound,
  LayoutDashboard,
  LogOut,
  ShieldCheck,
  Sparkles,
  Users,
  Terminal,
} from "lucide-react";

function AuthGate() {
  const [tab, setTab] = useState<"login" | "register">("login");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [referralCode, setReferralCode] = useState("");
  const [error, setError] = useState("");

  const loginMutation = trpc.auth.login.useMutation({
    onSuccess: () => {
      window.location.reload();
    },
    onError: (err) => {
      setError(err.message || "Invalid credentials");
    },
  });

  const registerMutation = trpc.auth.register.useMutation({
    onSuccess: () => {
      window.location.reload();
    },
    onError: (err) => {
      setError(err.message || "Registration failed");
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (tab === "login") {
      loginMutation.mutate({ username, password });
    } else {
      registerMutation.mutate({ username, password, referralCode });
    }
  };

  const isPending = loginMutation.isPending || registerMutation.isPending;

  return (
    <div className="min-h-screen bg-[#080b12] relative flex items-center justify-center p-4 overflow-hidden font-sans-modern">
      {/* Background ambient lighting */}
      <div className="absolute -top-40 left-1/2 -translate-x-1/2 w-[700px] h-[350px] bg-emerald-500/10 rounded-full blur-[140px] pointer-events-none" />
      <div className="absolute bottom-10 right-10 w-80 h-80 bg-cyan-500/10 rounded-full blur-[120px] pointer-events-none" />

      {/* Modern Glass Card */}
      <motion.div
        initial={{ opacity: 0, scale: 0.96, y: 12 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        transition={{ duration: 0.4, ease: "easeOut" }}
        className="relative z-10 max-w-md w-full p-8 sm:p-10 rounded-[28px] bg-[#0d121f]/90 backdrop-blur-3xl border border-white/[0.08] shadow-[0_24px_70px_rgba(0,0,0,0.8),0_0_50px_rgba(16,185,129,0.08)]"
      >
        {/* Brand / Logo */}
        <div className="text-center mb-7">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-2xl bg-gradient-to-tr from-emerald-500 to-cyan-500 text-white shadow-[0_0_25px_rgba(16,185,129,0.4)] mb-4">
            <Terminal className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="font-outfit text-3xl font-extrabold tracking-tight text-white">
              TOOL PANEL
            </h1>
            <p className="text-emerald-400 text-[11px] font-semibold tracking-widest uppercase mt-1">
              Next-Gen License Cloud Engine
            </p>
          </div>
          <p className="text-slate-400 text-xs mt-3">
            {tab === "login"
              ? "Sign in with your Super Owner or Admin credentials"
              : "Enter your invite referral code to join the mesh"}
          </p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-950/50 border border-red-500/40 text-red-200 text-xs rounded-xl backdrop-blur-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-300 mb-1.5">
              Username
            </label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="cyber-input w-full px-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none"
              placeholder="e.g. ALEXALORD"
              required
            />
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-300 mb-1.5">
              Password
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="cyber-input w-full px-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none"
              placeholder="••••••••••••"
              required
            />
          </div>

          {tab === "register" && (
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-cyan-300 mb-1.5">
                Invite / Referral Code
              </label>
              <input
                type="text"
                value={referralCode}
                onChange={(e) => setReferralCode(e.target.value)}
                className="cyber-input w-full px-4 py-3 text-sm text-white placeholder-slate-500 uppercase tracking-widest focus:outline-none"
                placeholder="REF-XXXXX"
                required
              />
            </div>
          )}

          <button
            type="submit"
            disabled={isPending}
            className="cyber-button w-full py-3.5 mt-2 rounded-xl text-white font-semibold text-sm flex items-center justify-center gap-2"
          >
            {isPending ? (
              <span>Authenticating...</span>
            ) : tab === "login" ? (
              <span>Sign In to Panel</span>
            ) : (
              <span>Register Account</span>
            )}
          </button>
        </form>

        {/* Footer Toggle */}
        <div className="mt-7 text-center pt-5 border-t border-white/[0.06]">
          {tab === "login" ? (
            <p className="text-slate-400 text-xs">
              Need an account?{" "}
              <button
                type="button"
                onClick={() => {
                  setTab("register");
                  setError("");
                }}
                className="text-emerald-400 hover:text-emerald-300 font-semibold underline ml-1"
              >
                Redeem Invite Code
              </button>
            </p>
          ) : (
            <p className="text-slate-400 text-xs">
              Already have an account?{" "}
              <button
                type="button"
                onClick={() => {
                  setTab("login");
                  setError("");
                }}
                className="text-emerald-400 hover:text-emerald-300 font-semibold underline ml-1"
              >
                Sign In
              </button>
            </p>
          )}
        </div>
      </motion.div>
    </div>
  );
}

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, isAuthenticated, loading, logout } = useAuth();
  const identity = trpc.dashboard.identity.useQuery(undefined, {
    enabled: isAuthenticated,
  });
  const [location] = useLocation();
  const [timeStr, setTimeStr] = useState("");

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTimeStr(
        now.toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit",
          hour12: true,
        })
      );
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#080b12] flex items-center justify-center">
        <div className="flex items-center gap-3 text-emerald-400 text-sm font-medium">
          <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-ping" />
          <span>INITIALIZING SECURE ENGINE...</span>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <AuthGate />;
  }

  const role = identity.data?.role || user?.role || "admin";
  const isSuperOwner = role === "super_owner";
  const isOwner = isSuperOwner || role === "owner";
  const displayName = identity.data?.username || user?.name || user?.email || "Operator";
  const roleLabel = isSuperOwner ? "Super Owner" : isOwner ? "Owner" : "Admin";

  return (
    <div className="min-h-screen cosmic-backdrop text-slate-100 font-sans-modern relative overflow-x-hidden">
      {/* Floating Modern Slim Dock */}
      <aside className="fixed left-5 top-5 bottom-5 w-64 cosmic-dock hidden lg:flex flex-col justify-between p-5 z-40">
        <div>
          {/* Top Brand Logo */}
          <div className="flex items-center gap-3 pb-5 mb-5 border-b border-white/[0.07]">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-emerald-500 to-cyan-500 flex items-center justify-center text-white shadow-[0_0_20px_rgba(16,185,129,0.4)]">
              <Terminal className="w-5 h-5 text-white" />
            </div>
            <div className="min-w-0">
              <h2 className="font-outfit font-bold tracking-wider text-base text-white truncate">
                TOOL PANEL
              </h2>
              <p className="text-[10px] text-emerald-400 font-semibold tracking-widest uppercase">
                LICENSE CLOUD
              </p>
            </div>
          </div>

          {/* Navigation Items */}
          <nav className="space-y-1.5">
            <Link
              href="/"
              className={`flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide transition-all ${
                location === "/"
                  ? "bg-gradient-to-r from-emerald-500 to-cyan-600 text-white shadow-[0_4px_20px_rgba(16,185,129,0.35)]"
                  : "text-slate-400 hover:text-white hover:bg-white/[0.05]"
              }`}
            >
              <LayoutDashboard className="h-4 w-4" /> Dashboard
            </Link>

            <Link
              href="/#provision-access"
              className="flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide text-slate-400 hover:text-white hover:bg-white/[0.05] transition-all"
            >
              <KeyRound className="h-4 w-4" /> Key Generator
            </Link>

            <Link
              href="/#key-registry"
              className="flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide text-slate-400 hover:text-white hover:bg-white/[0.05] transition-all"
            >
              <Database className="h-4 w-4" /> License Registry
            </Link>

            <Link
              href="/#key-registry"
              className="flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide text-slate-400 hover:text-white hover:bg-white/[0.05] transition-all"
            >
              <Cable className="h-4 w-4" /> Device Binding
            </Link>

            {isOwner && (
              <Link
                href="/#identity-control"
                className="flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide text-slate-400 hover:text-white hover:bg-white/[0.05] transition-all"
              >
                <Users className="h-4 w-4" /> Users & Team
              </Link>
            )}
          </nav>
        </div>

        {/* Bottom Section: Profile Card */}
        <div className="space-y-3 pt-4 border-t border-white/[0.07]">
          <div className="p-3 rounded-2xl bg-white/[0.02] border border-white/[0.06] flex items-center gap-3">
            <Avatar className="h-9 w-9 rounded-xl border border-emerald-500/30">
              <AvatarFallback className="bg-gradient-to-tr from-emerald-600 to-cyan-600 text-white text-xs font-bold rounded-xl">
                {displayName?.[0]?.toUpperCase() ?? "A"}
              </AvatarFallback>
            </Avatar>
            <div className="min-w-0 flex-1">
              <p className="truncate text-xs font-bold text-white">{displayName}</p>
              <span className="inline-block px-1.5 py-0.5 mt-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/25 text-[9px] uppercase tracking-wider text-emerald-400 font-semibold">
                {roleLabel}
              </span>
            </div>
            <button
              onClick={logout}
              className="text-slate-500 hover:text-rose-400 transition-colors p-1"
              title="Sign Out"
            >
              <LogOut className="h-4 w-4" />
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="min-h-screen lg:pl-72 p-4 sm:p-7 relative z-10">
        {/* Header Bar */}
        <header className="cosmic-card mb-6 px-6 py-4 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div>
              <p className="text-xs text-slate-400 font-medium">Operator Session</p>
              <h1 className="text-xl sm:text-2xl font-bold font-outfit text-white tracking-wide">
                {displayName}
              </h1>
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="px-3.5 py-1.5 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-medium text-slate-300">
              {timeStr || "10:00 PM"}
            </div>

            <div className="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/25 text-emerald-300 text-xs font-semibold">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span>24/7 ONLINE</span>
            </div>

            <button
              onClick={logout}
              className="lg:hidden p-2 rounded-xl bg-white/[0.05] border border-white/[0.1] text-slate-300 hover:text-rose-400"
              title="Sign Out"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </header>

        {/* Main Content */}
        <div className="space-y-6">{children}</div>
      </main>
    </div>
  );
}
