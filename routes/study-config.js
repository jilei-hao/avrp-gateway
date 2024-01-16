
import express from 'express';
import DBHelpers from '../util/db_helper.js';
import authenticateToken from '../util/auth_middleware.js';
import multer from 'multer';
import dotenv from 'dotenv';
import { ds_PostData } from '../util/ds_helper.js';
import fs from 'fs';

const router = express.Router();
const db = DBHelpers.getInstance();
dotenv.config();

// use multer to parse multipart/form-data
const upload = multer({ dest: process.env.UPLOAD_FILE_CACHE || '../tests/upload_file_cache' });


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

const uploadFileds = upload.fields([
  { name: 'image_4d', maxCount: 1 },
  { name: 'reference_seg_sys', maxCount: 1 },
  { name: 'reference_seg_dias', maxCount: 1 }
]);

router.post('/', authenticateToken, uploadFileds, async (req, res) => {
  try {
    const { 
      study_id, tp_start, tp_end,
      tp_ref_sys, tp_start_sys, tp_end_sys, 
      tp_ref_dias, tp_start_dias, tp_end_dias
    } = req.body;

    console.log("[studyConfigRoute::post] body: ", req.body);
    console.log("[studyConfigRoute::post] files: ", req.files);
    console.log("[studyConfigRoute::post] study_id: ", study_id);

    // send files to the data server
    const dsId_image_4d = 
      await ds_PostData(req.files.image_4d[0].path, `${study_id}`, 'image_4d.nii.gz');
    // const dsId_reference_seg_sys = 
    //   await ds_PostData(req.files.reference_seg_sys[0], `${study_id}`, 'reference_seg_sys.nii.gz');
    // const dsId_reference_seg_dias =
    //   await ds_PostData(req.files.reference_seg_dias[0], `${study_id}`, 'reference_seg_dias.nii.gz');
    
    // insert config to the database

    // respond with success

  } catch (error){
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

export default router;
