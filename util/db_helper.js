import dotenv from 'dotenv';
import pkg from 'pg';
const { Pool } = pkg;

dotenv.config();

class DBHelper {
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

export default DBHelper;
