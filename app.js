// app.js
const express = require('express');
const cors = require('cors');

const userRoute = require('./routes/user');
const loginRoute = require('./routes/login');
const caseRoute = require('./routes/case');
const caseStudiesRoute = require('./routes/case_studies')


const app = express();

// Configure CORS middleware
const corsOptions = {
  origin: 'http://localhost:3030', // Replace with your allowed origin(s)
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true, // enable set cookie with CORS
  optionsSuccessStatus: 204,
};

app.use(cors(corsOptions));

app.use('/user', userRoute);
app.use('/login', loginRoute);
app.use('/case', caseRoute);
app.use('/case_studies', caseStudiesRoute)

// Start the Express server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
