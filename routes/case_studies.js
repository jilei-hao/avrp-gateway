const express = require('express');
const router = express.Router();
const DBHelpers = require('../util/db_helpers');
const db = DBHelpers.getInstance();
const authenticateToken = require('../util/auth_middleware');

// Middleware to parse JSON requests
router.use(express.json());

router.get('/', authenticateToken, async (req, res) => {
  try {
    const { user } = req;

    console.log("[caseStudiesRoute::get] start querying database", user);

    // query the database
    const query = `SELECT * FROM fn_get_case_study_headers($1);`;
    const rows = await db.query(query, [user.userId]);

    const case_study_headers = {};

    rows.forEach(row => {
      const {case_id, case_name, mrn, study_id, study_name} = row;

      if (!case_study_headers[case_id]) {
        case_study_headers[case_id] = {
          id: case_id,
          name: case_name,
          mrn: mrn,
          study_count: 0,
          studies: []
        }

        if (study_id) {
          case_study_headers[case_id].studies.push({
            id: study_id,
            name: study_name
          });
          case_study_headers[case_id].study_count++;
        }
      }
    });

    res.status(200).json(case_study_headers);
  } catch(error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

module.exports = router;
