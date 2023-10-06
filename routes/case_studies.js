const express = require('express');
const router = express.Router();
const DBHelpers = require('../util/db_helpers');
const authenticateToken = require('../util/auth_middleware');

// Middleware to parse JSON requests
router.use(express.json());
const db = DBHelpers.getInstance();

router.post('/', authenticateToken, async (req, res) => {
  try {
    console.log("[CaseStudiesRoute::post] start querying database", req.body);

    const query = 'SELECT * FROM fn_GetUserInfo($1)';
    const result = await db.query(query, [email]);

    console.log("-- completed querying database", result);

    let message = '';

    if (result.rowCount !== 0) {
      const row = result[0];
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