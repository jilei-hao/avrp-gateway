import dotenv from 'dotenv';

dotenv.config();

console.log("[test_handler-tasks] start testing handler-tasks");

console.log("-- log in");

const gwUrl = `http://localhost:${process.env.PORT}`;

fetch (`${gwUrl}/login`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    username: process.env.TEST_USER_NAME,
    password: process.env.TEST_USER_PW
  })
}).then (response => {
  if (!response.ok) {
    throw new Error('Network response was not ok. Message: ' + response.statusText);
  }
  return response.json();
}).then (data => {
  console.log("-- login response: ", data);
  if (data.success !== true) {
    throw new Error('Login failed. error: ' + data.error);
  }

  const token = data.token;

  console.log("-- get handler tasks");

  fetch (`${gwUrl}/handler-tasks`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
   }).then (response => {
    if (!response.ok) {
      throw new Error('Network response was not ok. Message: ' + response.statusText);
    }
    return response.json();
   }).then (data => {
    console.log("-- handler tasks: ", data);
   })



}).catch (error => {
  console.error('Fetch error:', error);
});