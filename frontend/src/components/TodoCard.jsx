import styles from './TodoCard.module.css';

function formatDate(isoString) {
  return new Date(isoString).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

export default function TodoCard({ todo, onDelete }) {
  return (
    <div className={styles.card}>
      <button
        className={styles.deleteBtn}
        onClick={() => onDelete(todo.id)}
        title="Delete todo"
      >
        ✕
      </button>
      <div className={styles.body}>
        <h3 className={styles.title}>{todo.title}</h3>
        {todo.description && (
          <p className={styles.description}>{todo.description}</p>
        )}
      </div>
      <div className={styles.footer}>
        <span className={styles.date}>{formatDate(todo.created_at)}</span>
        {todo.completed && <span className={styles.badge}>Done</span>}
      </div>
    </div>
  );
}
