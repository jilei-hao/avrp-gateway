// app.js
const express = require('express');
const userRoute = require('./routes/user');
const loginRoute = require('./routes/login');


const app = express();

app.use('/user', userRoute);
app.use('/login', loginRoute);

// Start the Express server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
