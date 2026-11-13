import { motion } from "framer-motion";
import { AnimatedCounter } from "@/components/AnimatedCounter";

interface CircularProgressGaugeProps {
  value: number; // 0 to 100
  size?: number;
  strokeWidth?: number;
  gradientId: string;
  startColor: string;
  endColor: string;
  glowColor?: string;
  centerLabel?: string;
  centerSublabel?: string;
  customCenter?: React.ReactNode;
}

export function CircularProgressGauge({
  value,
  size = 130,
  strokeWidth = 9,
  gradientId,
  startColor,
  endColor,
  glowColor,
  centerLabel,
  centerSublabel,
  customCenter,
}: CircularProgressGaugeProps) {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const normalizedValue = Math.min(Math.max(value, 0), 100);
  const strokeDashoffset = circumference - (normalizedValue / 100) * circumference;

  return (
    <div
      className="relative flex items-center justify-center select-none"
      style={{ width: size, height: size }}
    >
      <svg
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        className="-rotate-90 overflow-visible"
      >
        <defs>
          <linearGradient id={gradientId} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor={startColor} />
            <stop offset="100%" stopColor={endColor} />
          </linearGradient>
          {glowColor && (
            <filter id={`${gradientId}-glow`} x="-20%" y="-20%" width="140%" height="140%">
              <feDropShadow dx="0" dy="0" stdDeviation="4" floodColor={glowColor} floodOpacity="0.6" />
            </filter>
          )}
        </defs>

        {/* Background Track */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke="rgba(255, 255, 255, 0.07)"
          strokeWidth={strokeWidth}
          fill="transparent"
        />

        {/* Animated Progress Arc */}
        <motion.circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={`url(#${gradientId})`}
          strokeWidth={strokeWidth}
          fill="transparent"
          strokeLinecap="round"
          strokeDasharray={circumference}
          initial={{ strokeDashoffset: circumference }}
          animate={{ strokeDashoffset }}
          transition={{ duration: 1.4, ease: "easeOut" }}
          filter={glowColor ? `url(#${gradientId}-glow)` : undefined}
        />
      </svg>

      {/* Center Display */}
      <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
        {customCenter ? (
          customCenter
        ) : (
          <>
            <span className="font-outfit text-2xl font-extrabold text-white tracking-tight leading-none">
              <AnimatedCounter value={normalizedValue} />%
            </span>
            {centerLabel && (
              <span className="text-[10px] text-slate-400 font-semibold uppercase tracking-wider mt-1">
                {centerLabel}
              </span>
            )}
            {centerSublabel && (
              <span className="text-[9px] text-slate-500 mt-0.5">
                {centerSublabel}
              </span>
            )}
          </>
        )}
      </div>
    </div>
  );
}
