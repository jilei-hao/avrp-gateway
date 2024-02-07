// handler route
// get all the incomplete studies with module status

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
    console.log("[handler-tasks::get] start querying database");

    // query the database
    const query = `SELECT * FROM fn_get_handler_tasks();`;
    const rows = await dbHelper.query(query, []);
    console.log("[handler-tasks::get] rows: ", rows);

    const resData = { handler_tasks: []};

    // parse results into handler_tasks
    rows.forEach(row => {
      console.log("[handler-tasks::get] row: ", row);
      const { study_id, main_image_dsid, tp_start, tp_end,
        sys_segref_dsid, sys_tp_ref, sys_tp_start, sys_tp_end,
        dias_segref_dsid, dias_tp_ref, dias_tp_start, dias_tp_end, module_status} = row;

      resData.handler_tasks.push({
        study_id: Number(study_id),
        study_config: {
          main_image_dsid: Number(main_image_dsid),
          tp_start: Number(tp_start),
          tp_end: Number(tp_end),
          sys_segref_dsid: Number(sys_segref_dsid),
          sys_tp_ref: Number(sys_tp_ref),
          sys_tp_start: Number(sys_tp_start),
          sys_tp_end: Number(sys_tp_end),
          dias_segref_dsid: Number(dias_segref_dsid),
          dias_tp_ref: Number(dias_tp_ref),
          dias_tp_start: Number(dias_tp_start),
          dias_tp_end: Number(dias_tp_end)
        },
        module_status: Number(module_status)
      });
    });

    res.status(200).json(resData);
  } catch(error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

export default router;
