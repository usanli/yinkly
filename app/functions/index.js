// File: index.js

const { Pool } = require('pg');

// Configure the connection pool
const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl:      { rejectUnauthorized: false },
});

exports.yinklyRedirect = async (req, res) => {
  // debug
  console.log('*** yinklyRedirect invoked with path =', req.path);
  console.log('*** Using env:', {
    DB_HOST: process.env.DB_HOST,
    DB_PORT: process.env.DB_PORT,
    DB_USER: process.env.DB_USER,
    DB_NAME: process.env.DB_NAME,
  });

  try {
    const parts = req.path.split('/');
    const code  = parts[parts.length - 1];
    console.log('*** Looking up shortcode =', code);

    const { rows } = await pool.query(
      'SELECT url FROM urls WHERE shortcode = $1',
      [code]
    );

    console.log('*** Query returned rows =', rows);

    if (rows.length === 0) {
      return res.status(404).send('Short link not found');
    }
    return res.redirect(302, rows[0].url);

  } catch (err) {
    console.error('Database error in yinklyRedirect:', err.message);
    console.error(err);
    return res.status(500).send('Internal server error');
  }
};
