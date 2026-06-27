import {
  PackageCheck,
  Wallet,
  TrendingUp,
  ArrowUpRight,
  ArrowDownRight,
  Truck,
  Clock,
  Plus,
  Home,
  ListOrdered,
  BarChart3,
  User,
} from "lucide-react"

const recentOrders = [
  { id: "#SM-4821", customer: "Aanya Traders", status: "Delivered", amount: "₹1,240", tone: "success" },
  { id: "#SM-4820", customer: "Kumar Stores", status: "In transit", amount: "₹860", tone: "primary" },
  { id: "#SM-4819", customer: "Mehta Mart", status: "Packed", amount: "₹2,310", tone: "muted" },
]

export function MerchantDashboard() {
  return (
    <div className="flex h-full flex-col">
      <div className="flex-1 overflow-y-auto px-5 pb-24 pt-2">
        {/* Header */}
        <header className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground">Good morning,</p>
            <h1 className="text-xl font-semibold text-foreground">Ravi&apos;s Wholesale</h1>
          </div>
          <div className="grid size-11 place-items-center rounded-full bg-accent text-sm font-semibold text-accent-foreground">
            RW
          </div>
        </header>

        {/* Hero balance card */}
        <section className="mt-5 rounded-3xl bg-primary p-5 text-primary-foreground shadow-lg shadow-primary/30">
          <div className="flex items-center gap-2 text-sm/none opacity-90">
            <Wallet className="size-4" aria-hidden="true" />
            Balance payable
          </div>
          <p className="mt-2 text-3xl font-semibold tracking-tight">₹18,450.00</p>
          <div className="mt-4 flex items-center justify-between">
            <span className="inline-flex items-center gap-1 rounded-full bg-primary-foreground/15 px-2.5 py-1 text-xs font-medium">
              <Clock className="size-3.5" aria-hidden="true" />
              Due in 3 days
            </span>
            <button className="rounded-full bg-primary-foreground px-4 py-1.5 text-xs font-semibold text-primary">
              Pay now
            </button>
          </div>
        </section>

        {/* Quick stats */}
        <section className="mt-5">
          <h2 className="mb-3 text-sm font-semibold text-foreground">Today&apos;s overview</h2>
          <div className="grid grid-cols-2 gap-3">
            <StatCard
              icon={<PackageCheck className="size-5" aria-hidden="true" />}
              label="Successful packages"
              value="42"
              delta="+12%"
              up
            />
            <StatCard
              icon={<Truck className="size-5" aria-hidden="true" />}
              label="Out for delivery"
              value="08"
              delta="+3"
              up
            />
            <StatCard
              icon={<TrendingUp className="size-5" aria-hidden="true" />}
              label="Revenue today"
              value="₹26.4k"
              delta="+8%"
              up
            />
            <StatCard
              icon={<Wallet className="size-5" aria-hidden="true" />}
              label="Pending dues"
              value="₹18.4k"
              delta="-5%"
            />
          </div>
        </section>

        {/* Recent orders */}
        <section className="mt-6">
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-sm font-semibold text-foreground">Recent orders</h2>
            <button className="text-xs font-medium text-primary">View all</button>
          </div>
          <ul className="flex flex-col gap-2.5">
            {recentOrders.map((o) => (
              <li
                key={o.id}
                className="flex items-center justify-between rounded-2xl border border-border bg-card p-3"
              >
                <div className="flex items-center gap-3">
                  <span className="grid size-10 place-items-center rounded-xl bg-accent text-accent-foreground">
                    <PackageCheck className="size-5" aria-hidden="true" />
                  </span>
                  <div>
                    <p className="text-sm font-medium text-foreground">{o.id}</p>
                    <p className="text-xs text-muted-foreground">{o.customer}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-sm font-semibold text-foreground">{o.amount}</p>
                  <StatusPill status={o.status} tone={o.tone} />
                </div>
              </li>
            ))}
          </ul>
        </section>
      </div>

      <BottomNav active="Home" />
    </div>
  )
}

function StatCard({
  icon,
  label,
  value,
  delta,
  up,
}: {
  icon: React.ReactNode
  label: string
  value: string
  delta: string
  up?: boolean
}) {
  return (
    <div className="rounded-2xl border border-border bg-card p-4">
      <div className="flex items-center justify-between">
        <span className="grid size-9 place-items-center rounded-xl bg-accent text-accent-foreground">{icon}</span>
        <span
          className={`inline-flex items-center gap-0.5 text-xs font-medium ${
            up ? "text-success" : "text-destructive"
          }`}
        >
          {up ? (
            <ArrowUpRight className="size-3.5" aria-hidden="true" />
          ) : (
            <ArrowDownRight className="size-3.5" aria-hidden="true" />
          )}
          {delta}
        </span>
      </div>
      <p className="mt-3 text-2xl font-semibold tracking-tight text-foreground">{value}</p>
      <p className="text-xs text-muted-foreground">{label}</p>
    </div>
  )
}

function StatusPill({ status, tone }: { status: string; tone: string }) {
  const styles: Record<string, string> = {
    success: "bg-success/12 text-success",
    primary: "bg-primary/12 text-primary",
    muted: "bg-muted text-muted-foreground",
  }
  return (
    <span className={`mt-1 inline-block rounded-full px-2 py-0.5 text-[11px] font-medium ${styles[tone]}`}>
      {status}
    </span>
  )
}

function BottomNav({ active }: { active: string }) {
  const items = [
    { label: "Home", icon: Home },
    { label: "Orders", icon: ListOrdered },
    { label: "Stats", icon: BarChart3 },
    { label: "Profile", icon: User },
  ]
  return (
    <nav className="absolute inset-x-0 bottom-0 border-t border-border bg-card/95 px-6 pb-5 pt-2 backdrop-blur">
      <div className="relative flex items-center justify-between">
        {items.slice(0, 2).map((it) => (
          <NavItem key={it.label} {...it} active={active === it.label} />
        ))}
        <button
          className="grid size-12 -translate-y-3 place-items-center rounded-2xl bg-primary text-primary-foreground shadow-lg shadow-primary/40"
          aria-label="New booking"
        >
          <Plus className="size-6" aria-hidden="true" />
        </button>
        {items.slice(2).map((it) => (
          <NavItem key={it.label} {...it} active={active === it.label} />
        ))}
      </div>
    </nav>
  )
}

function NavItem({
  label,
  icon: Icon,
  active,
}: {
  label: string
  icon: React.ElementType
  active?: boolean
}) {
  return (
    <button className="flex flex-col items-center gap-1">
      <Icon className={`size-5 ${active ? "text-primary" : "text-muted-foreground"}`} aria-hidden="true" />
      <span className={`text-[10px] font-medium ${active ? "text-primary" : "text-muted-foreground"}`}>{label}</span>
    </button>
  )
}
