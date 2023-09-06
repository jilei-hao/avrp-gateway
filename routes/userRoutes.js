const express = require('express');
const { Pool } = require('pg');

const router = express.Router();

// Create a PostgreSQL database connection pool
const pool = new Pool({
  user: 'gateway',
  host: 'localhost',
  database: 'avrp',
  password: 'avrpdev',
  port: 5432, // Change to your PostgreSQL port if necessary
});

// Middleware to parse JSON requests
router.use(express.json());

// API endpoint to validate a username
router.post('/', async (req, res) => {
  try {
    console.log("start querying database");
    const { username } = req.body;

    // Query the database to check if the username exists
    const query = 'SELECT fn_CreateUser($1, $2, $3);';
    const result = await pool.query(query, [username], 'abc', 'Application');

    console.log("completed querying database", result);

    if (result.rowCount === 0) {
      // Username is not found in the database (valid)
      res.json({ valid: true });
    } else {
      // Username is already in use (invalid)
      res.json({ valid: false });
    }
  } catch (error) {
    console.error('Error validating username:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
