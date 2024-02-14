
import express from 'express';
import { DBHelper, db_GetConfig} from '../util/db-helper.js';
import authenticateToken from '../util/auth_middleware.js';
import multer from 'multer';
import dotenv from 'dotenv';
import { ds_PostFile, ds_GetFileId } from '../util/ds-helper.js';

const router = express.Router();
const db = DBHelper.getInstance();
dotenv.config();

// use multer to parse multipart/form-data
const upload = multer({ dest: process.env.UPLOAD_FILE_CACHE || '../tests/upload_file_cache' });

router.head('/', authenticateToken, async (req, res) => {
  try {
    const { study_id } = req.query;
    console.log("[studyConfigRoute::head] ", study_id);

    // query the database
    const query = `SELECT * FROM fn_get_config_id($1);`;
    const rows = await db.query(query, [study_id]);
    const config_id = rows[0].fn_get_config_id;

    if (config_id === 0) {
      res.status(404).json({ message: "Study Config not found!" });
    } else {
      res.status(200).json({ message: "Study Config found!" });
    }
  } catch (error){
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// API endpoint to validate a username
router.get('/', authenticateToken, async (req, res) => {
  try {
    const result = await db_GetConfig(req.query.study_id);
    if (result.found) {
      res.status(200).json(result.config);
    } else {
      res.status(404).json({ message: "Study Config not found!" });
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
    const image4d_fileId = await ds_GetFileId(`${study_id}`, 'image_4d.nii.gz');
    const dsId_image_4d = image4d_fileId > 0 ? image4d_fileId :
      await ds_PostFile(req.files.image_4d[0].path, `${study_id}`, 'image_4d.nii.gz');

    console.log("[studyConfigRoute::post] dsId_image_4d: ", dsId_image_4d);
    
    const refsegsys_fileId = await ds_GetFileId(`${study_id}`, 'reference_seg_sys.nii.gz');
    const dsId_reference_seg_sys = refsegsys_fileId > 0 ? refsegsys_fileId :
      await ds_PostFile(req.files.reference_seg_sys[0].path, `${study_id}`, 'reference_seg_sys.nii.gz');
    
    console.log("[studyConfigRoute::post] dsId_reference_seg_sys: ", dsId_reference_seg_sys);

    const refsegdias_fileId = await ds_GetFileId(`${study_id}`, 'reference_seg_dias.nii.gz');
    const dsId_reference_seg_dias = refsegdias_fileId > 0 ? refsegdias_fileId : 
      await ds_PostFile(req.files.reference_seg_dias[0].path, `${study_id}`, 'reference_seg_dias.nii.gz');

    console.log("[studyConfigRoute::post] dsId_reference_seg_dias: ", dsId_reference_seg_dias);

    // check if the study config already exists
    const query_check = `SELECT * FROM fn_get_study_config_id($1);`;
    console.log("[studyConfigRoute::post] study_id: ", study_id);
    const rows_check = await db.query(query_check, [study_id]);
    const config_id = rows_check[0].fn_get_study_config_id;
    console.log("[studyConfigRoute::post] config_id: ", config_id);
    if (config_id === 0) {
      // insert config to the database
      const colName = 'study_config_id';
      const query = `SELECT fn_create_study_config($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) as ${colName};`;

      const rows = await db.query(query, [
        study_id, dsId_image_4d, modality, tp_start, tp_end,
        dsId_reference_seg_sys, tp_start_sys, tp_end_sys, tp_ref_sys,
        dsId_reference_seg_dias, tp_start_dias, tp_end_dias, tp_ref_dias, 
      ]);

      console.log("[studyConfigRoute::post] rows: ", rows);

      // respond with success
      res.status(201).json({
        studyConfigId: rows[0][colName],
        message: "Study Config created successfully!",
        config: {
          study_id, tp_start, tp_end,
          tp_ref_sys, tp_start_sys, tp_end_sys, 
          tp_ref_dias, tp_start_dias, tp_end_dias
        }
      });
    } else {
      // respond with error
      console.log("[studyConfigRoute::post] config exists");
      res.status(500).json({studyConfigId: -1, message: "Study Config already exists! Use PUT to update."});
    }
  } catch (error){
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

export default router;
