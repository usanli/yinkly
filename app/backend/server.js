const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

const {
  DB_HOST,
  DB_PORT,
  DB_USER,
  DB_PASSWORD,
  DB_NAME,
  REDIRECT_BASE_URL,
  PORT
} = process.env;

if (!DB_HOST || !DB_USER || !DB_PASSWORD || !DB_NAME || !REDIRECT_BASE_URL) {
  console.error('Missing one of: DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, REDIRECT_BASE_URL');
  process.exit(1);
}

const pool = new Pool({
  host: DB_HOST,
  port: DB_PORT || 5432,
  user: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
});

const app = express();
app.use(bodyParser.json());

// serve static index.html + JS/CSS under `/`
app.use(express.static(path.join(__dirname, 'frontend')));

// create endpoint
app.post('/create', async (req, res) => {
  const { url } = req.body;
  if (!url) return res.status(400).json({ error: 'url is required' });

  // generate 6-char code
  const code = Math.random().toString(36).substr(2, 6);

  try {
    await pool.query(
      'INSERT INTO urls (shortcode, url) VALUES ($1, $2) RETURNING shortcode',
      [code, url]
    );    
    return res.json({
      shortUrl: `${REDIRECT_BASE_URL}/${code}`
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'db error' });
  }
});

// everything else 404
app.use((_, res) => res.status(404).send('Not found'));

const port = PORT || 8080;
app.listen(port, () => {
  console.log(`Yinkly admin listening on port ${port}`);
});
