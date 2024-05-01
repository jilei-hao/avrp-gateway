import express from 'express';
import cors from 'cors';

import userRoute from './routes/user.js';
import loginRoute from './routes/login.js';
import caseRoute from './routes/case.js';
import caseStudiesRoute from './routes/case-studies.js';
import caseStudiesVSRoute from './routes/case-studies-vs.js';
import studyRoute from './routes/study.js';
import studyConfigRoute from './routes/study-config.js';
import studyDataHeadersVSRoute from './routes/study-data-headers-vs.js';
import handlerTasksRoute from './routes/handler-tasks.js';

const app = express();

// Configure CORS middleware
const corsOptions = {
  origin: ['http://localhost:3030', 'http://localhost:5173'],
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true, // enable set cookie with CORS
  optionsSuccessStatus: 204,
};

// Configure CORS middleware for any origin
const corsOptionsAnyOrigin = {
  origin: '*',
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true, // enable set cookie with CORS
  optionsSuccessStatus: 204,
};

app.use(cors(corsOptions));

app.use('/user', userRoute);
app.use('/login', cors(corsOptionsAnyOrigin), loginRoute);
app.use('/case', caseRoute);
app.use('/case_studies', caseStudiesRoute);
app.use('/case-studies-vs', caseStudiesVSRoute);
app.use('/study', studyRoute);
app.use('/study_config', studyConfigRoute);
app.use('/study-data-headers-vs', studyDataHeadersVSRoute);
app.use('/handler-tasks', handlerTasksRoute);

// Start the Express server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
