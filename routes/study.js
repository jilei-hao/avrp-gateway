
import express from 'express';
import DBHelpers from '../util/db_helper.js';
import authenticateToken from '../util/auth_middleware.js';

const router = express.Router();
const db = DBHelpers.getInstance();

// Middleware to parse JSON requests
router.use(express.json());

// API endpoint to validate a username
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { caseId } = req.body;
    const { user } = req;

    console.log("[caseRoute::post] start querying database: caseId: ", caseId, "; user: ",user);

    const colName = 'new_case_id';

    // Query the database
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

router.post('/', authenticateToken, async (req, res) => {
  try {
    const { 
      caseId, studyName, mainImageId, tpStart, tpEnd, isReady,
      sysPropaSegId, sysPropaTPRef, sysPropaTPStart, sysPropaTPEnd,
      diasPropaSegId, diasPropaTPRef, diasPropaTPStart, diasPropaTPEnd
    } = req.body;

    const { user } = req;

    const colName = 'new_study_id';

    // Query the database
    const query = 
      `SELECT fn_create_study($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) as ${colName};`;
    const result = await db.query(query, [
      studyName, caseId, mainImageId, tpStart, tpEnd,
      sysPropaSegId, sysPropaTPRef, sysPropaTPStart, sysPropaTPEnd,
      diasPropaSegId, diasPropaTPRef, diasPropaTPStart, diasPropaTPEnd,
      isReady, user.userId
    ])

    console.log("-- completed querying database", result);

    if (result.rowCount !== 0) {
      res.status(201).json({
        valid: true,
        studyId: result[0][colName],
        message: "Study created successfully!"
      })
    } else {
      res.status(500).json({
        valid: false,
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
