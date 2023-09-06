const axios = require('axios');

const url = "http://localhost:6060";

const testUserTag = 100 + Math.floor(Math.random() * 899);

const jsonData = {
  "un": `TestUser${testUserTag}`,
  "pw": `TestUser${testUserTag}Dev`
};

const reqConfig = {
  "headers": {
    "contentType": "application/json",
  }
};

let token = "";

axios.post(`${url}/user`, jsonData, reqConfig)
.then((res) => {
  console.log("Response: ", res.data);
  token = res.data.token;
})
.catch((err) => {
  console.error("Error: ", err);
});


// // test the protected route
// const tokenConfig = {
//   "headers": {
//     "token": token,
//   }
// };

// axios.get(`${url}/protected`, jsonData, tokenConfig)
// .then((res) => {
//   console.log("Reponse: ", res.data);
// })