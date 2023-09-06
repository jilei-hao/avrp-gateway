const { Pool } =  require('pg');

const pool = new Pool({
  user: 'dbusr_gateway',
  host: 'localhost',
  database: 'avrp',
  password: 'avrpdev',
  port: 5432
});

const query = 'SELECT fn_CreateUser($1, $2, $3, $4);';
pool.query(query, ['TestUser2', 'TestUser2Dev', 'EndUser', 'Gateway'])
.then((result) => {
  console.log(result);
});