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

router.post('/', async (req, res) => {
  try {
    const { un, pw } = req.body;
    const pwHash = pw; // todo: needs to implement hash logic

    console.log("[loginRoutes::post] start querying database", req.body);

    const query = 'SELECT * FROM fn_GetUserInfo($1)';
    const result = await pool.query(query, [un]);

    console.log("-- completed querying database", result.rows);

    let message = '';

    if (result.rowCount !== 0) {
      const row = result.rows[0];
      const dbPWHash = row['_passwordhash'];

      console.log("[loginRoute::post] dbPWHash: ", dbPWHash);
      console.log("[loginRoute::post] pwHash: ", pwHash);
      if (pwHash === dbPWHash) {
        res.json({ 
          success: true, 
          userId: row['_userid'],
          roleName: row['_roleName'],
          message: "Successfully logged in!"
        });
      }
      else
        message = "Incorrect password!";

      
    } else {
      message = "Invalid username!";
    }

    // failed
    res.json({ 
      success: false, 
      userId: -1,
      roleName: '',
      message: message
    });

  } catch (error) {
    console.error('Error processing the request:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;