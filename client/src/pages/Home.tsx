import { useEffect, useState } from "react";
import { trpc } from "@/lib/trpc";
import { useAuth } from "@/_core/hooks/useAuth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import {
  Copy,
  Check,
  KeyRound,
  Link2Off,
  LockKeyhole,
  Plus,
  RefreshCw,
  Search,
  ShieldAlert,
  ShieldCheck,
  Trash2,
  UserCog,
  Users,
  Smartphone,
  Calendar,
  Layers,
  ArrowRight,
} from "lucide-react";
import { toast } from "sonner";
import { motion } from "framer-motion";
import { PremiumSystemOverview } from "@/components/PremiumSystemOverview";
import { PremiumSectionAnchors } from "@/components/PremiumSectionAnchors";

const fmt = (value: Date | string | null | undefined) =>
  value ? new Date(value).toLocaleString([], { dateStyle: "medium", timeStyle: "short" }) : "—";

const formatDuration = (minutes: number | null | undefined) => {
  if (minutes == null) return "Legacy fixed expiry";
  if (minutes % 43200 === 0) {
    const amount = minutes / 43200;
    return `${amount} ${amount === 1 ? "month" : "months"} (30 days/mo)`;
  }
  if (minutes % 10080 === 0) {
    const amount = minutes / 10080;
    return `${amount} ${amount === 1 ? "week" : "weeks"}`;
  }
  if (minutes % 1440 === 0) {
    const amount = minutes / 1440;
    return `${amount} ${amount === 1 ? "day" : "days"}`;
  }
  if (minutes % 60 === 0) {
    const amount = minutes / 60;
    return `${amount} ${amount === 1 ? "hour" : "hours"}`;
  }
  return `${minutes} ${minutes === 1 ? "minute" : "minutes"}`;
};

const toDateTimeLocal = (value: Date | string) => {
  const date = new Date(value);
  const pad = (unit: number) => String(unit).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
};

const licenseStatusClass = (status: "active" | "expired" | "revoked" | "unused" | string) =>
  ({
    active: "status-active",
    expired: "status-expired",
    revoked: "status-revoked",
    unused: "status-muted",
  })[status] || "status-muted";

const MAX_LICENSE_DEVICES = 10_000;

export default function Home() {
  const { user, logout } = useAuth();
  const identity = trpc.dashboard.identity.useQuery();
  const isSuperOwner = identity.data?.role === "super_owner";
  const isOwner = isSuperOwner || identity.data?.role === "owner";
  const isActive = identity.data?.accessStatus === "active";

  const stats = trpc.dashboard.overview.useQuery(undefined, { enabled: isOwner && isActive });
  const keys = trpc.dashboard.homeKeys.useQuery(undefined, { enabled: isActive, refetchInterval: 15000 });
  const users = trpc.dashboard.users.useQuery(undefined, { enabled: isOwner && isActive });
  const referrals = trpc.referrals.list.useQuery(undefined, { enabled: Boolean(isOwner && isActive) });
  const audit = trpc.dashboard.audit.useQuery(undefined, { enabled: isOwner && isActive });
  const utils = trpc.useUtils();

  const [copiedKeyId, setCopiedKeyId] = useState<string | null>(null);

  const create = trpc.license.create.useMutation({
    onSuccess: async data => {
      try {
        if (!navigator.clipboard?.writeText) throw new Error("Clipboard unavailable");
        await navigator.clipboard.writeText(data.keyValue);
        toast.success("License Key Generated & Copied!", { description: data.keyValue });
      } catch {
        window.prompt("Copy your generated key:", data.keyValue);
        toast.info("Key generated", { description: data.keyValue });
      }
      utils.dashboard.homeKeys.invalidate();
      utils.dashboard.overview.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const status = trpc.license.setStatus.useMutation({
    onSuccess: () => {
      toast.success("Key status updated");
      utils.dashboard.homeKeys.invalidate();
      utils.dashboard.overview.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const updateLicense = trpc.license.update.useMutation({
    onSuccess: () => {
      toast.success("License settings saved");
      setManagingKey(null);
      utils.dashboard.homeKeys.invalidate();
      utils.dashboard.overview.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const remove = trpc.license.delete.useMutation({
    onSuccess: () => {
      toast.success("Key deleted");
      utils.dashboard.homeKeys.invalidate();
      utils.dashboard.overview.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const unbind = trpc.license.unbind.useMutation({
    onSuccess: () => {
      toast.success("Device unbound");
      utils.dashboard.bindings.invalidate();
      utils.dashboard.homeKeys.invalidate();
      utils.dashboard.overview.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const role = trpc.users.setRole.useMutation({
    onSuccess: () => {
      toast.success("Role updated");
      utils.dashboard.users.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const deleteUser = trpc.users.delete.useMutation({
    onSuccess: () => {
      toast.success("Account cleared");
      utils.dashboard.users.invalidate();
      utils.dashboard.audit.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const removeOwner = trpc.users.removeOwner.useMutation({
    onSuccess: () => {
      toast.success("Owner access removed");
      setConfirmOwnerRemoval(null);
      utils.dashboard.users.invalidate();
      utils.dashboard.audit.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const referral = trpc.referrals.create.useMutation({
    onSuccess: data => {
      toast.success(`${data.role} referral created`, { description: `${data.code} · expires ${fmt(data.expiresAt)}` });
      utils.referrals.list.invalidate();
      utils.dashboard.audit.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const revokeReferral = trpc.referrals.revoke.useMutation({
    onSuccess: () => {
      toast.success("Referral revoked");
      utils.referrals.list.invalidate();
      utils.dashboard.audit.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const deleteReferral = trpc.referrals.delete.useMutation({
    onSuccess: () => {
      toast.success("Referral cleared");
      utils.referrals.list.invalidate();
      utils.dashboard.audit.invalidate();
    },
    onError: e => toast.error(e.message),
  });

  const [usernameDialogOpen, setUsernameDialogOpen] = useState(false);
  const [usernameEditOpen, setUsernameEditOpen] = useState(false);
  const [usernameInput, setUsernameInput] = useState("");
  const saveUsername = trpc.users.changeUsername.useMutation({
    onSuccess: data => {
      toast.success("Username saved", { description: `Welcome, ${data.username}` });
      setUsernameDialogOpen(false);
      setUsernameEditOpen(false);
      utils.dashboard.identity.invalidate();
      utils.dashboard.users.invalidate();
      utils.dashboard.audit.invalidate();
    },
    onError: error => toast.error(error.message),
  });

  const redeem = trpc.referrals.redeem.useMutation({
    onSuccess: data => {
      toast.success(`Referral accepted: ${data.role}`);
      void utils.dashboard.identity.invalidate();
      if (data.needsUsername) {
        setUsernameInput("");
        setUsernameDialogOpen(true);
      }
    },
    onError: e => toast.error(e.message),
  });

  const [durationAmount, setDurationAmount] = useState("30");
  const [durationUnit, setDurationUnit] = useState<"minutes" | "hours" | "days" | "weeks" | "months">("days");
  const [maxDevices, setMaxDevices] = useState("1");
  const [customEnabled, setCustomEnabled] = useState(false);
  const [customPrefix, setCustomPrefix] = useState("");
  const [useExactCustomKey, setUseExactCustomKey] = useState(false);
  const [selectedKey, setSelectedKey] = useState<number | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<number | null>(null);
  const [confirmOwnerRemoval, setConfirmOwnerRemoval] = useState<number | null>(null);
  const [search, setSearch] = useState("");
  const [referralRole, setReferralRole] = useState<"admin" | "owner">("admin");
  const [referralDuration, setReferralDuration] = useState("30");
  const [referralCode, setReferralCode] = useState("");
  const [managingKey, setManagingKey] = useState<number | null>(null);
  const [manageStatus, setManageStatus] = useState<"active" | "expired" | "revoked" | "unused">("active");
  const [manageExpiry, setManageExpiry] = useState("");
  const [manageMaxDevices, setManageMaxDevices] = useState("1");

  const bindings = trpc.dashboard.bindings.useQuery(
    { keyId: selectedKey ?? 0 },
    { enabled: Boolean(selectedKey && isActive) }
  );

  const visibleKeys = keys.data?.filter(key => key.keyValue.toLowerCase().includes(search.trim().toLowerCase())) ?? [];
  const managedLicense = keys.data?.find(key => key.id === managingKey) ?? null;

  useEffect(() => {
    if (isActive && identity.data && !identity.data.username) setUsernameDialogOpen(true);
  }, [identity.data, isActive]);

  const makeKey = () =>
    create.mutate({
      durationAmount: Number(durationAmount),
      durationUnit,
      maxDevices: Number(maxDevices),
      customPrefix: customEnabled ? customPrefix : undefined,
      useExactCustomKey: customEnabled && useExactCustomKey,
    });

  const openManage = (key: {
    id: number;
    status: "active" | "expired" | "revoked" | "unused";
    expiresAt: Date | string | null;
    maxDevices: number;
  }) => {
    setManagingKey(key.id);
    setManageStatus(key.status);
    setManageExpiry(key.expiresAt ? toDateTimeLocal(key.expiresAt) : "");
    setManageMaxDevices(String(key.maxDevices));
  };

  const saveLicense = () => {
    if (!managingKey) return;
    if (managedLicense?.durationMinutes == null) {
      const expiresAt = new Date(manageExpiry);
      if (Number.isNaN(expiresAt.getTime())) return toast.error("Enter a valid expiry date and time");
      updateLicense.mutate({
        id: managingKey,
        status: manageStatus,
        expiresAt,
        maxDevices: Number(manageMaxDevices),
      });
      return;
    }
    updateLicense.mutate({ id: managingKey, status: manageStatus, maxDevices: Number(manageMaxDevices) });
  };

  const copyKey = async (keyValue: string) => {
    try {
      if (!navigator.clipboard?.writeText) throw new Error("Clipboard unavailable");
      await navigator.clipboard.writeText(keyValue);
      setCopiedKeyId(keyValue);
      setTimeout(() => setCopiedKeyId(null), 2000);
      toast.success("License Key Copied!", { description: keyValue });
    } catch {
      window.prompt("Copy your key:", keyValue);
      toast.info("Key copied", { description: keyValue });
    }
  };

  const switchAccount = async () => {
    await logout();
    window.location.reload();
  };

  if (identity.data?.accessStatus === "pending")
    return (
      <div className="min-h-[70vh] grid place-items-center">
        <Card className="hud-panel max-w-lg w-full">
          <CardContent className="p-8">
            <span className="text-xs uppercase font-semibold tracking-wider text-amber-400">Referral Verification</span>
            <h1 className="font-outfit text-3xl font-bold text-white mt-2">Activate Access</h1>
            <p className="mt-4 text-slate-400 text-sm">
              You are signed in as <span className="text-cyan-300 font-semibold">{user?.email ?? "your account"}</span>. Enter a valid referral invite code to activate your account.
            </p>
            <div className="mt-6 flex gap-2">
              <Input
                value={referralCode}
                onChange={e => setReferralCode(e.target.value)}
                placeholder="Enter REF-..."
                className="cyber-input"
              />
              <Button
                className="cyber-button whitespace-nowrap"
                disabled={redeem.isPending || !referralCode.trim()}
                onClick={() => redeem.mutate({ code: referralCode.trim() })}
              >
                {redeem.isPending ? "Validating…" : "Activate"}
              </Button>
            </div>
            <button
              className="mt-6 text-xs uppercase tracking-wider text-slate-400 hover:text-white transition-colors"
              onClick={() => void switchAccount()}
            >
              Sign out and switch account
            </button>
          </CardContent>
        </Card>
      </div>
    );

  return (
    <div className="space-y-7">
      {/* Page Header */}
      <header className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-6 border-b border-white/[0.08]">
        <div>
          <h1 className="font-outfit text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
            License Management
          </h1>
          <p className="text-sm text-slate-400 mt-1">
            Generate, bind, and govern client license keys with real-time hardware protection.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-500/10 border border-emerald-500/25 text-emerald-400 text-xs font-semibold">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            <span>24/7 Engine Active</span>
          </div>
        </div>
      </header>

      {/* Modern Analytics & Interactive Chart (Zero circular gauges) */}
      <PremiumSystemOverview
        stats={isOwner ? stats.data : undefined}
        keys={keys.data ?? []}
        isOwner={isOwner}
      />
      <PremiumSectionAnchors />

      {/* Account Identity Card */}
      {isActive && identity.data?.username && (
        <section>
          <Card className="hud-panel">
            <CardContent className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="flex items-center gap-4">
                <div className="w-11 h-11 rounded-2xl bg-gradient-to-tr from-emerald-500/20 to-cyan-500/20 border border-emerald-500/30 flex items-center justify-center text-emerald-300 font-bold font-outfit text-lg">
                  {identity.data.username[0]?.toUpperCase() ?? "U"}
                </div>
                <div>
                  <span className="text-[11px] uppercase font-semibold tracking-wider text-slate-400">Account Identity</span>
                  <h2 className="text-xl font-bold font-outfit text-white">{identity.data.username}</h2>
                  <p className="text-xs text-slate-400 mt-0.5">
                    Keys use prefix <code className="text-emerald-400 font-mono font-medium">{identity.data.username.toUpperCase().replace(/\s+/g, "-").replace(/[^A-Z0-9-]/g, "")}-…</code>
                    {" · "}
                    {identity.data.usernameChangeAvailable
                      ? "Username change available anytime."
                      : `Cooldown active until ${fmt(identity.data.usernameChangeAvailableAt)}.`}
                  </p>
                </div>
              </div>
              <Button
                variant="outline"
                className="cyber-outline"
                disabled={!identity.data.usernameChangeAvailable}
                onClick={() => {
                  setUsernameInput(identity.data?.username ?? "");
                  setUsernameEditOpen(true);
                }}
              >
                Change Username
              </Button>
            </CardContent>
          </Card>
        </section>
      )}

      {/* Main Grid: Generate Key & Create Referral */}
      <section className="grid gap-6 xl:grid-cols-[380px_1fr]">
        {/* Card: Generate License Key */}
        <Card className="hud-panel">
          <CardContent className="p-6">
            <div className="flex items-center gap-3 pb-5 border-b border-white/[0.06]">
              <div className="w-9 h-9 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                <Plus className="h-5 w-5" />
              </div>
              <div>
                <span className="text-[11px] uppercase font-semibold tracking-wider text-emerald-400">Key Provisioning</span>
                <h2 className="text-lg font-bold font-outfit text-white">Generate License</h2>
              </div>
            </div>

            <div className="mt-5 space-y-4">
              <div>
                <label className="field-label block mb-1.5">Duration from first activation</label>
                <div className="grid grid-cols-[1fr_130px] gap-2">
                  <Input
                    type="number"
                    min="1"
                    max="5256000"
                    value={durationAmount}
                    onChange={e => setDurationAmount(e.target.value)}
                    className="cyber-input"
                    aria-label="License duration amount"
                  />
                  <select
                    value={durationUnit}
                    onChange={e => setDurationUnit(e.target.value as typeof durationUnit)}
                    className="cyber-input h-10 px-3 text-sm cursor-pointer"
                    aria-label="License duration unit"
                  >
                    <option value="minutes">minutes</option>
                    <option value="hours">hours</option>
                    <option value="days">days</option>
                    <option value="weeks">weeks</option>
                    <option value="months">months</option>
                  </select>
                </div>
                <p className="mt-1 text-[11px] text-slate-400">Timer starts when first device validates.</p>
              </div>

              <div>
                <label className="field-label block mb-1.5">Maximum Allowed Devices</label>
                <Input
                  type="number"
                  min="1"
                  max={MAX_LICENSE_DEVICES}
                  value={maxDevices}
                  onChange={e => setMaxDevices(e.target.value)}
                  className="cyber-input"
                />
              </div>

              {/* Custom key name toggle */}
              <div className="p-3.5 rounded-xl bg-white/[0.02] border border-white/[0.06] space-y-3">
                <div className="flex items-center justify-between">
                  <label htmlFor="custom-key-toggle" className="text-xs font-semibold text-slate-300 cursor-pointer">
                    Custom Key Prefix
                  </label>
                  <Switch id="custom-key-toggle" checked={customEnabled} onCheckedChange={setCustomEnabled} />
                </div>
                {customEnabled && (
                  <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: "auto" }}>
                    <Input
                      value={customPrefix}
                      onChange={e => setCustomPrefix(e.target.value)}
                      placeholder="e.g. VIP"
                      maxLength={24}
                      className="cyber-input"
                    />
                    <div className="mt-2.5 flex items-center justify-between text-xs text-slate-400">
                      <span>Use exact name without suffix</span>
                      <Switch checked={useExactCustomKey} onCheckedChange={setUseExactCustomKey} />
                    </div>
                  </motion.div>
                )}
              </div>

              <Button
                className="cyber-button w-full h-11"
                onClick={makeKey}
                disabled={create.isPending || !durationAmount || !maxDevices || (customEnabled && !customPrefix.trim())}
              >
                <Plus className="mr-2 h-4 w-4" />
                {create.isPending ? "Generating…" : "Generate License Key"}
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Card: Team & Referral Management (for Owner) */}
        {isOwner && (
          <Card className="hud-panel">
            <CardContent className="p-6">
              <div className="flex flex-wrap items-center justify-between gap-4 pb-5 border-b border-white/[0.06]">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-xl bg-cyan-500/10 border border-cyan-500/20 flex items-center justify-center text-cyan-400">
                    <Users className="h-5 w-5" />
                  </div>
                  <div>
                    <span className="text-[11px] uppercase font-semibold tracking-wider text-cyan-400">Team Invitations</span>
                    <h2 className="text-lg font-bold font-outfit text-white">Create Referral Code</h2>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-2">
                  <Input
                    type="number"
                    min="1"
                    max="3650"
                    value={referralDuration}
                    onChange={e => setReferralDuration(e.target.value)}
                    className="cyber-input h-9 w-20 text-xs"
                    aria-label="Referral duration in days"
                  />
                  <select
                    value={referralRole}
                    onChange={e => setReferralRole(e.target.value as "admin" | "owner")}
                    className="cyber-input h-9 px-2 text-xs"
                  >
                    <option value="admin">Admin Access</option>
                    {isSuperOwner && <option value="owner">Owner Access</option>}
                  </select>
                  <Button
                    size="sm"
                    className="cyber-button h-9 px-3 text-xs"
                    disabled={referral.isPending}
                    onClick={() => referral.mutate({ role: referralRole, durationDays: Number(referralDuration) })}
                  >
                    {referral.isPending ? "Creating…" : "Generate Invite"}
                  </Button>
                </div>
              </div>

              {/* Referral Codes List */}
              <div className="mt-4 space-y-2">
                {referrals.data?.slice(0, 6).map(item => {
                  const expired = new Date(item.expiresAt).getTime() <= Date.now();
                  const stale = item.status !== "active" || expired;
                  const displayStatus = expired && item.status === "active" ? "expired" : item.status;
                  return (
                    <div
                      className="flex flex-wrap items-center justify-between gap-3 p-3 rounded-xl bg-white/[0.02] border border-white/[0.05]"
                      key={item.id}
                    >
                      <div>
                        <code className="text-cyan-300 font-mono text-sm font-semibold">{item.code}</code>
                        <p className="text-[11px] text-slate-400">Expires {fmt(item.expiresAt)}</p>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-xs uppercase px-2 py-0.5 rounded-md bg-white/[0.05] text-slate-400">
                          {item.role} · {displayStatus}
                        </span>
                        {item.status === "active" && !expired && (
                          <Button
                            size="sm"
                            variant="ghost"
                            className="action-button danger text-xs h-8 px-2"
                            onClick={() => revokeReferral.mutate({ id: item.id })}
                          >
                            Revoke
                          </Button>
                        )}
                        {stale && (
                          <Button
                            size="sm"
                            variant="ghost"
                            className="action-button danger text-xs h-8 px-2"
                            disabled={deleteReferral.isPending}
                            onClick={() => deleteReferral.mutate({ id: item.id })}
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </Button>
                        )}
                      </div>
                    </div>
                  );
                })}
                {(!referrals.data || referrals.data.length === 0) && (
                  <p className="py-6 text-center text-xs text-slate-400">No active referral invites created yet.</p>
                )}
              </div>
            </CardContent>
          </Card>
        )}
      </section>

      {/* License Keys Registry Table */}
      <section>
        <Card className="hud-panel overflow-hidden">
          <CardContent className="p-0">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-white/[0.08] p-6">
              <div>
                <span className="text-[11px] uppercase font-semibold tracking-wider text-emerald-400">License Registry</span>
                <h2 className="text-xl font-bold font-outfit text-white">Generated Keys</h2>
              </div>
              <div className="flex items-center gap-2">
                <div className="relative">
                  <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                  <Input
                    value={search}
                    onChange={e => setSearch(e.target.value)}
                    placeholder="Search license key..."
                    className="cyber-input h-9 w-60 pl-9 text-xs"
                  />
                </div>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-9 px-3 text-xs text-slate-300 hover:text-white"
                  onClick={() => void utils.dashboard.homeKeys.invalidate()}
                >
                  <RefreshCw className="mr-1.5 h-3.5 w-3.5" /> Refresh
                </Button>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead>
                  <tr className="table-head">
                    <th>License Key</th>
                    <th>Status</th>
                    <th>Activation & Expiry</th>
                    <th>Hardware Bindings</th>
                    <th>Created</th>
                    <th className="text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {visibleKeys.map(key => {
                    const displayedDeviceCount = Math.max(Number(key.usedDevices ?? 0), key.boundDeviceId ? 1 : 0);
                    const isCopied = copiedKeyId === key.keyValue;
                    return (
                      <tr className="table-row" key={key.id}>
                        <td>
                          <button
                            className="key-chip group"
                            onClick={() => setSelectedKey(key.id)}
                            title="Click to view bound hardware devices"
                          >
                            <LockKeyhole className="mr-2 h-3.5 w-3.5 text-cyan-400" />
                            <span>{key.keyValue}</span>
                          </button>
                        </td>
                        <td>
                          <Badge className={licenseStatusClass(key.status)}>{key.status}</Badge>
                        </td>
                        <td className="min-w-[200px] text-slate-300">
                          {key.activatedAt ? (
                            <div>
                              <p className="whitespace-nowrap text-emerald-300 text-xs font-medium">
                                Active · {fmt(key.activatedAt)}
                              </p>
                              <p className="whitespace-nowrap text-[11px] text-slate-400 mt-0.5">
                                Expires {fmt(key.expiresAt)}
                              </p>
                            </div>
                          ) : (
                            <div>
                              <p className="text-amber-300 text-xs font-medium">Pending Activation</p>
                              <p className="text-[11px] text-slate-400 mt-0.5">
                                {formatDuration(key.durationMinutes)} from first device
                              </p>
                            </div>
                          )}
                        </td>
                        <td>
                          <button
                            className="device-count flex items-center gap-1.5"
                            onClick={() => setSelectedKey(key.id)}
                            title="Inspect hardware device bindings"
                          >
                            <Smartphone className="w-3.5 h-3.5 text-cyan-400" />
                            <span>
                              {displayedDeviceCount} / {key.maxDevices}
                            </span>
                          </button>
                        </td>
                        <td className="whitespace-nowrap text-xs text-slate-400">{fmt(key.createdAt)}</td>
                        <td>
                          <div className="flex justify-end items-center gap-1">
                            <Button
                              size="sm"
                              variant="ghost"
                              className="action-button h-8 w-8 p-0"
                              title="Copy raw license key"
                              onClick={() => void copyKey(key.keyValue)}
                            >
                              {isCopied ? (
                                <Check className="h-4 w-4 text-emerald-400" />
                              ) : (
                                <Copy className="h-4 w-4" />
                              )}
                            </Button>
                            <Button
                              size="sm"
                              variant="ghost"
                              className="action-button h-8 w-8 p-0"
                              title={key.status === "active" ? "Revoke key" : "Restore key"}
                              onClick={() =>
                                status.mutate({ id: key.id, status: key.status === "active" ? "revoked" : "active" })
                              }
                            >
                              {key.status === "active" ? (
                                <ShieldAlert className="h-4 w-4 text-rose-400" />
                              ) : (
                                <ShieldCheck className="h-4 w-4 text-emerald-400" />
                              )}
                            </Button>
                            <Button
                              size="sm"
                              variant="ghost"
                              className="action-button h-8 px-2 text-xs"
                              onClick={() => openManage(key)}
                            >
                              Manage
                            </Button>
                            {isOwner && (
                              <Button
                                size="sm"
                                variant="ghost"
                                className="action-button danger h-8 w-8 p-0"
                                title="Delete key"
                                onClick={() => setConfirmDelete(key.id)}
                              >
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                  {!visibleKeys.length && (
                    <tr>
                      <td colSpan={6} className="p-12 text-center text-slate-400">
                        No keys generated yet. Use the key generator above to create your first license.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      </section>

      {/* User Roles & Permissions Section */}
      {isOwner && (
        <section>
          <Card className="hud-panel overflow-hidden">
            <CardContent className="p-0">
              <div className="border-b border-white/[0.08] p-6">
                <span className="text-[11px] uppercase font-semibold tracking-wider text-indigo-400">Permissions</span>
                <h2 className="text-xl font-bold font-outfit text-white">Team & Role Access</h2>
                <p className="mt-1 text-xs text-slate-400">
                  Manage accounts authorized to generate keys and govern access.
                </p>
              </div>
              <div className="divide-y divide-white/[0.05]">
                {users.data?.map(account => {
                  const expired = Boolean(
                    account.accessExpiresAt && new Date(account.accessExpiresAt).getTime() <= Date.now()
                  );
                  const clearable = account.openId !== user?.openId && (account.accessStatus === "revoked" || expired);
                  const roleLabel = account.role === "super_owner" ? "Super Owner" : account.role;
                  const displayName = account.username || account.name || account.email || account.openId;
                  return (
                    <div className="flex flex-wrap items-center gap-4 p-5" key={account.id}>
                      <div className="w-9 h-9 rounded-xl bg-white/[0.05] border border-white/[0.08] flex items-center justify-center text-slate-300">
                        <Users className="h-4 w-4" />
                      </div>
                      <div className="min-w-[180px] flex-1">
                        <p className="text-sm font-semibold text-white">{displayName}</p>
                        <p className="text-xs text-slate-400">
                          Last seen {fmt(account.lastSignedIn)} · Access expires {fmt(account.accessExpiresAt)}
                        </p>
                      </div>
                      <Badge className={account.accessStatus === "active" && !expired ? "status-active" : "status-banned"}>
                        {roleLabel} · {expired && account.accessStatus === "active" ? "expired" : account.accessStatus}
                      </Badge>
                      {account.role === "admin" && account.openId !== user?.openId && (
                        <Button
                          size="sm"
                          variant="outline"
                          className="cyber-outline h-8 px-2.5 text-xs"
                          onClick={() =>
                            role.mutate({
                              id: account.id,
                              accessStatus: account.accessStatus === "active" ? "revoked" : "active",
                            })
                          }
                        >
                          <UserCog className="mr-1.5 h-3.5 w-3.5" />
                          {account.accessStatus === "active" && !expired ? "Revoke" : "Restore"}
                        </Button>
                      )}
                      {isSuperOwner && account.role === "owner" && account.openId !== user?.openId && (
                        <Button
                          size="sm"
                          variant="ghost"
                          className="action-button danger h-8 px-2.5 text-xs"
                          onClick={() => setConfirmOwnerRemoval(account.id)}
                        >
                          <ShieldAlert className="mr-1.5 h-3.5 w-3.5" /> Demote to Admin
                        </Button>
                      )}
                      {clearable && (
                        <Button
                          size="sm"
                          variant="ghost"
                          className="action-button danger h-8 w-8 p-0"
                          disabled={deleteUser.isPending}
                          onClick={() => deleteUser.mutate({ id: account.id })}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      )}
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        </section>
      )}

      {/* Security Audit Trail */}
      {isOwner && (
        <section>
          <Card className="hud-panel overflow-hidden">
            <CardContent className="p-0">
              <div className="border-b border-white/[0.08] p-6">
                <span className="text-[11px] uppercase font-semibold tracking-wider text-slate-400">Audit Trail</span>
                <h2 className="text-xl font-bold font-outfit text-white">Security Activity Log</h2>
                <p className="mt-1 text-xs text-slate-400">
                  Showing recent 15 validation and management events.
                </p>
              </div>
              <div className="divide-y divide-white/[0.05]">
                {audit.data?.map(item => (
                  <div className="flex flex-wrap items-center justify-between gap-3 p-4 text-xs" key={item.id}>
                    <div>
                      <p className="font-medium text-slate-200">
                        {item.action.replaceAll("_", " ")}
                        {item.keyPreview ? ` · ${item.keyPreview}` : ""}
                      </p>
                      <p className="text-[11px] text-slate-400 mt-0.5">
                        {item.actorName || "System"} · {fmt(item.createdAt)}
                      </p>
                    </div>
                    <code className="text-[11px] text-slate-400 bg-white/[0.04] px-2 py-0.5 rounded border border-white/[0.06]">
                      {item.details || item.entityType}
                    </code>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </section>
      )}

      {/* Footer Info */}
      <footer className="pt-4 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 text-xs text-slate-400 border-t border-white/[0.08]">
        <div>
          API Validation Endpoint: <code className="text-emerald-400 font-mono">POST /api/license/validate</code>
        </div>
        <div>
          Enforced: 1-Device-1-Key Hardware Lock · 24/7 Cloud Mesh
        </div>
      </footer>

      {/* Dialogs */}
      {/* 1. Bound Devices Dialog */}
      <Dialog open={Boolean(selectedKey)} onOpenChange={open => !open && setSelectedKey(null)}>
        <DialogContent className="cyber-dialog">
          <DialogHeader>
            <DialogTitle className="font-outfit text-xl text-white">Bound Hardware Devices</DialogTitle>
          </DialogHeader>
          <div className="space-y-3 mt-3">
            {bindings.data?.map((binding, index) => (
              <div className="binding-row" key={binding.id}>
                <div>
                  <p className="text-xs font-semibold text-slate-300">Device #{(index + 1).toString().padStart(2, "0")}</p>
                  <p className="font-mono text-xs text-slate-400 mt-0.5">{binding.deviceHash.slice(0, 24)}…</p>
                </div>
                <Button
                  size="sm"
                  variant="ghost"
                  className="action-button danger"
                  onClick={() => unbind.mutate({ bindingId: binding.id })}
                >
                  <Link2Off className="h-4 w-4 mr-1" /> Unbind
                </Button>
              </div>
            ))}
            {!bindings.data?.length && (
              <p className="py-8 text-center text-xs text-slate-400">No hardware devices bound to this license yet.</p>
            )}
          </div>
        </DialogContent>
      </Dialog>

      {/* 2. Manage License Dialog */}
      <Dialog open={managingKey !== null} onOpenChange={open => !open && setManagingKey(null)}>
        <DialogContent className="cyber-dialog">
          <DialogHeader>
            <DialogTitle className="font-outfit text-xl text-white">Manage License Configuration</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 mt-3">
            <div>
              <label className="field-label block mb-1">Status</label>
              <select
                value={manageStatus}
                onChange={e => setManageStatus(e.target.value as typeof manageStatus)}
                className="cyber-input w-full"
              >
                <option value="unused">unused</option>
                <option value="active">active</option>
                <option value="expired">expired</option>
                <option value="revoked">revoked</option>
              </select>
            </div>

            {managedLicense?.durationMinutes != null ? (
              <div className="p-3 rounded-xl bg-white/[0.03] border border-white/[0.08] text-xs">
                <span className="text-emerald-400 font-semibold block">Activation-based Duration</span>
                <p className="text-slate-300 mt-1">{formatDuration(managedLicense.durationMinutes)} from first activation</p>
                <p className="text-slate-400 text-[11px] mt-1">
                  {managedLicense.activatedAt
                    ? `Activated ${fmt(managedLicense.activatedAt)} · Expires ${fmt(managedLicense.expiresAt)}`
                    : "Pending first activation from device."}
                </p>
              </div>
            ) : (
              <div>
                <label className="field-label block mb-1">Expiry Date & Time</label>
                <Input
                  type="datetime-local"
                  value={manageExpiry}
                  onChange={e => setManageExpiry(e.target.value)}
                  className="cyber-input"
                />
              </div>
            )}

            <div>
              <label className="field-label block mb-1">Max Devices</label>
              <Input
                type="number"
                min="1"
                max={MAX_LICENSE_DEVICES}
                value={manageMaxDevices}
                onChange={e => setManageMaxDevices(e.target.value)}
                className="cyber-input"
              />
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <Button variant="ghost" onClick={() => setManagingKey(null)}>
                Cancel
              </Button>
              <Button
                className="cyber-button"
                disabled={updateLicense.isPending || !manageMaxDevices || (managedLicense?.durationMinutes == null && !manageExpiry)}
                onClick={saveLicense}
              >
                {updateLicense.isPending ? "Saving…" : "Save Changes"}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* 3. Delete Confirmation Dialog */}
      <Dialog open={confirmDelete !== null} onOpenChange={open => !open && setConfirmDelete(null)}>
        <DialogContent className="cyber-dialog">
          <DialogHeader>
            <DialogTitle className="font-outfit text-xl text-white">Delete License Key?</DialogTitle>
          </DialogHeader>
          <p className="text-slate-400 text-sm mt-2">
            This permanently deletes the license and severs all associated hardware device bindings.
          </p>
          <div className="flex justify-end gap-3 mt-4">
            <Button variant="ghost" onClick={() => setConfirmDelete(null)}>
              Cancel
            </Button>
            <Button
              className="cyber-danger"
              onClick={() => {
                if (confirmDelete) remove.mutate({ id: confirmDelete });
                setConfirmDelete(null);
              }}
            >
              Confirm Delete
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* 4. Remove Owner Confirmation Dialog */}
      <Dialog open={confirmOwnerRemoval !== null} onOpenChange={open => !open && setConfirmOwnerRemoval(null)}>
        <DialogContent className="cyber-dialog">
          <DialogHeader>
            <DialogTitle className="font-outfit text-xl text-white">Demote Owner Account?</DialogTitle>
          </DialogHeader>
          <p className="text-slate-400 text-sm mt-2">
            This revokes owner privileges and downgrades this user to Admin access.
          </p>
          <div className="flex justify-end gap-3 mt-4">
            <Button variant="ghost" onClick={() => setConfirmOwnerRemoval(null)}>
              Cancel
            </Button>
            <Button
              className="cyber-danger"
              disabled={removeOwner.isPending}
              onClick={() => {
                if (confirmOwnerRemoval) removeOwner.mutate({ id: confirmOwnerRemoval });
              }}
            >
              {removeOwner.isPending ? "Demoting…" : "Demote to Admin"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* 5. Set Username Initial Dialog */}
      <Dialog open={usernameDialogOpen} onOpenChange={open => { if (open) setUsernameDialogOpen(true); }}>
        <DialogContent className="cyber-dialog">
          <DialogHeader>
            <DialogTitle className="font-outfit text-xl text-white">Choose Your Username</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-slate-400 mt-2">
            This name will be displayed in the dashboard and used as the prefix for license keys you generate.
          </p>
          <div className="space-y-3 mt-4">
            <Input
              autoFocus
              value={usernameInput}
              onChange={e => setUsernameInput(e.target.value)}
              maxLength={32}
              placeholder="e.g. ALEXALORD"
              className="cyber-input"
            />
            <Button
              className="cyber-button w-full"
              disabled={saveUsername.isPending || usernameInput.trim().length < 3}
              onClick={() => saveUsername.mutate({ username: usernameInput })}
            >
              {saveUsername.isPending ? "Saving…" : "Save Username"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* 6. Edit Username Dialog */}
      <Dialog open={usernameEditOpen} onOpenChange={setUsernameEditOpen}>
        <DialogContent className="cyber-dialog">
          <DialogHeader>
            <DialogTitle className="font-outfit text-xl text-white">Edit Username</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-slate-400 mt-2">
            {isSuperOwner
              ? "As Super Owner, you can update your username anytime without cooldown."
              : "Standard users have a 72-hour cooldown after changing usernames."}
          </p>
          <div className="space-y-3 mt-4">
            <Input
              autoFocus
              value={usernameInput}
              onChange={e => setUsernameInput(e.target.value)}
              maxLength={32}
              className="cyber-input"
            />
            <div className="flex justify-end gap-2 pt-2">
              <Button variant="ghost" onClick={() => setUsernameEditOpen(false)}>
                Cancel
              </Button>
              <Button
                className="cyber-button"
                disabled={saveUsername.isPending || usernameInput.trim().length < 3}
                onClick={() => saveUsername.mutate({ username: usernameInput })}
              >
                {saveUsername.isPending ? "Saving…" : "Update Username"}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
