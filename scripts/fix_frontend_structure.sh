#!/bin/bash

echo "Fixing frontend project structure..."

cd frontend

# Create directories
mkdir -p app/problems
mkdir -p app/notes
mkdir -p app/ai

mkdir -p components
mkdir -p services
mkdir -p types
mkdir -p utils

# Root page
cat > app/page.tsx <<'EOF'
import Navbar from "@/components/Navbar"

export default function Home() {
  return (
    <div>
      <Navbar />
      <div className="p-6">
        <h1 className="text-2xl font-semibold">
          Interview Prep Platform
        </h1>
      </div>
    </div>
  )
}
EOF

# Problems page
cat > app/problems/page.tsx <<'EOF'
"use client"

import { useEffect, useState } from "react"
import Navbar from "@/components/Navbar"
import { getProblems } from "@/services/problemService"
import { Problem } from "@/types/problem"

export default function ProblemsPage() {

  const [problems,setProblems] = useState<Problem[]>([])

  useEffect(()=>{
    loadProblems()
  },[])

  async function loadProblems(){
    try{
      const data = await getProblems()
      setProblems(data)
    }catch(e){
      console.error(e)
    }
  }

  return (
    <div>
      <Navbar/>

      <div className="p-6">

        <h1 className="text-xl font-semibold mb-4">
          Problems
        </h1>

        {problems.map((p)=>(
          <div
            key={p.id}
            className="border rounded p-4 mb-3 hover:bg-gray-50"
          >
            <div className="font-medium">{p.title}</div>
            <div className="text-xs text-gray-500">
              {p.difficulty}
            </div>
          </div>
        ))}

      </div>
    </div>
  )
}
EOF

# AI Page
cat > app/ai/page.tsx <<'EOF'
import Navbar from "@/components/Navbar"
import ChatBox from "@/components/ChatBox"

export default function AIPage(){
  return (
    <div>
      <Navbar/>
      <div className="p-6">
        <h1 className="text-xl font-semibold mb-4">
          AI Assistant
        </h1>
        <ChatBox/>
      </div>
    </div>
  )
}
EOF

# Notes Page
cat > app/notes/page.tsx <<'EOF'
import Navbar from "@/components/Navbar"

export default function NotesPage(){
  return (
    <div>
      <Navbar/>

      <div className="p-6">
        <h1 className="text-xl font-semibold">
          Notes
        </h1>
      </div>

    </div>
  )
}
EOF

# Navbar
cat > components/Navbar.tsx <<'EOF'
import Link from "next/link"

export default function Navbar(){

  return (
    <nav className="border-b p-4 flex gap-6 text-sm font-medium">

      <Link href="/">Dashboard</Link>
      <Link href="/problems">Problems</Link>
      <Link href="/notes">Notes</Link>
      <Link href="/ai">AI</Link>

    </nav>
  )
}
EOF

# ChatBox
cat > components/ChatBox.tsx <<'EOF'
"use client"

import { useState } from "react"
import { askAI } from "@/services/aiService"

export default function ChatBox(){

  const [query,setQuery] = useState("")
  const [answer,setAnswer] = useState("")

  async function handleAsk(){

    try{

      const res = await askAI(query)
      setAnswer(res)

    }catch(e){

      setAnswer("Error retrieving response")

    }

  }

  return (

    <div className="max-w-xl">

      <textarea
        className="border w-full p-3 rounded"
        placeholder="Ask about a coding problem..."
        onChange={(e)=>setQuery(e.target.value)}
      />

      <button
        className="mt-3 px-4 py-2 bg-black text-white rounded"
        onClick={handleAsk}
      >
        Ask AI
      </button>

      <div className="mt-4 text-gray-700 text-sm">
        {answer}
      </div>

    </div>

  )

}
EOF

# API client
cat > services/api.ts <<'EOF'
import axios from "axios"

const api = axios.create({
  baseURL:"http://localhost:8000/api/v1",
  timeout:10000
})

export default api
EOF

# Problem service
cat > services/problemService.ts <<'EOF'
import api from "./api"
import { Problem } from "@/types/problem"

export async function getProblems():Promise<Problem[]>{

  const res = await api.get("/problems")
  return res.data

}
EOF

# AI service
cat > services/aiService.ts <<'EOF'
import api from "./api"

export async function askAI(query:string){

  const res = await api.post("/ai/chat",{query})
  return res.data

}
EOF

# Types
cat > types/problem.ts <<'EOF'
export interface Problem{
  id:string
  title:string
  difficulty:string
  leetcode_url?:string
}
EOF

echo "Frontend structure fixed successfully!"