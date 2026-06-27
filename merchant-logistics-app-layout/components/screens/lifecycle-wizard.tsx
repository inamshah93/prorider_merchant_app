"use client"

import { useRef, useState } from "react"
import { ChevronLeft, FilePlus2, Printer, PackageCheck, Truck, Check, ChevronsRight } from "lucide-react"

interface Step {
  key: string
  title: string
  desc: string
  time: string
  icon: React.ElementType
}

const steps: Step[] = [
  { key: "created", title: "Order created", desc: "Booking confirmed for Kumar Stores", time: "9:02 AM", icon: FilePlus2 },
  { key: "printed", title: "Label printed", desc: "AWB #SM-4821 generated", time: "9:18 AM", icon: Printer },
  { key: "packed", title: "Packed", desc: "3 items sealed & weighed (2.4 kg)", time: "9:41 AM", icon: PackageCheck },
  { key: "ready", title: "Ready to ship", desc: "Hand over to courier partner", time: "Pending", icon: Truck },
]

export function LifecycleWizard() {
  // first 3 steps complete, last one unlocked via slide
  const [shipped, setShipped] = useState(false)
  const currentIndex = shipped ? 4 : 3

  return (
    <div className="flex h-full flex-col">
      {/* Top bar */}
      <header className="flex items-center gap-3 px-5 pb-2 pt-2">
        <button className="grid size-9 place-items-center rounded-full bg-muted text-foreground" aria-label="Back">
          <ChevronLeft className="size-5" aria-hidden="true" />
        </button>
        <div>
          <h1 className="text-base font-semibold text-foreground">Order #SM-4821</h1>
          <p className="text-xs text-muted-foreground">Life-cycle tracking</p>
        </div>
      </header>

      {/* Progress summary */}
      <div className="px-5 pb-2 pt-1">
        <div className="rounded-2xl bg-accent p-4">
          <div className="flex items-center justify-between text-xs font-medium text-accent-foreground">
            <span>Progress</span>
            <span className="tabular-nums">{Math.min(currentIndex, 4)} / 4 stages</span>
          </div>
          <div className="mt-2 h-2 w-full overflow-hidden rounded-full bg-primary-foreground/60">
            <div
              className="h-full rounded-full bg-primary transition-all duration-500"
              style={{ width: `${(Math.min(currentIndex, 4) / 4) * 100}%` }}
            />
          </div>
        </div>
      </div>

      {/* Timeline */}
      <div className="flex-1 overflow-y-auto px-5 pb-36 pt-3">
        <ol className="relative">
          {steps.map((step, i) => {
            const done = i < currentIndex
            const isCurrent = i === currentIndex - 1
            const Icon = done ? Check : step.icon
            const last = i === steps.length - 1
            return (
              <li key={step.key} className="relative flex gap-4 pb-7 last:pb-0">
                {/* connector */}
                {!last && (
                  <span
                    className={`absolute left-[19px] top-10 h-[calc(100%-1.5rem)] w-0.5 ${
                      i < currentIndex - 1 ? "bg-primary" : "bg-border"
                    }`}
                    aria-hidden="true"
                  />
                )}
                {/* node */}
                <span
                  className={`relative z-10 grid size-10 shrink-0 place-items-center rounded-full border-2 transition-colors ${
                    done
                      ? "border-primary bg-primary text-primary-foreground"
                      : "border-border bg-card text-muted-foreground"
                  } ${isCurrent ? "ring-4 ring-primary/15" : ""}`}
                >
                  <Icon className="size-5" aria-hidden="true" />
                </span>
                {/* content */}
                <div className="flex flex-1 items-start justify-between pt-1">
                  <div>
                    <p className={`text-sm font-semibold ${done ? "text-foreground" : "text-muted-foreground"}`}>
                      {step.title}
                    </p>
                    <p className="mt-0.5 text-xs text-muted-foreground">{step.desc}</p>
                  </div>
                  <span
                    className={`shrink-0 pl-2 text-[11px] font-medium ${
                      done ? "text-primary" : "text-muted-foreground"
                    }`}
                  >
                    {done && step.time === "Pending" ? "Done" : step.time}
                  </span>
                </div>
              </li>
            )
          })}
        </ol>
      </div>

      {/* Slide to ship */}
      <div className="absolute inset-x-0 bottom-0 bg-card/95 px-5 pb-6 pt-3 backdrop-blur">
        <SlideToShip shipped={shipped} onComplete={() => setShipped(true)} />
      </div>
    </div>
  )
}

function SlideToShip({ shipped, onComplete }: { shipped: boolean; onComplete: () => void }) {
  const trackRef = useRef<HTMLDivElement>(null)
  const [x, setX] = useState(0)
  const [dragging, setDragging] = useState(false)
  const knob = 52

  const max = () => {
    const w = trackRef.current?.clientWidth ?? 280
    return w - knob - 8
  }

  const onPointerDown = (e: React.PointerEvent) => {
    if (shipped) return
    setDragging(true)
    e.currentTarget.setPointerCapture(e.pointerId)
  }

  const onPointerMove = (e: React.PointerEvent) => {
    if (!dragging || shipped) return
    const rect = trackRef.current?.getBoundingClientRect()
    if (!rect) return
    const next = Math.min(Math.max(0, e.clientX - rect.left - knob / 2), max())
    setX(next)
  }

  const onPointerUp = () => {
    if (shipped) return
    setDragging(false)
    if (x >= max() * 0.85) {
      setX(max())
      onComplete()
    } else {
      setX(0)
    }
  }

  const progress = shipped ? 1 : x / max()

  return (
    <div
      ref={trackRef}
      className={`relative h-14 select-none overflow-hidden rounded-2xl transition-colors ${
        shipped ? "bg-success" : "bg-primary/15"
      }`}
    >
      {/* label */}
      <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
        <span
          className={`flex items-center gap-1.5 text-sm font-semibold ${
            shipped ? "text-success-foreground" : "text-primary"
          }`}
          style={{ opacity: shipped ? 1 : 1 - progress * 1.4 }}
        >
          {shipped ? (
            <>
              <Check className="size-4" aria-hidden="true" /> Ready to ship!
            </>
          ) : (
            <>
              Slide to mark ready <ChevronsRight className="size-4" aria-hidden="true" />
            </>
          )}
        </span>
      </div>

      {/* knob */}
      <button
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
        disabled={shipped}
        aria-label="Slide to mark ready to ship"
        className={`absolute top-1 grid size-12 cursor-grab touch-none place-items-center rounded-xl text-primary-foreground shadow-md active:cursor-grabbing ${
          shipped ? "bg-success-foreground/20" : "bg-primary"
        } ${dragging ? "" : "transition-[left] duration-300"}`}
        style={{ left: shipped ? max() : x + 4 }}
      >
        {shipped ? (
          <Truck className="size-5 text-success-foreground" aria-hidden="true" />
        ) : (
          <Truck className="size-5" aria-hidden="true" />
        )}
      </button>
    </div>
  )
}
