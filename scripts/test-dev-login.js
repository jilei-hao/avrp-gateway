import axios from "axios";

const url = "http://localhost:6060";

const jsonData = {
  "username": `avrpdev`,
  "password": `avrp@dev`
};

const reqConfig = {
  "headers": {
    "contentType": "application/json",
  }
};

let token = "";

// test login in
axios.post(`${url}/login`, jsonData, reqConfig)
.then((res) => {
  token = res.data.token;
  console.log("Dev user logged in. Token: ", token);
})