import { motion } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import { Cloud, Shield, Zap, GitBranch, ArrowRight, Activity, Lock } from 'lucide-react'

const features = [
  { icon: Cloud,      title: 'Cloud Native',      description: 'Built on GKE with private networking, Workload Identity, and auto-scaling from the ground up.' },
  { icon: GitBranch,  title: 'GitOps Driven',      description: 'ArgoCD watches your Git repository. Every change is auditable, reversible, and automated.' },
  { icon: Shield,     title: 'Security First',     description: 'Zero stored credentials via OIDC. Network policies, RBAC, and distroless containers by default.' },
  { icon: Activity,   title: 'Full Observability', description: 'Prometheus metrics, Grafana dashboards, and Alertmanager notifications out of the box.' },
  { icon: Zap,        title: 'Zero-Downtime',      description: 'Rolling updates with PodDisruptionBudgets ensure continuous availability during deployments.' },
  { icon: Lock,       title: 'Least Privilege',    description: 'Every service account and pod has exactly the permissions it needs — nothing more.' },
]

const stack = [
  'GKE','Terraform','ArgoCD','GitHub Actions',
  'Prometheus','Grafana','Spring Boot','React',
  'MySQL','Redis','RabbitMQ','Artifact Registry',
]

const container = {
  hidden:  { opacity: 0 },
  visible: { opacity: 1, transition: { staggerChildren: 0.1 } },
}
const item = {
  hidden:  { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
}

export default function LandingPage() {
  const navigate = useNavigate()

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 overflow-x-hidden">

      {/* Nav */}
      <header className="fixed top-0 left-0 right-0 z-50 border-b border-slate-800/80 bg-slate-950/80 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-nimbus-600 flex items-center justify-center">
              <Cloud className="w-5 h-5 text-white" />
            </div>
            <span className="font-semibold text-lg tracking-tight">Nimbus</span>
          </div>
          <button
            onClick={() => navigate('/dashboard')}
            className="flex items-center gap-2 px-4 py-2 bg-nimbus-600 hover:bg-nimbus-500 text-white text-sm font-medium rounded-lg transition-colors"
          >
            Open Dashboard <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </header>

      {/* Hero */}
      <section className="relative pt-32 pb-24 px-6">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[800px] h-[600px] bg-nimbus-600/10 rounded-full blur-3xl" />
        </div>

        <div className="relative max-w-4xl mx-auto text-center">
          <motion.div initial={{ opacity:0, y:-10 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.5 }}>
            <span className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-medium bg-nimbus-500/10 text-nimbus-400 border border-nimbus-500/20 mb-6">
              <span className="w-1.5 h-1.5 rounded-full bg-nimbus-400 animate-pulse" />
              Production-Grade Cloud Native Platform
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity:0, y:20 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.1 }}
            className="text-5xl md:text-7xl font-bold tracking-tight mb-6"
          >
            Ship cloud software{' '}
            <span className="bg-gradient-to-r from-nimbus-400 to-violet-400 bg-clip-text text-transparent">
              the right way
            </span>
          </motion.h1>

          <motion.p
            initial={{ opacity:0, y:20 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.2 }}
            className="text-xl text-slate-400 max-w-2xl mx-auto mb-10 leading-relaxed"
          >
            Nimbus Platform is an enterprise-grade cloud native infrastructure built on GKE,
            Terraform, and GitOps principles — demonstrating production DevOps engineering at scale.
          </motion.p>

          <motion.div
            initial={{ opacity:0, y:20 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.3 }}
            className="flex flex-col sm:flex-row items-center justify-center gap-4"
          >
            <button
              onClick={() => navigate('/dashboard')}
              className="flex items-center gap-2 px-6 py-3 bg-nimbus-600 hover:bg-nimbus-500 text-white font-semibold rounded-xl transition-all shadow-lg shadow-nimbus-600/25"
            >
              View Dashboard <ArrowRight className="w-5 h-5" />
            </button>
            
            <a 
              href="https://github.com/MohamedElsayad5/nimbus-platform"
              className="flex items-center gap-2 px-6 py-3 bg-slate-800 hover:bg-slate-700 text-slate-200 font-semibold rounded-xl transition-colors border border-slate-700"
            >
              <GitBranch className="w-5 h-5" /> View on GitHub
            </a>
          </motion.div>
        </div>

        {/* Stats */}
        <motion.div
          initial={{ opacity:0, y:30 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.7, delay:0.4 }}
          className="relative max-w-3xl mx-auto mt-20 grid grid-cols-2 md:grid-cols-4 gap-4"
        >
          {[
            { value: '99.9%',  label: 'Uptime SLA' },
            { value: '<100ms', label: 'P99 Latency' },
            { value: '0',      label: 'Stored Credentials' },
            { value: '~$45',   label: 'Monthly Cost' },
          ].map((s) => (
            <div key={s.label} className="card text-center">
              <div className="text-2xl font-bold text-nimbus-400 mb-1">{s.value}</div>
              <div className="text-xs text-slate-500">{s.label}</div>
            </div>
          ))}
        </motion.div>
      </section>

      {/* Features */}
      <section className="py-24 px-6">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Built for production. Designed for learning.</h2>
            <p className="text-slate-400 text-lg max-w-2xl mx-auto">
              Every component reflects real-world engineering decisions you'd find at companies running Kubernetes at scale.
            </p>
          </div>
          <motion.div
            variants={container} initial="hidden" whileInView="visible" viewport={{ once: true }}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            {features.map((f) => (
              <motion.div key={f.title} variants={item} className="card group hover:border-nimbus-500/30 transition-colors">
                <div className="w-10 h-10 rounded-lg bg-nimbus-600/20 border border-nimbus-500/30 flex items-center justify-center mb-4">
                  <f.icon className="w-5 h-5 text-nimbus-400" />
                </div>
                <h3 className="font-semibold text-slate-100 mb-2">{f.title}</h3>
                <p className="text-sm text-slate-400 leading-relaxed">{f.description}</p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Stack */}
      <section className="py-24 px-6 border-t border-slate-800">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-3xl font-bold mb-4">Technology Stack</h2>
          <p className="text-slate-400 mb-12">Industry-standard tools used at scale by leading engineering teams.</p>
          <div className="flex flex-wrap justify-center gap-3">
            {stack.map((tech, i) => (
              <motion.span
                key={tech}
                initial={{ opacity:0, scale:0.9 }}
                whileInView={{ opacity:1, scale:1 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.05 }}
                className="px-4 py-2 bg-slate-800 border border-slate-700 rounded-lg text-sm font-medium text-slate-300 hover:border-nimbus-500/50 hover:text-nimbus-300 transition-colors"
              >
                {tech}
              </motion.span>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-slate-800 py-8 px-6">
        <div className="max-w-7xl mx-auto flex items-center justify-between text-sm text-slate-500">
          <div className="flex items-center gap-2">
            <Cloud className="w-4 h-4 text-nimbus-500" />
            <span>Nimbus Platform</span>
          </div>
          <p>Built with GKE · Terraform · ArgoCD · Prometheus</p>
        </div>
      </footer>
    </div>
  )
}