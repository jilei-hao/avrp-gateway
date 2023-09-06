const { Pool } =  require('pg');

const pool = new Pool({
  user: 'dbusr_gateway',
  host: 'localhost',
  database: 'avrp',
  password: 'avrpdev',
  port: 5432
});

const query = 'SELECT fn_GetUserInfo($1);';
pool.query(query, ['Gateway'])
.then((result) => {
  console.log(result);
});