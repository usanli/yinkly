const express = require('express');
const path = require('path');
const app = express();

const { Pool } = require('pg');

const pool = new Pool({
  host:     process.env.DB_HOST,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});


app.use(express.json());

// 1) serve your static UI
const front = path.join(__dirname, 'frontend');
app.use(express.static(front));
app.get('/', (req, res) => {
  res.sendFile(path.join(front, 'index.html'));
});

// 2) your API endpoint
app.post('/api/create', async (req, res) => {
  const { url: longUrl } = req.body;
  if (!longUrl) return res.status(400).json({ error: 'Missing url' });

  // Generate a short code (e.g. base62 of timestamp/random)
  const code = Math.random().toString(36).substring(2,8);

  try {
    await pool.query(
      'INSERT INTO urls(code,long_url) VALUES($1,$2)',
      [code, longUrl]
    );
    const shortUrl = `${process.env.REDIRECT_BASE_URL}/${code}`;
    res.json({ shortCode: code, shortUrl });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

app.listen(80, () => console.log('Yinkly admin listening on port 80'));
