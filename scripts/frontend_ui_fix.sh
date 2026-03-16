#!/bin/bash

echo "Fixing UI wiring..."

cd frontend

echo "Updating Navbar..."

cat > components/Navbar.tsx <<'EOF'
"use client"

import Link from "next/link"

export default function Navbar(){

  return (

    <nav className="flex items-center justify-between border-b px-6 py-3">

      <div className="flex gap-6 font-medium">

        <Link href="/">Dashboard</Link>
        <Link href="/problems">Problems</Link>
        <Link href="/notes">Notes</Link>
        <Link href="/ai">AI</Link>

      </div>

      <div className="flex gap-3">

        <Link
          href="/auth/login"
          className="border px-3 py-1 rounded"
        >
          Login
        </Link>

        <Link
          href="/auth/login"
          className="bg-black text-white px-3 py-1 rounded"
        >
          Sign Up
        </Link>

      </div>

    </nav>

  )

}
EOF


echo "Updating Dashboard..."

cat > app/page.tsx <<'EOF'
import Navbar from "@/components/Navbar"
import Link from "next/link"

export default function Home(){

  return(

    <div>

      <Navbar/>

      <div className="max-w-4xl mx-auto p-10">

        <h1 className="text-3xl font-bold mb-6">
          Interview Prep Platform
        </h1>

        <p className="text-gray-500 mb-6">
          Practice coding problems, write notes, and use AI to improve your interview skills.
        </p>

        <div className="grid grid-cols-3 gap-6">

          <Link
            href="/problems"
            className="border p-6 rounded hover:shadow"
          >
            <h2 className="font-semibold mb-2">
              Practice Problems
            </h2>
            <p className="text-sm text-gray-500">
              Solve coding interview questions
            </p>
          </Link>

          <Link
            href="/notes"
            className="border p-6 rounded hover:shadow"
          >
            <h2 className="font-semibold mb-2">
              Study Notes
            </h2>
            <p className="text-sm text-gray-500">
              Save your learnings
            </p>
          </Link>

          <Link
            href="/ai"
            className="border p-6 rounded hover:shadow"
          >
            <h2 className="font-semibold mb-2">
              AI Assistant
            </h2>
            <p className="text-sm text-gray-500">
              Ask coding questions
            </p>
          </Link>

        </div>

      </div>

    </div>

  )

}
EOF


echo "Updating Problems Page..."

cat > app/problems/page.tsx <<'EOF'
"use client"

import { useEffect,useState } from "react"
import Navbar from "@/components/Navbar"
import Link from "next/link"
import { getProblems } from "@/services/problemService"

export default function ProblemsPage(){

  const [problems,setProblems] = useState([])

  useEffect(()=>{

    load()

  },[])

  async function load(){

    try{

      const data = await getProblems()
      setProblems(data)

    }catch(e){

      console.error(e)

    }

  }

  return(

    <div>

      <Navbar/>

      <div className="max-w-4xl mx-auto p-8">

        <h1 className="text-xl font-semibold mb-6">
          Problems
        </h1>

        <div className="space-y-3">

          {problems.map((p:any)=>(
            
            <Link
              key={p.id}
              href={`/problems/${p.id}`}
              className="block border rounded p-4 hover:bg-gray-50"
            >

              <div className="font-medium">
                {p.title}
              </div>

              <div className="text-sm text-gray-500">
                {p.difficulty}
              </div>

            </Link>

          ))}

        </div>

      </div>

    </div>

  )

}
EOF


echo "Frontend UI fixed!"