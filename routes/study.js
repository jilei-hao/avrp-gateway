
import express from 'express';
import { DBHelper } from '../util/db-helper.js';
import authenticateToken from '../util/auth_middleware.js';

const router = express.Router();
const db = DBHelper.getInstance();

// Middleware to parse JSON requests
router.use(express.json());

// API endpoint to validate a username
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { studyId } = req.body;
    const { user } = req;

    console.log("[studyRoute::get] studyId: ", studyId);
    res.status(500).json({ error: 'Not Implemented!' });
    
  } catch (error) {
    console.error('Error querying database:', error);
  }
});

router.post('/', authenticateToken, async (req, res) => {
  try {
    const { caseId, studyName } = req.body;

    console.log("[caseRoute::post] start querying database", caseId, studyName);

    // Query the database
    const colName = 'new_study_id';
    const query = `SELECT fn_create_study($1, $2) as ${colName};`;
    const result = await db.query(query, [caseId, studyName]);

    if (result.rowCount !== 0) {
      res.status(201).json({
        studyId: result[0][colName],
        message: "Study created successfully!"
      })
    } else {
      res.status(500).json({
        studyId: -1,
        message: "No study was created! Database returns no record."
      })
    }
  } catch (error){
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

export default router;
