import api from "./axios"

export const getProblems = async () => {
  const {data} = await api.get("/problems")
  return data
}

export const getProblem = async (id:string)=>{
  const {data} = await api.get(`/problems/${id}`)
  return data
}
