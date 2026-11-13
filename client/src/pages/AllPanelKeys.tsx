import { useState } from "react";
import { Link } from "wouter";
import { ArrowLeft, KeyRound, RefreshCw, ShieldAlert, Trash2 } from "lucide-react";
import { trpc } from "@/lib/trpc";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

const fmt = (value: Date | string | null | undefined) => value ? new Date(value).toLocaleString([], { dateStyle: "medium", timeStyle: "short" }) : "—";
const statusClass = (status: "active" | "expired" | "revoked" | "unused") => ({ active: "status-active", expired: "status-expired", revoked: "status-revoked", unused: "status-muted" })[status];

export default function AllPanelKeys() {
  const identity = trpc.dashboard.identity.useQuery();
  const isSuperOwner = identity.data?.role === "super_owner" && identity.data.accessStatus === "active";
  const utils = trpc.useUtils();
  const keys = trpc.superOwner.allKeysOverview.useQuery(undefined, { enabled: isSuperOwner });
  const counts = trpc.superOwner.seasonCounts.useQuery(undefined, { enabled: isSuperOwner });
  const [confirmOpen, setConfirmOpen] = useState(false);
  const deleteKeys = trpc.superOwner.deleteAllKeys.useMutation({
    onSuccess: () => {
      setConfirmOpen(false);
      void utils.superOwner.allKeysOverview.invalidate();
      void utils.superOwner.seasonCounts.invalidate();
      void utils.dashboard.homeKeys.invalidate();
      void utils.dashboard.overview.invalidate();
      void utils.dashboard.audit.invalidate();
    },
  });

  if (!isSuperOwner) return <Card className="hud-panel mx-auto mt-10 max-w-xl"><CardContent className="p-8 text-center"><ShieldAlert className="mx-auto h-8 w-8 text-pink-300" /><p className="eyebrow mt-4">RESTRICTED NODE</p><h1 className="neon-heading mt-2 text-3xl">SUPER OWNER ONLY</h1><p className="mt-4 text-sm text-slate-400">This review is available only to the active configured Super Owner account.</p><Link href="/" className="cyber-outline mt-6 inline-flex h-10 items-center px-4 text-sm">RETURN TO DASHBOARD</Link></CardContent></Card>;

  const keyCount = counts.data?.keys ?? keys.data?.length ?? 0;
  const isDeleting = deleteKeys.isPending;
  return <>
    <header className="flex flex-col gap-5 border-b border-cyan-300/15 pb-7 sm:flex-row sm:items-end sm:justify-between"><div><p className="eyebrow">SUPER OWNER // COMPLETE REGISTRY</p><h1 className="neon-heading mt-2 text-4xl sm:text-5xl">ALL PANEL KEYS</h1><p className="mt-3 max-w-2xl text-sm text-slate-400">Every license key created across the panel, including Owner and Admin records. This view is read-only except for the confirmation-protected global delete.</p></div><Link href="/super-owner" className="cyber-outline inline-flex h-10 items-center justify-center px-4 text-sm"><ArrowLeft className="mr-2 h-4 w-4" />BACK TO GLOBAL REVIEW</Link></header>
    <section className="mt-7"><Card className="hud-panel overflow-hidden"><CardContent className="p-0"><div className="flex flex-wrap items-center justify-between gap-4 border-b border-cyan-300/15 p-6"><div className="flex items-center gap-4"><KeyRound className="h-8 w-8 text-cyan-300" /><div><p className="stat-label">complete panel registry</p><p className="mt-2 font-display text-4xl text-cyan-100">{String(keyCount).padStart(2, "0")}</p></div></div><div className="flex flex-wrap gap-2"><Button variant="ghost" className="text-cyan-200 hover:bg-cyan-300/10" onClick={() => { void keys.refetch(); void counts.refetch(); }}><RefreshCw className="mr-2 h-4 w-4" />REFRESH</Button><Button className="cyber-danger" disabled={!keyCount || isDeleting} onClick={() => setConfirmOpen(true)}><Trash2 className="mr-2 h-4 w-4" />DELETE ALL KEYS</Button></div></div><div className="overflow-x-auto"><table className="w-full text-left text-sm"><thead><tr className="table-head"><th>creator</th><th>role</th><th>key</th><th>status</th><th>devices</th><th>activation / expiry</th></tr></thead><tbody>{keys.data?.map(item => { const shownDevices = Math.max(item.usedDevices, item.boundDeviceId ? 1 : 0); return <tr className="table-row" key={item.id}><td className="min-w-[170px] text-cyan-100">{item.creatorDisplayName}</td><td><Badge className={item.creatorRole === "super_owner" ? "status-active" : "status-muted"}>{item.creatorRole?.replaceAll("_", " ") ?? "legacy"}</Badge></td><td><code className="key-chip">{item.keyValue}</code></td><td><Badge className={statusClass(item.status)}>{item.status}</Badge></td><td>{shownDevices} / {item.maxDevices}</td><td className="min-w-[210px] text-xs text-slate-400">{item.activatedAt ? <><p className="text-cyan-100">activated {fmt(item.activatedAt)}</p><p className="mt-1">expires {fmt(item.expiresAt)}</p></> : <p className="text-amber-200">pending activation</p>}</td></tr>; })}{!keys.data?.length && <tr><td colSpan={6} className="p-12 text-center text-slate-500">No panel keys are available.</td></tr>}</tbody></table></div></CardContent></Card></section>
    <Dialog open={confirmOpen} onOpenChange={setConfirmOpen}><DialogContent className="cyber-dialog"><DialogHeader><DialogTitle className="neon-heading text-xl">DELETE ALL PANEL KEYS?</DialogTitle></DialogHeader><p className="text-slate-300">This will permanently delete all <span className="text-pink-200">{keyCount}</span> keys from Owners, Admins, and the Super Owner.</p><p className="text-sm leading-6 text-slate-500">All associated device bindings will also be removed. Users, referrals, audit history, Lua artifacts, validation, and transport remain unchanged.</p><div className="flex justify-end gap-3"><Button variant="ghost" onClick={() => setConfirmOpen(false)}>NO, CANCEL</Button><Button className="cyber-danger" disabled={isDeleting} onClick={() => deleteKeys.mutate()}>{isDeleting ? "DELETING…" : "YES, DELETE ALL KEYS"}</Button></div></DialogContent></Dialog>
  </>;
}
