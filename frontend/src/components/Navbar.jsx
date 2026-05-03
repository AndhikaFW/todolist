'use client';

import styles from './Navbar.module.css';

export default function Navbar({ onAddClick }) {
  return (
    <header className={styles.navbar}>
      <div className={styles.inner}>
        <h1 className={styles.logo}>
          <span className={styles.logoIcon}>✓</span>
          TodoList
        </h1>
        <button className={styles.addBtn} onClick={onAddClick}>
          + Add Todo
        </button>
      </div>
    </header>
  );
}
