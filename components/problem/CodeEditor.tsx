"use client"

import Editor from "@monaco-editor/react"
import { useState } from "react"
import { runCode } from "@/services/api/code"

export default function CodeEditor({problemId}:{problemId:string}){

const [code,setCode] = useState("")
const [output,setOutput] = useState("")

async function run(){

const res = await runCode({
problemId,
code
})

setOutput(res.output)

}

return(

<div className="flex flex-col h-full">

<Editor
height="70%"
defaultLanguage="python"
value={code}
onChange={(v)=>setCode(v||"")}
/>

<button
onClick={run}
className="bg-blue-600 text-white p-2 mt-2 rounded"
>
Run
</button>

<pre className="bg-black text-green-400 p-4">
{output}
</pre>

</div>

)
}
