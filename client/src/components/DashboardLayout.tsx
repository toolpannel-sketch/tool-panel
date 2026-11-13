import { useEffect, useState } from "react";
import { useAuth } from "@/_core/hooks/useAuth";
import { COOKIE_NAME } from "@shared/const";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { trpc } from "@/lib/trpc";
import { Link, useLocation } from "wouter";
import {
  Cable,
  Database,
  KeyRound,
  LayoutDashboard,
  LogOut,
  RadioTower,
  ShieldCheck,
  Sparkles,
  Users,
} from "lucide-react";

function AuthGate() {
  const [tab, setTab] = useState<"login" | "register">("login");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [referralCode, setReferralCode] = useState("");
  const [error, setError] = useState("");
  const utils = trpc.useUtils();

  const loginMutation = trpc.auth.login.useMutation({
    onSuccess: async (data) => {
      if (data?.token) {
        try {
          sessionStorage.setItem("manus-cookie", `${COOKIE_NAME}=${data.token}`);
        } catch {}
      }
      await utils.auth.me.invalidate();
      await utils.dashboard.identity.invalidate();
      window.location.reload();
    },
    onError: (err) => {
      setError(err.message || "Invalid credentials");
    },
  });

  const registerMutation = trpc.auth.register.useMutation({
    onSuccess: async (data) => {
      if (data?.token) {
        try {
          sessionStorage.setItem("manus-cookie", `${COOKIE_NAME}=${data.token}`);
        } catch {}
      }
      await utils.auth.me.invalidate();
      await utils.dashboard.identity.invalidate();
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
    <div className="min-h-screen bg-[#070913] relative flex items-center justify-center p-4 overflow-hidden font-sans-modern">
      {/* Background radial ambient lights */}
      <div className="absolute top-1/4 -left-20 w-96 h-96 bg-blue-500/10 rounded-full blur-[100px] pointer-events-none" />
      <div className="absolute bottom-1/4 -right-20 w-96 h-96 bg-purple-600/15 rounded-full blur-[100px] pointer-events-none" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-32 bg-purple-600/10 rounded-full blur-[90px] pointer-events-none" />

      {/* Horizontal Neon Beam Flare (Exact reference match to Image 2) */}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none overflow-hidden">
        <div className="w-[850px] max-w-full h-[3px] bg-gradient-to-r from-transparent via-purple-500 to-transparent shadow-[0_0_50px_12px_rgba(168,85,247,0.75)] animate-cosmic-beam" />
      </div>

      {/* Frosted Glass Login / Register Card */}
      <div className="relative z-10 max-w-md w-full p-8 sm:p-10 rounded-[32px] bg-[#0b0e22]/85 backdrop-blur-3xl border border-purple-500/30 shadow-[0_25px_80px_rgba(0,0,0,0.7),0_0_60px_rgba(147,51,234,0.18)]">
        {/* Brand / Logo */}
        <div className="text-center mb-6">
          <div className="inline-flex items-center justify-center gap-2 mb-2">
            <span className="font-outfit text-3xl font-extrabold tracking-[0.25em] bg-gradient-to-r from-white via-purple-100 to-violet-300 bg-clip-text text-transparent">
              TOOL PANEL
            </span>
          </div>
          <p className="text-slate-300 text-base font-medium">
            {tab === "login" ? "Welcome Back" : "Create New Account"}
          </p>
          <p className="text-slate-500 text-xs mt-1">
            {tab === "login"
              ? "Sign in to access your license management engine"
              : "Enter your invite referral code to join the system"}
          </p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-950/60 border border-red-500/40 text-red-200 text-xs rounded-xl backdrop-blur-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1.5">
              Username
            </label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="cosmic-input w-full px-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none"
              placeholder="Enter username"
              required
            />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-300 mb-1.5">
              Password
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="cosmic-input w-full px-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none"
              placeholder="••••••••••••"
              required
            />
          </div>

          {tab === "register" && (
            <div>
              <label className="block text-xs font-medium text-purple-300 mb-1.5">
                Invite / Referral Code
              </label>
              <input
                type="text"
                value={referralCode}
                onChange={(e) => setReferralCode(e.target.value)}
                className="cosmic-input w-full px-4 py-3 text-sm text-white placeholder-slate-500 uppercase tracking-widest focus:outline-none border-purple-500/40"
                placeholder="ENTER REFERRAL CODE"
                required
              />
              <p className="text-[11px] text-slate-400 mt-1.5">
                Your permissions (Admin / Owner) will be assigned automatically.
              </p>
            </div>
          )}

          <button
            type="submit"
            disabled={isPending}
            className="cosmic-btn-primary w-full py-3.5 mt-2 rounded-xl text-white font-semibold text-sm shadow-[0_0_25px_rgba(139,92,246,0.5)] flex items-center justify-center gap-2"
          >
            {isPending ? (
              <span>Authenticating...</span>
            ) : tab === "login" ? (
              <span>Login</span>
            ) : (
              <span>Create Account</span>
            )}
          </button>
        </form>

        {/* Footer Toggle (Sign Up / Sign In switch) */}
        <div className="mt-8 text-center pt-5 border-t border-white/[0.08]">
          {tab === "login" ? (
            <p className="text-slate-400 text-xs">
              Are You New Member ?{" "}
              <button
                type="button"
                onClick={() => {
                  setTab("register");
                  setError("");
                }}
                className="text-purple-400 font-semibold hover:text-purple-300 transition-colors ml-1 underline decoration-purple-400/40 underline-offset-4"
              >
                Sign UP
              </button>
            </p>
          ) : (
            <p className="text-slate-400 text-xs">
              Already have an account ?{" "}
              <button
                type="button"
                onClick={() => {
                  setTab("login");
                  setError("");
                }}
                className="text-purple-400 font-semibold hover:text-purple-300 transition-colors ml-1 underline decoration-purple-400/40 underline-offset-4"
              >
                Sign IN
              </button>
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, loading, logout } = useAuth();
  const identity = trpc.dashboard.identity.useQuery(undefined, { enabled: Boolean(user) });
  const [location] = useLocation();
  const [timeStr, setTimeStr] = useState("");

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTimeStr(
        now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: true })
      );
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#070913] flex items-center justify-center text-cyan-400 font-sans-modern">
        <div className="flex flex-col items-center gap-3">
          <div className="w-10 h-10 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
          <p className="text-xs uppercase tracking-widest text-slate-400">Loading System...</p>
        </div>
      </div>
    );
  }

  if (!user) return <AuthGate />;

  const isOwner =
    identity.data?.role === "super_owner" ||
    identity.data?.role === "owner" ||
    user.role === "owner" ||
    user.openId === import.meta.env.VITE_OWNER_OPEN_ID;
  const isSuperOwner = identity.data?.role === "super_owner";
  const roleLabel =
    identity.data?.role === "super_owner"
      ? "super owner"
      : isOwner
      ? "owner"
      : identity.data?.role ?? user.role;
  const displayName = identity.data?.username || user.name || user.email;

  const switchAccount = async () => {
    await logout();
    window.location.href = "/";
  };

  return (
    <div className="min-h-screen cosmic-backdrop text-slate-100 font-sans-modern relative overflow-x-hidden">
      {/* Ambient background blur circles */}
      <div className="fixed top-0 left-1/4 w-[500px] h-[500px] bg-sky-500/[0.07] rounded-full blur-[120px] pointer-events-none" />
      <div className="fixed bottom-0 right-10 w-[600px] h-[600px] bg-orange-500/[0.05] rounded-full blur-[140px] pointer-events-none" />
      <div className="fixed top-1/3 right-1/4 w-[450px] h-[450px] bg-purple-600/[0.06] rounded-full blur-[120px] pointer-events-none" />

      {/* Floating Slim Dock / Sidebar (Inspired by Image 1) */}
      <aside className="fixed left-5 top-5 bottom-5 w-64 cosmic-dock hidden lg:flex flex-col justify-between p-5 z-40">
        <div>
          {/* Top Brand Logo */}
          <div className="flex items-center gap-3 pb-5 mb-5 border-b border-white/[0.08]">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-blue-600 to-indigo-600 flex items-center justify-center text-white shadow-[0_0_20px_rgba(59,130,246,0.5)]">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
            <div className="min-w-0">
              <h2 className="font-outfit font-bold tracking-wider text-base text-white truncate">
                TOOL PANEL
              </h2>
              <p className="text-[10px] text-slate-400 tracking-widest uppercase">
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
                  ? "bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-[0_4px_20px_rgba(59,130,246,0.45)]"
                  : "text-slate-400 hover:text-white hover:bg-white/[0.05]"
              }`}
            >
              <LayoutDashboard className="h-4 w-4" /> Dashboard
            </Link>

            <Link
              href="/#key-registry"
              className="flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide text-slate-400 hover:text-white hover:bg-white/[0.05] transition-all"
            >
              <KeyRound className="h-4 w-4" /> Licenses
            </Link>

            <Link
              href="/#provision-access"
              className="flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide text-slate-400 hover:text-white hover:bg-white/[0.05] transition-all"
            >
              <Database className="h-4 w-4" /> Key Generator
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

            {isSuperOwner && (
              <Link
                href="/super-owner"
                className={`flex items-center gap-3 px-3.5 py-3 rounded-2xl text-xs font-semibold tracking-wide transition-all ${
                  location === "/super-owner"
                    ? "bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-[0_4px_20px_rgba(59,130,246,0.45)]"
                    : "text-slate-400 hover:text-white hover:bg-white/[0.05]"
                }`}
              >
                <ShieldCheck className="h-4 w-4" /> Admin Center
              </Link>
            )}
          </nav>
        </div>

        {/* Bottom Section: Profile Card */}
        <div className="space-y-3 pt-4 border-t border-white/[0.08]">
          <div className="p-3 rounded-2xl bg-white/[0.03] border border-white/[0.06] flex items-center gap-3">
            <Avatar className="h-9 w-9 rounded-xl border border-purple-500/30">
              <AvatarFallback className="bg-gradient-to-tr from-purple-600 to-indigo-600 text-white text-xs font-bold rounded-xl">
                {displayName?.[0]?.toUpperCase() ?? "A"}
              </AvatarFallback>
            </Avatar>
            <div className="min-w-0 flex-1">
              <p className="truncate text-xs font-bold text-white">{displayName}</p>
              <span className="inline-block px-1.5 py-0.5 mt-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/25 text-[9px] uppercase tracking-wider text-emerald-300 font-semibold">
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

      {/* Main Content View */}
      <main className="min-h-screen lg:pl-72 p-4 sm:p-7 relative z-10">
        {/* Top Header Bar */}
        <header className="cosmic-card mb-6 px-6 py-4 flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div>
              <p className="text-xs text-slate-400">Welcome Back,</p>
              <h1 className="text-xl sm:text-2xl font-bold font-outfit text-white tracking-wide">
                {displayName}
              </h1>
            </div>
          </div>

          <div className="flex items-center gap-4">
            {/* Live Time Badge */}
            <div className="px-3.5 py-1.5 rounded-full bg-white/[0.05] border border-white/[0.1] text-xs font-medium text-slate-300">
              {timeStr || "07:45 PM"}
            </div>

            {/* Server Status Indicator */}
            <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-medium">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span>24/7 ONLINE</span>
            </div>

            {/* Mobile Sign Out */}
            <button
              onClick={logout}
              className="lg:hidden p-2 rounded-xl bg-white/[0.05] border border-white/[0.1] text-slate-300 hover:text-rose-400"
              title="Sign Out"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </header>

        {/* Child Pages Content */}
        <div className="space-y-6">{children}</div>
      </main>
    </div>
  );
}
