const express = require('express');
const { getAllTodos, createTodo, deleteTodo } = require('../controllers/todoController');

const router = express.Router();

router.get('/', getAllTodos);
router.post('/', createTodo);
router.delete('/:id', deleteTodo);

module.exports = router;
