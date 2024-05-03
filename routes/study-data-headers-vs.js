
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
    const { study_id } = req.query;

    console.log("[study-data-headers-vs::get] ", user, study_id);

    // query the database
    const query = `SELECT * FROM fn_vs_get_study_data_headers($1);`;
    const rows = await dbHelper.query(query, [study_id]);

    const study_data_headers = [];

    rows.forEach(row => {
      console.log("[study-data-headers-vs::get] row: ", row);
      const {data_group_name, time_point,
          primary_index, primary_index_name, primary_index_desc,
          secondary_index, secondary_index_name, secondary_index_desc,
          data_server_id
        } = row;

      let time_point_data = study_data_headers.find(header => header.time_point === time_point);

      if (!time_point_data) {
        time_point_data = {
          time_point: time_point,
          data_groups: []
        }
        study_data_headers.push(time_point_data);
      }

      let data_group = time_point_data.data_groups.find(group => group.data_group_name === data_group_name);

      if (!data_group) {
        data_group = {
          data_group_name: data_group_name,
          data: []
        }
        time_point_data.data_groups.push(data_group);
      }

      data_group.data.push({
        primary_index: primary_index,
        primary_index_name: primary_index_name,
        primary_index_desc: primary_index_desc,
        secondary_index: secondary_index,
        secondary_index_name: secondary_index_name,
        secondary_index_desc: secondary_index_desc,
        data_server_id: data_server_id
      });
    });

    console.log("[study-data-headers-vs::get] study-data-headers: ", study_data_headers);

    res.status(200).json(study_data_headers);
  } catch(error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
})

export default router;
