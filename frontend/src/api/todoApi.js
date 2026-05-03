import axios from 'axios';

const BASE = process.env.NEXT_PUBLIC_API_URL;

export const fetchTodos = () => axios.get(`${BASE}/todos`);
export const createTodo = (payload) => axios.post(`${BASE}/todos`, payload);
export const deleteTodo = (id) => axios.delete(`${BASE}/todos/${id}`);
