const express = require('express');
const { Pool } = require('pg');

const router = express.Router();

// Create a PostgreSQL database connection pool
const pool = new Pool({
  user: 'dbusr_gateway',
  host: 'localhost',
  database: 'avrp',
  password: 'avrpdev',
  port: 5432,
});

// Middleware to parse JSON requests
router.use(express.json());

// API endpoint to validate a username
router.post('/', async (req, res) => {
  try {
    const { un, pw } = req.body;
    const pwHash = pw; // todo: needs to implement hash logic

    // Query the database to check if the username exists
    console.log("[user::post] start querying database");

    const colName = 'userid';
    const query = `SELECT fn_CreateUser($1, $2, $3) as ${colName};`;
    const result = await pool.query(query, [un, pwHash, 'EndUser']);

    console.log("-- completed querying database", result.rows);

    if (result.rowCount !== 0) {
      res.json({ 
        valid: true, 
        userId: result.rows[0][colName],
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
