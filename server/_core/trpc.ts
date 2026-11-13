import { initTRPC, TRPCError } from "@trpc/server";
import superjson from "superjson";
import type { TrpcContext } from "./context";
import { ENV } from "./env";

const t = initTRPC.context<TrpcContext>().create({ transformer: superjson });
export const router = t.router;
export const publicProcedure = t.procedure;

export function hasActiveAccess(user: NonNullable<TrpcContext["user"]>, now = new Date()) {
  return user.accessStatus === "active" && (!user.accessExpiresAt || user.accessExpiresAt.getTime() > now.getTime());
}

const requireUser = t.middleware(async opts => {
  if (!opts.ctx.user) throw new TRPCError({ code: "UNAUTHORIZED", message: "Authentication required" });
  if (!hasActiveAccess(opts.ctx.user)) throw new TRPCError({ code: "FORBIDDEN", message: "Account access has expired or been revoked" });
  return opts.next({ ctx: { ...opts.ctx, user: opts.ctx.user } });
});

export const protectedProcedure = t.procedure.use(requireUser);

export const adminProcedure = t.procedure.use(t.middleware(async opts => {
  const user = opts.ctx.user;
  const isOwner = Boolean(user && hasActiveAccess(user) && (user.role === "super_owner" || user.role === "owner" || user.openId === ENV.ownerOpenId));
  if (!user || !hasActiveAccess(user) || (!isOwner && user.role !== "admin")) {
    throw new TRPCError({ code: "FORBIDDEN", message: "Owner or admin access required" });
  }
  return opts.next({ ctx: { ...opts.ctx, user, isOwner } });
}));

export const ownerProcedure = t.procedure.use(t.middleware(async opts => {
  const user = opts.ctx.user;
  if (!user || !hasActiveAccess(user) || (user.role !== "super_owner" && user.role !== "owner" && user.openId !== ENV.ownerOpenId)) {
    throw new TRPCError({ code: "FORBIDDEN", message: "Owner access required" });
  }
  return opts.next({ ctx: { ...opts.ctx, user, isOwner: true } });
}));

export const superOwnerProcedure = t.procedure.use(t.middleware(async opts => {
  const user = opts.ctx.user;
  if (!user || !hasActiveAccess(user) || user.role !== "super_owner" || user.openId !== ENV.ownerOpenId) {
    throw new TRPCError({ code: "FORBIDDEN", message: "Super Owner access required" });
  }
  return opts.next({ ctx: { ...opts.ctx, user, isOwner: true, isSuperOwner: true } });
}));
