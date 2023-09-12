const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
require('dotenv').config({ path: '.env.local' });

const secretKey = process.env.SECRET_KEY;

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
    const { email, password } = req.body;
    const pwHash = await bcrypt.hash(password, 10);

    console.log("sk: ", secretKey);
    console.log("hash: ", pwHash);

    // Write to database
    const colName = 'userid';
    const query = `SELECT fn_CreateUser($1, $2, $3) as ${colName};`;
    const result = await pool.query(query, [email, pwHash, 'EndUser']);

    if (result.rowCount !== 0) {
      res.status(201).json({ 
        valid: true, 
        userId: result.rows[0][colName],
        message: "User created successfully!"
      });
    } else {
      // Username is already in use (invalid)
      res.json({
        valid: false,
        userId: -1,
        message: "A user with same email already exists!"});
    }
  } catch (error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
