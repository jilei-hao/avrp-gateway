// test for the study-config route
import 'dotenv';
import fetch from 'node-fetch';

dotenv.config();

async function test_head() {
  const gatewayURL = `http://localhost:${process.env.PORT}`;

  fetch (`${gatewayURL}/study_config`, {
    method: 'HEAD',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.TEST_TOKEN}`
    }
  })
}