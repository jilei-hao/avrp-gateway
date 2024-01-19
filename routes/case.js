import express from 'express';
import { DBHelper } from '../util/db-helper.js';
import authenticateToken from '../util/auth_middleware.js';

const router = express.Router();
const dbHelper = DBHelper.getInstance();

// Middleware to parse JSON requests
router.use(express.json());

// API endpoint to validate a username
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { caseName } = req.body;
    const { user } = req;

    console.log("[caseRoute::post] start querying database", caseName, user);

    const colName = 'new_case_id';

    // Write to database
    const query = `SELECT fn_create_case($1, $2) as ${colName};`;
    const result = await dbHelper.query(query, [caseName, user.userId]);

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

export default router;
