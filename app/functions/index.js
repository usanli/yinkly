// File: index.js

const { Pool } = require('pg');

// Configure the connection pool from environment variables
const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl:      { rejectUnauthorized: false }
});

/**
 * HTTP function handler.
 * Entry point: yinklyRedirect
 * Trigger URL: https://.../yinkly-redirect/:shortCode
 */
exports.yinklyRedirect = async (req, res) => {
  // Get the last segment of the path as our code
  const parts = req.path.split('/');
  const code  = parts[parts.length - 1];

  try {
    const { rows } = await pool.query(
      'SELECT long_url FROM public.urls WHERE code = $1',
      [code]
    );

    if (rows.length === 0) {
      return res.status(404).send('Short link not found');
    }

    // redirect to the long_url column
    return res.redirect(302, rows[0].long_url);


    // Redirect the client to the original URL
    return res.redirect(302, rows[0].original_url);
  } catch (err) {
    console.error('Database error in yinklyRedirect:', err);
    return res.status(500).send('Internal server error');
  }
};
