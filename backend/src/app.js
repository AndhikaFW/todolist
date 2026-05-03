const express = require('express');
const cors = require('cors');
const todoRoutes = require('./routes/todoRoutes');

const app = express();

app.use(cors({ origin: ['http://localhost:5672', 'http://todolist.norugroup.com:5672'] }));
app.use(express.json());

app.use('/api/todos', todoRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

module.exports = app;
