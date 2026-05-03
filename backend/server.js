require('dotenv').config();
const app = require('./src/app');
const pool = require('./src/config/db');

const PORT = process.env.PORT || 5000;

pool.connect((err, client, release) => {
  if (err) {
    process.exit(1);
  }
  release();
  app.listen(PORT);
});
