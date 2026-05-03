const pool = require('../config/db');

const getAllTodos = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM todos ORDER BY created_at DESC'
    );
    res.json({ data: result.rows });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch todos' });
  }
};

const createTodo = async (req, res) => {
  const { title, description } = req.body;
  if (!title || !title.trim()) {
    return res.status(400).json({ error: 'Title is required' });
  }
  try {
    const result = await pool.query(
      'INSERT INTO todos (title, description) VALUES ($1, $2) RETURNING *',
      [title.trim(), description?.trim() || null]
    );
    res.status(201).json({ data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create todo' });
  }
};

const deleteTodo = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'DELETE FROM todos WHERE id = $1 RETURNING *',
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Todo not found' });
    }
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete todo' });
  }
};

module.exports = { getAllTodos, createTodo, deleteTodo };
