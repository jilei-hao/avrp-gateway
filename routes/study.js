const express = require('express');
const router = express.Router();
const DBHelpers = require('../util/db_helpers');
const db = DBHelpers.getInstance();
const authenticateToken = require('../util/auth_middleware');

// Middleware to parse JSON requests
router.use(express.json());

// API endpoint to validate a username
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { caseId } = req.body;
    const { user } = req;

    console.log("[caseRoute::post] start querying database: caseId: ", caseId, "; user: ",user);

    const colName = 'new_case_id';

    // Write to database
    const query = `SELECT fn_get_studies_by_case($1, $2) as ${colName};`;
    const result = await db.query(query, [caseId, user.userId]);

    console.log("-- completed querying database", result);

    if (result.rowCount !== 0) {
      res.status(201).json({ 
        valid: true, 
        caseId: result[0][colName],
        message: "Case created successfully!"
      });
    } else {
      res.status(500).json({
        valid: false,
        caseId: -1,
        message: "No case was created! Database returns no record."
      });
    }
  } catch (error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;
