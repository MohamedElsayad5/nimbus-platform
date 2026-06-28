import { useQuery } from '@tanstack/react-query'
import { motion } from 'framer-motion'
import { api, PlatformService } from '@/lib/api'
import { Server, CheckCircle, AlertTriangle, XCircle, TrendingUp, RefreshCw } from 'lucide-react'
import { AreaChart, Area, ResponsiveContainer } from 'recharts'

const statusConfig = {
  RUNNING:  { label: 'Running',  className: 'badge-running',  color: '#10b981' },
  DEGRADED: { label: 'Degraded', className: 'badge-degraded', color: '#f59e0b' },
  DOWN:     { label: 'Down',     className: 'badge-down',     color: '#ef4444' },
  UNKNOWN:  { label: 'Unknown',  className: 'badge-unknown',  color: '#64748b' },
}

const generateSparkline = (seed: number) =>
  Array.from({ length: 12 }, (_, i) => ({
    t: i,
    v: Math.max(95, Math.min(100, 98 + Math.sin(i * seed) * 2)),
  }))

function StatusBadge({ status }: { status: PlatformService['status'] }) {
  const cfg = statusConfig[status]
  return (
    <span className={cfg.className}>
      <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: cfg.color }} />
      {cfg.label}
    </span>
  )
}

function ServiceCard({ service, index }: { service: PlatformService; index: number }) {
  const spark   = generateSparkline(service.id * 0.7)
  const healthy = service.status === 'RUNNING'
  const cfg     = statusConfig[service.status]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      className="card hover:border-slate-700 transition-colors"
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className={`w-9 h-9 rounded-lg flex items-center justify-center ${healthy ? 'bg-emerald-500/10' : 'bg-amber-500/10'}`}>
            <Server className={`w-4 h-4 ${healthy ? 'text-emerald-400' : 'text-amber-400'}`} />
          </div>
          <div>
            <h3 className="font-semibold text-slate-100 text-sm">{service.name}</h3>
            <p className="text-xs text-slate-500">{service.region}</p>
          </div>
        </div>
        <StatusBadge status={service.status} />
      </div>

      <p className="text-xs text-slate-400 mb-4 leading-relaxed line-clamp-2">{service.description}</p>

      <div className="h-12 mb-3">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={spark} margin={{ top:0, right:0, left:0, bottom:0 }}>
            <defs>
              <linearGradient id={`g-${service.id}`} x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%"  stopColor={cfg.color} stopOpacity={0.3} />
                <stop offset="95%" stopColor={cfg.color} stopOpacity={0}   />
              </linearGradient>
            </defs>
            <Area type="monotone" dataKey="v" stroke={cfg.color} strokeWidth={1.5} fill={`url(#g-${service.id})`} dot={false} />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      <div className="flex items-center justify-between pt-3 border-t border-slate-800">
        <div>
          <p className="text-xs text-slate-500">Uptime</p>
          <p className="text-sm font-semibold text-slate-200">{service.uptimePct}%</p>
        </div>
        <div>
          <p className="text-xs text-slate-500">Version</p>
          <p className="text-sm font-mono text-nimbus-400">{service.version}</p>
        </div>
      </div>
    </motion.div>
  )
}

export default function DashboardPage() {
  const { data: summary, isLoading, error, refetch, isFetching } = useQuery({
    queryKey: ['platform-summary'],
    queryFn:  api.getSummary,
    refetchInterval: 30_000,
  })

  if (isLoading) return (
    <div className="flex items-center justify-center h-full">
      <div className="flex flex-col items-center gap-4">
        <div className="w-8 h-8 border-2 border-nimbus-500 border-t-transparent rounded-full animate-spin" />
        <p className="text-slate-400 text-sm">Loading platform data...</p>
      </div>
    </div>
  )

  if (error) return (
    <div className="flex items-center justify-center h-full">
      <div className="card max-w-md text-center">
        <XCircle className="w-10 h-10 text-red-400 mx-auto mb-3" />
        <h3 className="font-semibold text-slate-100 mb-2">Failed to load data</h3>
        <p className="text-sm text-slate-400 mb-4">Could not connect to the Nimbus API.</p>
        <button onClick={() => refetch()} className="px-4 py-2 bg-nimbus-600 hover:bg-nimbus-500 text-white text-sm rounded-lg transition-colors">
          Retry
        </button>
      </div>
    </div>
  )

  const stats = [
    { label: 'Total Services', value: summary!.totalServices,    Icon: Server,        color: 'text-slate-300',  bg: 'bg-slate-700/30'    },
    { label: 'Running',        value: summary!.runningServices,  Icon: CheckCircle,   color: 'text-emerald-400', bg: 'bg-emerald-500/10' },
    { label: 'Degraded',       value: summary!.degradedServices, Icon: AlertTriangle, color: 'text-amber-400',   bg: 'bg-amber-500/10'   },
    { label: 'Avg Uptime',     value: `${Number(summary!.overallUptimePct).toFixed(2)}%`, Icon: TrendingUp, color: 'text-nimbus-400', bg: 'bg-nimbus-500/10' },
  ]

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-slate-100">Platform Overview</h1>
          <p className="text-slate-400 text-sm mt-1">Real-time status of all Nimbus services</p>
        </div>
        <button
          onClick={() => refetch()}
          disabled={isFetching}
          className="flex items-center gap-2 px-3 py-2 bg-slate-800 hover:bg-slate-700 border border-slate-700 rounded-lg text-sm text-slate-300 transition-colors disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 ${isFetching ? 'animate-spin' : ''}`} />
          Refresh
        </button>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {stats.map((s, i) => (
          <motion.div key={s.label} initial={{ opacity:0, y:20 }} animate={{ opacity:1, y:0 }} transition={{ delay: i * 0.08 }} className="card">
            <div className="flex items-center gap-3 mb-3">
              <div className={`w-8 h-8 rounded-lg ${s.bg} flex items-center justify-center`}>
                <s.Icon className={`w-4 h-4 ${s.color}`} />
              </div>
              <span className="text-xs text-slate-500">{s.label}</span>
            </div>
            <p className={`text-2xl font-bold ${s.color}`}>{s.value}</p>
          </motion.div>
        ))}
      </div>

      <div>
        <h2 className="text-sm font-semibold text-slate-400 uppercase tracking-wider mb-4">
          Services ({summary!.services.length})
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {summary!.services.map((svc, i) => (
            <ServiceCard key={svc.id} service={svc} index={i} />
          ))}
        </div>
      </div>
    </div>
  )
}
