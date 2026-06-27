import { PhoneFrame } from "@/components/phone-frame"
import { MerchantDashboard } from "@/components/screens/merchant-dashboard"
import { SmartBooking } from "@/components/screens/smart-booking"
import { LifecycleWizard } from "@/components/screens/lifecycle-wizard"
import { Truck } from "lucide-react"

export default function Page() {
  return (
    <main className="min-h-dvh bg-background">
      {/* Page header */}
      <header className="mx-auto max-w-6xl px-6 pt-12 text-center">
        <span className="inline-flex items-center gap-2 rounded-full bg-accent px-3 py-1 text-xs font-medium text-accent-foreground">
          <span className="grid size-5 place-items-center rounded-full bg-primary text-primary-foreground">
            <Truck className="size-3" aria-hidden="true" />
          </span>
          ShipMate · Merchant &amp; Supplier Logistics
        </span>
        <h1 className="mx-auto mt-4 max-w-2xl text-balance text-3xl font-semibold tracking-tight text-foreground sm:text-4xl">
          A faster way for merchants to track, book, and ship every package
        </h1>
        <p className="mx-auto mt-3 max-w-xl text-pretty leading-relaxed text-muted-foreground">
          Three core flows of the mobile app — a stats-first dashboard, a tap-to-book catalog, and a visual order
          life-cycle with slide-to-ship.
        </p>
      </header>

      {/* Frames */}
      <section className="mx-auto flex max-w-6xl flex-wrap items-start justify-center gap-10 px-6 py-12">
        <PhoneFrame step="1" label="Merchant Dashboard">
          <MerchantDashboard />
        </PhoneFrame>
        <PhoneFrame step="2" label="Smart Manual Booking">
          <SmartBooking />
        </PhoneFrame>
        <PhoneFrame step="3" label="Life-cycle Wizard">
          <LifecycleWizard />
        </PhoneFrame>
      </section>

      <footer className="pb-12 text-center text-xs text-muted-foreground">
        Layout frames · Tap items and drag the slider to interact
      </footer>
    </main>
  )
}
