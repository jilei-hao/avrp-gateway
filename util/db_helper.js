import pkg from 'pg';
const { Pool } = pkg;

class DBHelper {
  constructor() {
    this.pool = new Pool({
      // DBHelper configuration options
      user: 'dbusr_gateway',
      host: 'localhost',
      DBHelper: 'avrp',
      password: 'avrpdev',
      port: 5432,
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
