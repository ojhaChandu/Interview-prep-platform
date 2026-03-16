"use client"

import { Code, Notebook } from "lucide-react"

export default function Sidebar(){

return(

<div className="w-60 border-r h-screen p-4">

<nav className="space-y-3">

<a className="flex gap-2 items-center">
<Code size={16}/>
Problems
</a>

<a className="flex gap-2 items-center">
<Notebook size={16}/>
Notes
</a>

</nav>

</div>

)
}
