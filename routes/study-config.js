
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
    const modality = 'CT'; // todo: get this from the request body

    // send files to the data server
    const dsId_image_4d = 
      await ds_PostData(req.files.image_4d[0].path, `${study_id}`, 'image_4d.nii.gz');

    console.log("[studyConfigRoute::post] dsId_image_4d: ", dsId_image_4d);
    
    const dsId_reference_seg_sys = 
      await ds_PostData(req.files.reference_seg_sys[0].path, `${study_id}`, 'reference_seg_sys.nii.gz');
    
    console.log("[studyConfigRoute::post] dsId_reference_seg_sys: ", dsId_reference_seg_sys);

    const dsId_reference_seg_dias =
      await ds_PostData(req.files.reference_seg_dias[0].path, `${study_id}`, 'reference_seg_dias.nii.gz');

    console.log("[studyConfigRoute::post] dsId_reference_seg_dias: ", dsId_reference_seg_dias);
    
    
    
    // insert config to the database
    const colName = 'study_config_id';
    const query = `SELECT fn_create_study_config($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) as ${colName};`;

    const rows = await db.query(query, [
      study_id, dsId_image_4d, modality, tp_start, tp_end,
      dsId_reference_seg_sys, tp_ref_sys, tp_start_sys, tp_end_sys,
      dsId_reference_seg_dias, tp_ref_dias, tp_start_dias, tp_end_dias
    ]);

    console.log("[studyConfigRoute::post] rows: ", rows);

    // respond with success
    res.status(201).json({studyConfigId: rows[0][colName], message: "Study Config created successfully!"});
  } catch (error){
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

export default router;
