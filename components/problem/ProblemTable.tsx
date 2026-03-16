import Link from "next/link"

export default function ProblemTable({problems}:{problems:any[]}){

return(

<table className="w-full border">

<thead>
<tr>
<th>Name</th>
<th>Difficulty</th>
</tr>
</thead>

<tbody>

{problems.map((p)=>(
<tr key={p.id} className="hover:bg-gray-100">

<td>
<Link href={`/problems/${p.id}`}>
{p.title}
</Link>
</td>

<td>{p.difficulty}</td>

</tr>
))}

</tbody>

</table>

)
}
