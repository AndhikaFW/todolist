'use client';

import { useState, useEffect, useCallback } from 'react';
import { fetchTodos, createTodo, deleteTodo } from '../api/todoApi';

export function useTodos() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);

  const loadTodos = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetchTodos();
      setTodos(res.data.data);
    } catch {
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadTodos();
  }, [loadTodos]);

  const addTodo = async (data) => {
    const res = await createTodo(data);
    setTodos((prev) => [res.data.data, ...prev]);
  };

  const removeTodo = async (id) => {
    await deleteTodo(id);
    setTodos((prev) => prev.filter((t) => t.id !== id));
  };

  return { todos, loading, addTodo, removeTodo, reload: loadTodos };
}
