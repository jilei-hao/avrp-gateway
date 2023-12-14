import express from 'express';
import cors from 'cors';

import userRoute from './routes/user.js';
import loginRoute from './routes/login.js';
import caseRoute from './routes/case.js';
import caseStudiesRoute from './routes/case_studies.js';

const app = express();

// Configure CORS middleware
const corsOptions = {
  origin: 'http://localhost:3030',
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true, // enable set cookie with CORS
  optionsSuccessStatus: 204,
};

app.use(cors(corsOptions));

app.use('/user', userRoute);
app.use('/login', loginRoute);
app.use('/case', caseRoute);
app.use('/case_studies', caseStudiesRoute);

// Start the Express server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
