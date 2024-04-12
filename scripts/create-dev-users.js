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

axios.post(`${url}/user`, jsonData, reqConfig)
.then((res) => {
  console.log("Response: ", res.data);
  token = res.data.token;
  console.log("Dev user created. Token: ", token);
})
.catch((err) => {
  console.error("Error: ", err);
});