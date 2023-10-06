const { Pool } = require('pg');

class Database {
  constructor() {
    this.pool = new Pool({
      // Database configuration options
      user: 'dbusr_gateway',
      host: 'localhost',
      database: 'avrp',
      password: 'avrpdev',
      port: 5432,
    });
  }

  static getInstance() {
    if (!Database.instance) {
      Database.instance = new Database();
    }
    return Database.instance;
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

module.exports = Database;