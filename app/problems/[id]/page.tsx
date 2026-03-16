"use client"

import CodeEditor from "@/components/problem/CodeEditor"

export default function ProblemPage({params}:{params:{id:string}}){

return(

<div className="grid grid-cols-2 h-screen">

<div className="p-6 border-r">
Problem description
</div>

<CodeEditor problemId={params.id}/>

</div>

)

}
