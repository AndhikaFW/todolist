import TodoCard from './TodoCard';
import styles from './TodoGrid.module.css';

function SkeletonCard() {
  return <div className={styles.skeleton} />;
}

export default function TodoGrid({ todos, loading, onDelete }) {
  if (loading) {
    return (
      <div className={styles.grid}>
        {Array.from({ length: 6 }).map((_, i) => (
          <SkeletonCard key={i} />
        ))}
      </div>
    );
  }

  if (todos.length === 0) {
    return (
      <div className={styles.center}>
        <div className={styles.emptyIcon}>📝</div>
        <p className={styles.emptyTitle}>No todos yet</p>
        <p className={styles.emptyText}>Click "Add Todo" to create your first task.</p>
      </div>
    );
  }

  return (
    <div className={styles.grid}>
      {todos.map((todo) => (
        <TodoCard key={todo.id} todo={todo} onDelete={onDelete} />
      ))}
    </div>
  );
}
