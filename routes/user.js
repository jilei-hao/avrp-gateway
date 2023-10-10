const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');

const router = express.Router();
const DBHelpers = require('../util/db_helpers');
const db = DBHelpers.getInstance();

// Middleware to parse JSON requests
router.use(express.json());

// API endpoint to validate a username
router.post('/', async (req, res) => {
  try {
    const { email, password } = req.body;
    const pwHash = await bcrypt.hash(password, 10);

    console.log("[loginRoutes::post] start querying database", email, pwHash);

    // Write to database
    const colName = 'user_id';
    const query = `SELECT fn_create_user($1, $2, $3) as ${colName};`;
    const result = await db.query(query, [email, pwHash, 'EndUser']);

    console.log("-- completed querying database", result);

    if (result.rowCount !== 0) {
      res.status(201).json({ 
        valid: true, 
        userId: result[0][colName],
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
