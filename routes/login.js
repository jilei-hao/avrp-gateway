const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt')

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

router.post('/', async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log("[loginRoutes::post] start querying database", req.body);

    const query = 'SELECT * FROM fn_GetUserInfo($1)';
    const result = await pool.query(query, [email]);

    console.log("-- completed querying database", result.rows);

    let message = '';

    if (result.rowCount !== 0) {
      const row = result.rows[0];
      const dbPWHash = row['_passwordhash'];

      console.log("[loginRoute::post] dbPWHash: ", dbPWHash);

      const isPasswordValid = await bcrypt.compare(password, dbPWHash);
      if (isPasswordValid) {
        console.log("password is valid!");
        res.status(200).json({ 
          success: true, 
          userId: row['_userid'],
          roleName: row['_roleName'],
          message: "Successfully logged in!"
        });
      }
      else
        // failed
        res.status(401).json({ 
          success: false, 
          userId: -1,
          roleName: '',
          message: "Invalid credentials!"
        });
      
    } else {
      // failed
      res.status(401).json({ 
        success: false, 
        userId: -1,
        roleName: '',
        message: "Invalid credentials!"
      });
    }

    

  } catch (error) {
    console.error('Error processing the request:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;