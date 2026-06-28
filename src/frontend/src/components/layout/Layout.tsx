import { Outlet, NavLink } from 'react-router-dom'
import { motion } from 'framer-motion'
import { LayoutDashboard, Server, Activity, Settings, Cloud } from 'lucide-react'
import { clsx } from 'clsx'

const navItems = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/services',  icon: Server,          label: 'Services'  },
  { to: '/metrics',   icon: Activity,        label: 'Metrics'   },
  { to: '/settings',  icon: Settings,        label: 'Settings'  },
]

export default function Layout() {
  return (
    <div className="flex h-screen bg-slate-950 overflow-hidden">
      <aside className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col">
        <div className="h-16 flex items-center px-6 border-b border-slate-800">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-nimbus-600 flex items-center justify-center">
              <Cloud className="w-5 h-5 text-white" />
            </div>
            <span className="font-semibold text-slate-100 tracking-tight">Nimbus</span>
          </div>
        </div>

        <nav className="flex-1 px-3 py-4 space-y-1">
          {navItems.map(({ to, icon: Icon, label }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) =>
                clsx(
                  'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150',
                  isActive
                    ? 'bg-nimbus-600/20 text-nimbus-400 border border-nimbus-500/30'
                    : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800'
                )
              }
            >
              <Icon className="w-4 h-4 flex-shrink-0" />
              {label}
            </NavLink>
          ))}
        </nav>

        <div className="p-4 border-t border-slate-800">
          <div className="flex items-center gap-3 px-2">
            <div className="w-7 h-7 rounded-full bg-nimbus-600 flex items-center justify-center text-xs font-bold text-white">
              N
            </div>
            <div>
              <p className="text-xs font-medium text-slate-300">Nimbus Platform</p>
              <p className="text-xs text-slate-500">v1.0.0</p>
            </div>
          </div>
        </div>
      </aside>

      <main className="flex-1 overflow-auto">
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="h-full"
        >
          <Outlet />
        </motion.div>
      </main>
    </div>
  )
}
