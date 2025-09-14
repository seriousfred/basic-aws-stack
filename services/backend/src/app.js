require('dotenv').config();

const AWS = require('aws-sdk');
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

AWS.config.update({
  region: process.env.AWS_REGION || 'us-east-1'
});

const { Pool } = require('pg');

// create postgres connection pool
const pool = new Pool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'backend',
  user: process.env.DB_USERNAME || 'backend',
  password: process.env.DB_PASSWORD || 'backend'
});


// health check
app.get('/status', (req, res) => {
  console.log('Health check received');
  res.send({
    message: 'Backend is up!'
  })
})


// db health check
app.get('/status/database', async (req, res, next) => {

  try {

    console.log('Database health check received');

    const result = await pool.query('SELECT NOW()');
    res.status(200).json({ time: result.rows[0].now });

  } catch (err) {
    err.status = 500
    next(err)
  }

})

// create file in S3
app.get('/s3/create', (req, res) => {

  const s3 = new AWS.S3();

  s3.putObject({
    Bucket: process.env.S3_BUCKET,
    Key: `status-${Date.now()}.json`,
    Body: JSON.stringify({ message: `Backend was up at ${new Date().toISOString()}`}),
    ContentType: 'application/json'
  }, (err, data) => {

    if (err) {
      console.error(`Error creating S3 object: ${err}`);
      return res.status(500).send({ error: 'Error creating S3 object' });
    }

    console.log('S3 object created successfully');
    res.send({ message: 'S3 object created successfully', data });

  });

})

// 404
app.use(function (req, res, next) {
  var err = new Error('Not Found')
  err.status = 404
  next(err)
})

// error handler
app.use(function (err, req, res, next) {
  console.error(`Error catched! ${err}`)

  let error = {
      code: err.status,
      description: err.message
  }

  res.status(error.code).send(error)
})

app.listen(port)

console.log('Server started on port ' + port)