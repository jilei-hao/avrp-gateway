
import express from 'express';
import { Router } from 'express';
import { DBHelper } from '../util/db-helper.js';
import authenticateToken from '../util/auth_middleware.js';

// Middleware to parse JSON requests
const router = Router();
router.use(express.json());

const dbHelper = DBHelper.getInstance();

router.get('/', authenticateToken, async (req, res) => {
  try {
    const { user } = req;

    console.log("[caseStudiesRoute::get] start querying database", user);

    // query the database
    const query = `SELECT * FROM fn_get_case_study_headers($1);`;
    const rows = await dbHelper.query(query, [user.userId]);

    const case_study_headers = {};

    rows.forEach(row => {
      console.log("[caseStudiesRoute::get] row: ", row);
      const {case_id, case_name, mrn, study_id, study_name} = row;

      if (!case_study_headers[case_id]) {
        case_study_headers[case_id] = {
          id: case_id,
          name: case_name,
          mrn: mrn,
          studies: []
        }
      }

      if (study_id) {
        case_study_headers[case_id].studies.push({
          id: study_id,
          name: study_name
        });
      }
    });

    console.log("[caseStudiesRoute::get] case_study_headers: ", case_study_headers);

    res.status(200).json(case_study_headers);
  } catch(error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

export default router;
