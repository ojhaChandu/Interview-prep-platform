"use client"

import { Search } from "lucide-react"

export default function Navbar(){

return(

<div className="sticky top-0 bg-white border-b h-14 flex items-center px-6 justify-between">

<div className="font-bold text-lg">
InterviewPrep
</div>

<div className="flex items-center gap-2">
<Search size={16}/>
<input
className="border rounded px-2 py-1"
placeholder="Search"
/>
</div>

<div className="flex gap-4">
<a href="/dashboard">Dashboard</a>
<a href="/problems">Problems</a>
<a href="/notes">Notes</a>
</div>

</div>

)
}
