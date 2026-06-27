"use client"

import { useState } from "react"
import {
  ChevronLeft,
  Search,
  Plus,
  Minus,
  Check,
  Box,
  Boxes,
  Shirt,
  Cookie,
  Smartphone,
  SprayCan,
} from "lucide-react"

interface CatalogItem {
  id: string
  name: string
  sku: string
  price: number
  icon: React.ElementType
}

const catalog: CatalogItem[] = [
  { id: "1", name: "Cotton Tee", sku: "APP-TS-01", price: 240, icon: Shirt },
  { id: "2", name: "Snack Box", sku: "FD-SB-22", price: 180, icon: Cookie },
  { id: "3", name: "Phone Case", sku: "EL-PC-09", price: 320, icon: Smartphone },
  { id: "4", name: "Gift Carton", sku: "PK-GC-04", price: 90, icon: Box },
  { id: "5", name: "Bulk Crate", sku: "PK-BC-12", price: 150, icon: Boxes },
  { id: "6", name: "Body Spray", sku: "CS-BS-07", price: 410, icon: SprayCan },
]

export function SmartBooking() {
  const [counts, setCounts] = useState<Record<string, number>>({ "1": 2, "3": 1 })

  const update = (id: string, delta: number) =>
    setCounts((prev) => {
      const next = Math.max(0, (prev[id] ?? 0) + delta)
      return { ...prev, [id]: next }
    })

  const selected = catalog.filter((c) => (counts[c.id] ?? 0) > 0)
  const totalItems = selected.reduce((s, c) => s + counts[c.id], 0)
  const totalAmount = selected.reduce((s, c) => s + counts[c.id] * c.price, 0)

  return (
    <div className="flex h-full flex-col">
      {/* Top bar */}
      <header className="flex items-center gap-3 px-5 pb-3 pt-2">
        <button className="grid size-9 place-items-center rounded-full bg-muted text-foreground" aria-label="Back">
          <ChevronLeft className="size-5" aria-hidden="true" />
        </button>
        <div>
          <h1 className="text-base font-semibold text-foreground">New Booking</h1>
          <p className="text-xs text-muted-foreground">Tap saved items — no typing</p>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto px-5 pb-40">
        {/* Customer field */}
        <label className="mb-1.5 block text-xs font-medium text-muted-foreground">Ship to</label>
        <div className="flex items-center gap-2 rounded-2xl border border-border bg-card px-3.5 py-3">
          <Search className="size-4 text-muted-foreground" aria-hidden="true" />
          <input
            defaultValue="Kumar Stores, Pune"
            className="w-full bg-transparent text-sm text-foreground outline-none placeholder:text-muted-foreground"
            placeholder="Search customer"
          />
        </div>

        {/* Catalog grid */}
        <div className="mb-3 mt-5 flex items-center justify-between">
          <h2 className="text-sm font-semibold text-foreground">Saved catalog</h2>
          <span className="rounded-full bg-accent px-2.5 py-0.5 text-[11px] font-medium text-accent-foreground">
            {catalog.length} items
          </span>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {catalog.map((item) => {
            const qty = counts[item.id] ?? 0
            const active = qty > 0
            const Icon = item.icon
            return (
              <div
                key={item.id}
                className={`relative rounded-2xl border p-3 transition-colors ${
                  active ? "border-primary bg-accent" : "border-border bg-card"
                }`}
              >
                {active && (
                  <span className="absolute right-2 top-2 grid size-5 place-items-center rounded-full bg-primary text-primary-foreground">
                    <Check className="size-3" aria-hidden="true" />
                  </span>
                )}
                <span
                  className={`grid size-10 place-items-center rounded-xl ${
                    active ? "bg-primary text-primary-foreground" : "bg-muted text-foreground"
                  }`}
                >
                  <Icon className="size-5" aria-hidden="true" />
                </span>
                <p className="mt-2.5 text-sm font-medium text-foreground">{item.name}</p>
                <p className="text-[11px] text-muted-foreground">{item.sku}</p>

                <div className="mt-2.5 flex items-center justify-between">
                  <span className="text-sm font-semibold text-foreground">₹{item.price}</span>
                  {qty === 0 ? (
                    <button
                      onClick={() => update(item.id, 1)}
                      className="grid size-7 place-items-center rounded-lg bg-primary text-primary-foreground"
                      aria-label={`Add ${item.name}`}
                    >
                      <Plus className="size-4" aria-hidden="true" />
                    </button>
                  ) : (
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => update(item.id, -1)}
                        className="grid size-7 place-items-center rounded-lg bg-card text-foreground ring-1 ring-border"
                        aria-label={`Remove one ${item.name}`}
                      >
                        <Minus className="size-4" aria-hidden="true" />
                      </button>
                      <span className="w-4 text-center text-sm font-semibold tabular-nums text-foreground">{qty}</span>
                      <button
                        onClick={() => update(item.id, 1)}
                        className="grid size-7 place-items-center rounded-lg bg-primary text-primary-foreground"
                        aria-label={`Add one ${item.name}`}
                      >
                        <Plus className="size-4" aria-hidden="true" />
                      </button>
                    </div>
                  )}
                </div>
              </div>
            )
          })}
        </div>
      </div>

      {/* Sticky summary + CTA */}
      <div className="absolute inset-x-0 bottom-0 border-t border-border bg-card/95 px-5 pb-6 pt-3 backdrop-blur">
        <div className="mb-3 flex items-center justify-between text-sm">
          <span className="text-muted-foreground">
            {totalItems} item{totalItems === 1 ? "" : "s"} selected
          </span>
          <span className="text-lg font-semibold text-foreground">₹{totalAmount.toLocaleString("en-IN")}</span>
        </div>
        <button
          disabled={totalItems === 0}
          className="w-full rounded-2xl bg-primary py-3.5 text-sm font-semibold text-primary-foreground shadow-lg shadow-primary/30 disabled:opacity-50"
        >
          Confirm booking
        </button>
      </div>
    </div>
  )
}
