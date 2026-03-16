"use client"

import { useProblems } from "@/hooks/useProblems"
import ProblemTable from "@/components/problem/ProblemTable"

export default function ProblemsPage(){

const {data,isLoading} = useProblems()

if(isLoading) return <div>Loading...</div>

return(

<div className="p-6">

<h1 className="text-xl font-semibold mb-4">
Problems
</h1>

<ProblemTable problems={data}/>

</div>

)

}
