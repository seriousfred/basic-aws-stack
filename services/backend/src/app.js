require('dotenv').config();

const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

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
  res.send({
    message: 'Backend is up!'
  })
})


// db health check
app.get('/status/database', async (req, res, next) => {

  try {

    const result = await pool.query('SELECT NOW()');
    res.status(200).json({ time: result.rows[0].now });

  } catch (err) {
    err.status = 500
    next(err)
  }

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