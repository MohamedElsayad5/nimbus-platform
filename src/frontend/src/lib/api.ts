import axios from 'axios'

export const apiClient = axios.create({
  baseURL: (import.meta as any).env.VITE_API_URL || '/api/v1',
  timeout: 10_000,
  headers: { 'Content-Type': 'application/json' },
})

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message)
    return Promise.reject(error)
  }
)

export interface PlatformService {
  id:          number
  name:        string
  description: string
  status:      'RUNNING' | 'DEGRADED' | 'DOWN' | 'UNKNOWN'
  region:      string
  version:     string
  uptimePct:   number
  updatedAt:   string
}

export interface PlatformSummary {
  totalServices:    number
  runningServices:  number
  degradedServices: number
  downServices:     number
  overallUptimePct: number
  services:         PlatformService[]
}

export const api = {
  getSummary:  () => apiClient.get<PlatformSummary>('/summary').then(r => r.data),
  getServices: () => apiClient.get<PlatformService[]>('/services').then(r => r.data),
}
