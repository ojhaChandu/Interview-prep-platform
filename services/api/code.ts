import api from "./axios"

export const runCode = async(payload:any)=>{
  const {data} = await api.post("/run",payload)
  return data
}

export const submitCode = async(payload:any)=>{
  const {data} = await api.post("/submit",payload)
  return data
}
