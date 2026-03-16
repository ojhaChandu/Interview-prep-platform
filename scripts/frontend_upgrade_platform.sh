#!/bin/bash

echo "🚀 Upgrading frontend to full coding platform UI..."

cd frontend

echo "📦 Installing UI dependencies..."

npm install \
react-markdown \
@monaco-editor/react \
next-auth \
axios \
react-resizable-panels

echo "📁 Creating new directories..."

mkdir -p components/editor
mkdir -p components/problem
mkdir -p components/notes
mkdir -p components/ai
mkdir -p services
mkdir -p types
mkdir -p app/problems/[id]
mkdir -p app/auth/login
mkdir -p app/api/auth/[...nextauth]

echo "🧠 Creating Monaco Code Editor..."

cat > components/editor/CodeEditor.tsx <<'EOF'
"use client"

import Editor from "@monaco-editor/react"
import { useState } from "react"

export default function CodeEditor() {

  const [code,setCode] = useState("// Write your solution here")

  return (

    <div className="h-full border rounded">

      <Editor
        height="100%"
        defaultLanguage="python"
        theme="vs-dark"
        value={code}
        onChange={(v)=>setCode(v || "")}
      />

    </div>

  )

}
EOF

echo "🧾 Creating Markdown renderer..."

cat > components/problem/ProblemDescription.tsx <<'EOF'
"use client"

import ReactMarkdown from "react-markdown"

export default function ProblemDescription({content}:{content:string}){

  return (

    <div className="prose max-w-none p-4">

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

export default function AIExplanation({problem}:{problem:string}){

  const [answer,setAnswer] = useState("")

  async function getExplanation(){

    const res = await axios.post(
      "http://127.0.0.1:8000/api/v1/ai/chat",
      {query:problem}
    )

    setAnswer(res.data.answer)

  }

  return(

    <div className="p-4 border-l h-full">

      <button
        className="bg-black text-white px-3 py-2 rounded mb-4"
        onClick={getExplanation}
      >
        Explain with AI
      </button>

      <div className="text-sm whitespace-pre-wrap">
        {answer}
      </div>

    </div>

  )

}
EOF

echo "📝 Creating Notes Panel..."

cat > components/notes/NotesPanel.tsx <<'EOF'
"use client"

import { useState } from "react"

export default function NotesPanel(){

  const [note,setNote] = useState("")

  return(

    <div className="p-4">

      <textarea
        className="w-full border p-3 rounded"
        rows={8}
        placeholder="Write your notes..."
        value={note}
        onChange={(e)=>setNote(e.target.value)}
      />

    </div>

  )

}
EOF

echo "📄 Creating Problem Detail Page..."

cat > app/problems/[id]/page.tsx <<'EOF'
"use client"

import { Panel, PanelGroup, PanelResizeHandle } from "react-resizable-panels"
import CodeEditor from "@/components/editor/CodeEditor"
import ProblemDescription from "@/components/problem/ProblemDescription"
import AIExplanation from "@/components/ai/AIExplanation"
import NotesPanel from "@/components/notes/NotesPanel"

export default function ProblemPage(){

  const description = `
# Two Sum

Given an array of integers nums and an integer target,
return indices of the two numbers such that they add up to target.

Example:
nums = [2,7,11,15]
target = 9

Output:
[0,1]
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

        <AIExplanation problem="Explain Two Sum problem"/>

        <NotesPanel/>

      </Panel>

    </PanelGroup>

  )

}
EOF

echo "🔐 Creating Login Page..."

cat > app/auth/login/page.tsx <<'EOF'
"use client"

import { signIn } from "next-auth/react"

export default function LoginPage(){

  return(

    <div className="flex items-center justify-center h-screen">

      <div className="border p-6 rounded">

        <h1 className="text-xl mb-4">Login</h1>

        <button
          className="bg-black text-white px-4 py-2 rounded"
          onClick={()=>signIn("google")}
        >
          Sign in with Google
        </button>

      </div>

    </div>

  )

}
EOF

echo "🔑 Creating NextAuth config..."

cat > app/api/auth/[...nextauth]/route.ts <<'EOF'
import NextAuth from "next-auth"
import GoogleProvider from "next-auth/providers/google"

const handler = NextAuth({

  providers: [

    GoogleProvider({

      clientId:process.env.GOOGLE_CLIENT_ID!,
      clientSecret:process.env.GOOGLE_CLIENT_SECRET!

    })

  ]

})

export {handler as GET,handler as POST}
EOF

echo "📦 Creating types..."

cat > types/problem.ts <<'EOF'
export interface Problem{

  id:string
  title:string
  description:string
  difficulty:string

}
EOF

echo "🎉 Frontend upgrade completed!"