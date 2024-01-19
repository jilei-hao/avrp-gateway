import dotenv from 'dotenv';
import pkg from 'pg';
const { Pool } = pkg;

dotenv.config();

export class DBHelper {
  constructor() {
    this.pool = new Pool({
      // DBHelper configuration options
      user: process.env.DB_USER || 'avrpdev',
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 6061,
      database: process.env.DB_NAME || 'avrpdb',
      password: process.env.DB_PASSWORD || 'avrpdev',
    });
  }

  static getInstance() {
    if (!DBHelper.instance) {
      DBHelper.instance = new DBHelper();
    }
    return DBHelper.instance;
  }

  async query(sql, params) {
    const client = await this.pool.connect();
    try {
      const result = await client.query(sql, params);
      return result.rows;
    } finally {
      client.release();
    }
  }
}

export async function db_GetConfig(studyId) {
  const db = DBHelper.getInstance();
  console.log("[db_GetConfig] ", studyId);

  // query the database
  const query = `SELECT * FROM fn_get_study_config($1);`;
  const rows = await db.query(query, [studyId]);

  console.log("[db_GetConfig] rows: ", rows[0]);

  if (rows.length !== 0) {
    const { 
      study_config_id, study_id, image_4d_id, modality, tp_start, tp_end,
      reference_seg_sys_id, tp_ref_sys, tp_start_sys, tp_end_sys,
      reference_seg_dias_id, tp_ref_dias, tp_start_dias, tp_end_dias
    } = rows[0];

    return {
      found: true,
      config: {
        studyConfigId: study_config_id,
        studyId: study_id,
        image4dId: image_4d_id,
        modality: modality,
        tpStart: tp_start,
        tpEnd: tp_end,
        referenceSegSysId: reference_seg_sys_id,
        tpRefSys: tp_ref_sys,
        tpStartSys: tp_start_sys,
        tpEndSys: tp_end_sys,
        referenceSegDiasId: reference_seg_dias_id,
        tpRefDias: tp_ref_dias,
        tpStartDias: tp_start_dias,
        tpEndDias: tp_end_dias
      }
    };
  } else {
    return {
      found: false,
      config: {}
    };
  }
}
