const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config({ path: '.env.local' });

const secretKey = process.env.SECRET_KEY;
const router = express.Router();
const DBHelpers = require('../util/db_helpers');

// Middleware to parse JSON requests
router.use(express.json());
const db = DBHelpers.getInstance();

router.post('/', async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log("[loginRoutes::post] start querying database", req.body);

    const query = 'SELECT * FROM fn_get_user_info($1)';
    const result = await db.query(query, [email]);

    if (result.rowCount !== 0) {
      const row = result[0];
      const dbPWHash = row['password_hash'];

      console.log("[loginRoute::post] dbPWHash: ", dbPWHash);

      const isPasswordValid = await bcrypt.compare(password, dbPWHash);

      if (!isPasswordValid) {
        // failed
        res.status(401).json({ 
          success: false, 
          token: '',
          error: "Invalid credentials!"
        });
      }

      const userId = row['user_id'];

      res.status(200).json({
        success: true,
        token: jwt.sign({ userId: userId }, secretKey, { expiresIn: '1h' }),
        error: ''
      });
    } else {
      // failed
      res.status(401).json({ 
        success: false, 
        token: '',
        error: "User not found!"
      });
    }
  } catch (error) {
    console.error('Error processing the request:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;