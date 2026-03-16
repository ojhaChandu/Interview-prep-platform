import { useQuery } from "@tanstack/react-query"
import { getProblems } from "@/services/api/problems"

export function useProblems(){
  return useQuery({
    queryKey:["problems"],
    queryFn:getProblems
  })
}
