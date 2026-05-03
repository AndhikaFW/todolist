import { useState } from 'react';
import Navbar from './components/Navbar';
import TodoGrid from './components/TodoGrid';
import AddTodoModal from './components/AddTodoModal';
import { useTodos } from './hooks/useTodos';
import styles from './App.module.css';

export default function App() {
  const { todos, loading, addTodo, removeTodo } = useTodos();
  const [showModal, setShowModal] = useState(false);

  return (
    <>
      <Navbar onAddClick={() => setShowModal(true)} />
      <main className={styles.main}>
        <div className={styles.header}>
          <h2 className={styles.heading}>My Todos</h2>
          <span className={styles.count}>
            {loading ? '...' : `${todos.length} task${todos.length !== 1 ? 's' : ''}`}
          </span>
        </div>
        <TodoGrid
          todos={todos}
          loading={loading}
          onDelete={removeTodo}
        />
      </main>
      {showModal && (
        <AddTodoModal
          onClose={() => setShowModal(false)}
          onAdd={addTodo}
        />
      )}
    </>
  );
}
