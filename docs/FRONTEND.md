# Frontend Architecture

The frontend is built with Next.js 15 using the App Router, TypeScript, and modern React patterns with a focus on performance and user experience.

## 🏗️ Project Structure

```
frontend/
├── app/                        # Next.js App Router
│   ├── globals.css            # Global styles and Tailwind imports
│   ├── layout.tsx             # Root layout component
│   ├── page.tsx               # Landing page (redirects to login)
│   ├── login/                 # Authentication pages
│   │   └── page.tsx
│   ├── signup/
│   │   └── page.tsx
│   ├── dashboard/             # Main dashboard
│   │   └── page.tsx
│   ├── problems/              # Problem-related pages
│   │   ├── page.tsx           # Problems list
│   │   └── [id]/              # Dynamic problem detail
│   │       └── page.tsx
│   ├── notes/                 # Notes management
│   │   └── page.tsx
│   └── ai/                    # AI assistant page
│       └── page.tsx
├── components/                 # Reusable components
│   ├── ui/                    # shadcn/ui components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── textarea.tsx
│   │   └── tabs.tsx
│   ├── layout/                # Layout components
│   │   └── Navbar.tsx
│   ├── problems/              # Problem-specific components
│   │   └── ProblemDescription.tsx
│   ├── editor/                # Code editor components
│   │   └── CodeEditor.tsx
│   ├── ai/                    # AI-related components
│   │   └── AIExplanation.tsx
│   ├── notes/                 # Notes components
│   │   └── NotesPanel.tsx
│   └── ChatBox.tsx            # AI chat interface
├── services/                   # API and external services
│   ├── api.ts                 # Axios configuration
│   └── aiService.ts           # AI service functions
├── utils/                      # Utility functions
│   └── auth.ts                # Authentication utilities
├── lib/                        # Library configurations
│   └── utils.ts               # Utility functions
├── public/                     # Static assets
├── next.config.mjs            # Next.js configuration
├── tailwind.config.ts         # Tailwind CSS configuration
├── tsconfig.json              # TypeScript configuration
└── package.json               # Dependencies and scripts
```

## 🎨 Design System

### Tailwind CSS Configuration
```typescript
// tailwind.config.ts
export default {
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        // ... more color definitions
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'system-ui', 'sans-serif'],
        mono: ['SF Mono', 'Monaco', 'Consolas', 'monospace'],
      },
      fontSize: {
        base: '14px', // LeetCode-style base font size
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
```

### Global Styles
```css
/* app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    /* ... CSS custom properties */
  }
  
  body {
    font-size: 14px;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
    line-height: 1.5;
  }
}
```

## 🧩 Component Architecture

### Layout Components

#### Navbar Component
```typescript
// components/layout/Navbar.tsx
export default function Navbar() {
  const [authenticated, setAuthenticated] = useState(false)

  useEffect(() => {
    setAuthenticated(isAuthenticated())
  }, [])

  const handleLogout = () => {
    logout()
  }

  return (
    <nav className="flex justify-between items-center border-b bg-card px-6 py-3">
      {/* Navigation content */}
    </nav>
  )
}
```

### Problem Components

#### Problem Detail Page
```typescript
// app/problems/[id]/page.tsx
export default function ProblemPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params) // Next.js 15 async params
  const [problem, setProblem] = useState<ProblemDetail | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchProblem()
  }, [id])

  return (
    <div className="h-screen flex flex-col">
      {/* Resizable panels layout */}
      <PanelGroup orientation="horizontal">
        <Panel defaultSize={35}>
          <ProblemDescription content={problem?.description} />
        </Panel>
        <PanelResizeHandle />
        <Panel defaultSize={45}>
          <CodeEditor />
        </Panel>
        <PanelResizeHandle />
        <Panel defaultSize={20}>
          <AIExplanation problem={problem} />
          <NotesPanel />
        </Panel>
      </PanelGroup>
    </div>
  )
}
```

### AI Components

#### Chat Interface
```typescript
// components/ChatBox.tsx
interface Message {
  role: "user" | "assistant"
  content: string
}

export default function ChatBox() {
  const [messages, setMessages] = useState<Message[]>([])
  const [query, setQuery] = useState("")
  const [loading, setLoading] = useState(false)

  // Auto-scroll to latest response
  useEffect(() => {
    if (messages.length > 0 && messages[messages.length - 1].role === "assistant") {
      scrollToLatestResponse()
    }
  }, [messages])

  return (
    <div className="h-full flex flex-col">
      {/* Messages area */}
      <div className="flex-1 overflow-y-auto">
        {messages.map((msg, idx) => (
          <MessageBubble key={idx} message={msg} />
        ))}
      </div>
      
      {/* Input area */}
      <div className="border-t p-4">
        <ChatInput onSend={handleSend} loading={loading} />
      </div>
    </div>
  )
}
```

#### Syntax Highlighting
```typescript
// Enhanced code blocks with VSCode-style highlighting
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { vscDarkPlus } from 'react-syntax-highlighter/dist/esm/styles/prism'

const CodeBlock = ({ language, children }) => (
  <SyntaxHighlighter
    style={vscDarkPlus}
    language={language}
    showLineNumbers={true}
    customStyle={{
      borderRadius: '8px',
      fontSize: '13px',
      lineHeight: '1.4'
    }}
  >
    {children}
  </SyntaxHighlighter>
)
```

## 🔄 State Management

### Local State with React Hooks
```typescript
// Custom hooks for common patterns
const useAuth = () => {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('token')
    if (token) {
      // Validate token and set user
    }
    setLoading(false)
  }, [])

  return { user, loading, login, logout }
}

const useProblems = () => {
  const [problems, setProblems] = useState([])
  const [loading, setLoading] = useState(false)

  const fetchProblems = async () => {
    setLoading(true)
    try {
      const response = await api.get('/problems/')
      setProblems(response.data)
    } finally {
      setLoading(false)
    }
  }

  return { problems, loading, fetchProblems }
}
```

## 🌐 API Integration

### Axios Configuration
```typescript
// services/api.ts
import axios from "axios"
import { logout } from "@/utils/auth"

const api = axios.create({
  baseURL: "http://localhost:8000/api/v1",
  timeout: 10000
})

// Request interceptor - add auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Response interceptor - handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      logout() // Auto-logout on token expiry
    }
    return Promise.reject(error)
  }
)
```

### Service Functions
```typescript
// services/aiService.ts
export async function askAI(query: string) {
  if (!isAuthenticated()) {
    throw new Error('Please log in to use AI features.')
  }
  
  const res = await api.post("/ai/chat", { query })
  return res.data
}

// services/problemService.ts
export async function getProblems() {
  const response = await api.get('/problems/')
  return response.data
}

export async function getProblemDetail(id: string) {
  const response = await api.get(`/problems/${id}/detail`)
  return response.data
}
```

## 🎯 Routing and Navigation

### App Router Structure
```typescript
// app/layout.tsx - Root layout
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  )
}

// Dynamic routing with Next.js 15
// app/problems/[id]/page.tsx
export default function ProblemPage({ 
  params 
}: { 
  params: Promise<{ id: string }> 
}) {
  const { id } = use(params) // New async params handling
  // Component logic
}
```

### Navigation Guards
```typescript
// utils/auth.ts
export const logout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  window.location.href = '/login'
}

export const isAuthenticated = () => {
  return !!localStorage.getItem('token')
}

// Protected route pattern
const ProtectedPage = () => {
  useEffect(() => {
    if (!isAuthenticated()) {
      router.push('/login')
    }
  }, [])

  return <PageContent />
}
```

## 🎨 UI Components

### shadcn/ui Integration
```typescript
// components/ui/button.tsx
import { cn } from "@/lib/utils"

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
```

### Custom Components
```typescript
// components/LoadingSpinner.tsx
export const LoadingSpinner = ({ size = "md" }) => (
  <div className={`animate-spin rounded-full border-b-2 border-primary ${
    size === "sm" ? "h-4 w-4" : 
    size === "md" ? "h-8 w-8" : 
    "h-12 w-12"
  }`} />
)

// components/ErrorBoundary.tsx
export class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true }
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />
    }
    return this.props.children
  }
}
```

## 📱 Responsive Design

### Mobile-First Approach
```typescript
// Responsive breakpoints
const breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
}

// Responsive component example
const ResponsiveLayout = () => (
  <div className="
    grid 
    grid-cols-1 
    md:grid-cols-2 
    lg:grid-cols-3 
    gap-4 
    p-4
  ">
    {/* Content */}
  </div>
)
```

### Adaptive UI Components
```typescript
// components/AdaptivePanel.tsx
const AdaptivePanel = ({ children }) => {
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768)
    checkMobile()
    window.addEventListener('resize', checkMobile)
    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  return isMobile ? (
    <MobileLayout>{children}</MobileLayout>
  ) : (
    <DesktopLayout>{children}</DesktopLayout>
  )
}
```

## ⚡ Performance Optimizations

### Code Splitting
```typescript
// Dynamic imports for code splitting
const CodeEditor = dynamic(() => import('@/components/editor/CodeEditor'), {
  loading: () => <LoadingSpinner />,
  ssr: false
})

const AIChat = dynamic(() => import('@/components/ChatBox'), {
  loading: () => <div>Loading AI...</div>
})
```

### Memoization
```typescript
// React.memo for expensive components
const ProblemCard = React.memo(({ problem }) => (
  <div className="border rounded-lg p-4">
    <h3>{problem.title}</h3>
    <p>{problem.difficulty}</p>
  </div>
))

// useMemo for expensive calculations
const filteredProblems = useMemo(() => 
  problems.filter(p => p.difficulty === selectedDifficulty),
  [problems, selectedDifficulty]
)
```

### Image Optimization
```typescript
// Next.js Image component
import Image from 'next/image'

const OptimizedImage = () => (
  <Image
    src="/hero-image.jpg"
    alt="Interview Prep"
    width={800}
    height={400}
    priority
    placeholder="blur"
  />
)
```

## 🧪 Testing Strategy

### Component Testing
```typescript
// __tests__/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from '@/components/ui/button'

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })

  it('handles click events', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    
    fireEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### Integration Testing
```typescript
// __tests__/pages/problems.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import ProblemsPage from '@/app/problems/page'

// Mock API calls
jest.mock('@/services/api')

describe('Problems Page', () => {
  it('displays problems list', async () => {
    render(<ProblemsPage />)
    
    await waitFor(() => {
      expect(screen.getByText('Two Sum')).toBeInTheDocument()
    })
  })
})
```

## 🚀 Build and Deployment

### Next.js Configuration
```javascript
// next.config.mjs
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  images: {
    domains: ['example.com'],
  },
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },
}

export default nextConfig
```

### Build Optimization
```json
// package.json scripts
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch"
  }
}
```

### Environment Variables
```bash
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_APP_ENV=development
```

## 📊 Monitoring and Analytics

### Error Tracking
```typescript
// utils/errorTracking.ts
export const trackError = (error: Error, context?: any) => {
  console.error('Error tracked:', error, context)
  // Send to error tracking service
}

// Global error handler
window.addEventListener('unhandledrejection', (event) => {
  trackError(new Error(event.reason), { type: 'unhandledrejection' })
})
```

### Performance Monitoring
```typescript
// utils/performance.ts
export const measurePerformance = (name: string, fn: () => void) => {
  const start = performance.now()
  fn()
  const end = performance.now()
  console.log(`${name} took ${end - start} milliseconds`)
}
```

## 🔧 Development Tools

### TypeScript Configuration
```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

### ESLint Configuration
```json
// .eslintrc.json
{
  "extends": ["next/core-web-vitals", "@typescript-eslint/recommended"],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
```