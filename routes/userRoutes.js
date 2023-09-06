const express = require('express');
const { Pool } = require('pg');

const router = express.Router();

// Create a PostgreSQL database connection pool
const pool = new Pool({
  user: 'dbusr_gateway',
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
    console.log("[userRoutes] start querying database");
    const { un, pw } = req.body;

    // Query the database to check if the username exists
    const query = 'SELECT fn_CreateUser($1, $2, $3, $4) as userId;';
    const result = await pool.query(query, [un, pw, 'EndUser', 'Gateway']);

    console.log("-- completed querying database", result.rows);

    if (result.rowCount !== 0) {
      res.json({ 
        valid: true, 
        userId: result.rows[0]['userid'],
        message: "User created successfully!"
      });
    } else {
      // Username is already in use (invalid)
      res.json({
        valid: false,
        userId: -1,
        message: "Username already exists!"});
    }
  } catch (error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
