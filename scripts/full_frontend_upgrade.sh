#!/bin/bash

echo "🚀 Upgrading Interview Platform UI..."

cd frontend

echo "📦 Installing dependencies..."

npm install \
axios \
react-markdown \
@monaco-editor/react \
lucide-react \
react-resizable-panels \
next-auth \
bcryptjs \
zod \
react-hook-form

echo "📦 Installing shadcn UI..."

npx shadcn@latest init -y

npx shadcn@latest add button card input textarea tabs dialog badge

echo "📁 Creating directories..."

mkdir -p components/layout
mkdir -p components/problems
mkdir -p components/editor
mkdir -p components/ai
mkdir -p components/notes
mkdir -p components/auth

mkdir -p app/problems/[id]
mkdir -p app/login
mkdir -p app/signup

mkdir -p services
mkdir -p types

echo "🧭 Creating Navbar..."

cat > components/layout/Navbar.tsx <<'EOF'
"use client"

import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function Navbar(){

  return(

    <nav className="flex justify-between items-center border-b px-6 py-3">

      <div className="flex gap-6 font-medium">

        <Link href="/">Dashboard</Link>
        <Link href="/problems">Problems</Link>
        <Link href="/notes">Notes</Link>
        <Link href="/ai">AI</Link>

      </div>

      <div className="flex gap-3">

        <Link href="/login">
          <Button variant="outline">Login</Button>
        </Link>

        <Link href="/signup">
          <Button>Sign Up</Button>
        </Link>

      </div>

    </nav>

  )

}
EOF

echo "📊 Creating Dashboard..."

cat > app/page.tsx <<'EOF'
import Navbar from "@/components/layout/Navbar"
import { Card, CardContent } from "@/components/ui/card"

export default function Dashboard(){

  return(

    <div>

      <Navbar/>

      <div className="max-w-6xl mx-auto p-10">

        <h1 className="text-3xl font-bold mb-6">
          Interview Prep Platform
        </h1>

        <div className="grid grid-cols-3 gap-6">

          <Card>
            <CardContent className="p-6">
              <h2 className="font-semibold mb-2">Practice Problems</h2>
              <p className="text-sm text-gray-500">
                Solve coding interview questions
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <h2 className="font-semibold mb-2">Study Notes</h2>
              <p className="text-sm text-gray-500">
                Save important concepts
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <h2 className="font-semibold mb-2">AI Assistant</h2>
              <p className="text-sm text-gray-500">
                Ask coding questions
              </p>
            </CardContent>
          </Card>

        </div>

      </div>

    </div>

  )

}
EOF

echo "📚 Creating Problems Page..."

cat > app/problems/page.tsx <<'EOF'
"use client"

import { useEffect,useState } from "react"
import axios from "axios"
import Navbar from "@/components/layout/Navbar"
import Link from "next/link"
import { Card,CardContent } from "@/components/ui/card"

export default function ProblemsPage(){

  const [problems,setProblems] = useState([])

  useEffect(()=>{

    load()

  },[])

  async function load(){

    const res = await axios.get("http://127.0.0.1:8000/api/v1/problems")

    setProblems(res.data)

  }

  return(

    <div>

      <Navbar/>

      <div className="max-w-5xl mx-auto p-8">

        <h1 className="text-xl font-semibold mb-6">
          Problems
        </h1>

        <div className="space-y-4">

          {problems.map((p:any)=>(
            
            <Link key={p.id} href={`/problems/${p.id}`}>

              <Card>

                <CardContent className="p-4">

                  <div className="font-medium">
                    {p.title}
                  </div>

                  <div className="text-sm text-gray-500">
                    {p.difficulty}
                  </div>

                </CardContent>

              </Card>

            </Link>

          ))}

        </div>

      </div>

    </div>

  )

}
EOF

echo "💻 Creating Monaco Code Editor..."

cat > components/editor/CodeEditor.tsx <<'EOF'
"use client"

import Editor from "@monaco-editor/react"

export default function CodeEditor(){

  return(

    <Editor
      height="100%"
      defaultLanguage="python"
      theme="vs-dark"
      defaultValue="# Write your solution here"
    />

  )

}
EOF

echo "🧾 Creating Problem Description..."

cat > components/problems/ProblemDescription.tsx <<'EOF'
"use client"

import ReactMarkdown from "react-markdown"

export default function ProblemDescription({content}:{content:string}){

  return(

    <div className="p-6 prose max-w-none">

      <ReactMarkdown>
        {content}
      </ReactMarkdown>

    </div>

  )

}
EOF

echo "🤖 Creating AI Explanation Panel..."

cat > components/ai/AIExplanation.tsx <<'EOF'
"use client"

import { useState } from "react"
import axios from "axios"
import { Button } from "@/components/ui/button"

export default function AIExplanation(){

  const [answer,setAnswer] = useState("")

  async function explain(){

    const res = await axios.post(
      "http://127.0.0.1:8000/api/v1/ai/chat",
      {query:"Explain this problem"}
    )

    setAnswer(res.data.answer)

  }

  return(

    <div className="p-4">

      <Button onClick={explain}>
        Explain with AI
      </Button>

      <div className="mt-4 text-sm whitespace-pre-wrap">
        {answer}
      </div>

    </div>

  )

}
EOF

echo "📝 Creating Notes Panel..."

cat > components/notes/NotesPanel.tsx <<'EOF'
"use client"

import { Textarea } from "@/components/ui/textarea"

export default function NotesPanel(){

  return(

    <div className="p-4">

      <Textarea
        placeholder="Write notes for this problem..."
      />

    </div>

  )

}
EOF

echo "📄 Creating Problem Detail Layout..."

cat > app/problems/[id]/page.tsx <<'EOF'
"use client"

import { Panel,PanelGroup,PanelResizeHandle } from "react-resizable-panels"
import CodeEditor from "@/components/editor/CodeEditor"
import ProblemDescription from "@/components/problems/ProblemDescription"
import AIExplanation from "@/components/ai/AIExplanation"
import NotesPanel from "@/components/notes/NotesPanel"

export default function ProblemPage(){

  const description = `
# Two Sum

Given an array of integers nums and an integer target,
return indices of the two numbers such that they add up to target.
`

  return(

    <PanelGroup direction="horizontal">

      <Panel defaultSize={40}>

        <ProblemDescription content={description}/>

      </Panel>

      <PanelResizeHandle className="w-1 bg-gray-200"/>

      <Panel defaultSize={40}>

        <CodeEditor/>

      </Panel>

      <PanelResizeHandle className="w-1 bg-gray-200"/>

      <Panel defaultSize={20}>

        <AIExplanation/>

        <NotesPanel/>

      </Panel>

    </PanelGroup>

  )

}
EOF

echo "🔐 Creating Login Page..."

cat > app/login/page.tsx <<'EOF'
"use client"

import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

export default function LoginPage(){

  return(

    <div className="flex items-center justify-center h-screen">

      <div className="w-80 space-y-4">

        <h1 className="text-xl font-semibold">Login</h1>

        <Input placeholder="Email"/>

        <Input placeholder="Password" type="password"/>

        <Button className="w-full">
          Login
        </Button>

      </div>

    </div>

  )

}
EOF

echo "🔐 Creating Signup Page..."

cat > app/signup/page.tsx <<'EOF'
"use client"

import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

export default function SignupPage(){

  return(

    <div className="flex items-center justify-center h-screen">

      <div className="w-80 space-y-4">

        <h1 className="text-xl font-semibold">Create Account</h1>

        <Input placeholder="Email"/>

        <Input placeholder="Password" type="password"/>

        <Button className="w-full">
          Sign Up
        </Button>

      </div>

    </div>

  )

}
EOF

echo "🎉 Frontend platform upgrade complete!"