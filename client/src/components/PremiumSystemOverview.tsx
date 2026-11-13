import { ModernAnalyticsOverview } from "@/components/ModernAnalyticsOverview";

type SystemStats = {
  totalKeys?: number;
  activeKeys?: number;
  totalDeviceBindings?: number;
  revokedKeys?: number;
} | undefined;

export function PremiumSystemOverview({
  stats,
  keys = [],
  isOwner,
}: {
  stats: SystemStats;
  keys?: any[];
  isOwner: boolean;
}) {
  return <ModernAnalyticsOverview stats={stats} keys={keys} isOwner={isOwner} />;
}
