import type { ReactNode } from "react"
import { Signal, Wifi, BatteryFull } from "lucide-react"
import { cn } from "@/lib/utils"

interface PhoneFrameProps {
  children: ReactNode
  label: string
  step: string
  className?: string
}

export function PhoneFrame({ children, label, step, className }: PhoneFrameProps) {
  return (
    <div className="flex flex-col items-center gap-4">
      <div className="flex flex-col items-center gap-1 text-center">
        <span className="inline-flex items-center gap-2 rounded-full bg-accent px-3 py-1 text-xs font-medium text-accent-foreground">
          <span className="grid size-4 place-items-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
            {step}
          </span>
          {label}
        </span>
      </div>

      <div
        className={cn(
          "relative h-[680px] w-[330px] shrink-0 rounded-[2.75rem] border border-border bg-foreground/90 p-3 shadow-2xl shadow-primary/20",
          className,
        )}
      >
        {/* Screen */}
        <div className="relative flex h-full w-full flex-col overflow-hidden rounded-[2.1rem] bg-background">
          {/* Status bar */}
          <div className="flex items-center justify-between px-6 pt-3 pb-1 text-foreground">
            <span className="text-sm font-semibold tabular-nums">9:41</span>
            <div className="flex items-center gap-1.5">
              <Signal className="size-4" aria-hidden="true" />
              <Wifi className="size-4" aria-hidden="true" />
              <BatteryFull className="size-4" aria-hidden="true" />
            </div>
          </div>
          {/* Notch */}
          <div className="pointer-events-none absolute left-1/2 top-2 h-6 w-28 -translate-x-1/2 rounded-full bg-foreground/90" />

          {/* Content */}
          <div className="flex min-h-0 flex-1 flex-col">{children}</div>
        </div>
      </div>
    </div>
  )
}
