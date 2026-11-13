import { CosmicSystemOverview } from "@/components/CosmicSystemOverview";

type SystemStats = {
  totalKeys?: number;
  activeKeys?: number;
  totalDeviceBindings?: number;
  revokedKeys?: number;
} | undefined;

export function PremiumSystemOverview({ stats, isOwner }: { stats: SystemStats; isOwner: boolean }) {
  return <CosmicSystemOverview stats={stats} isOwner={isOwner} />;
}
