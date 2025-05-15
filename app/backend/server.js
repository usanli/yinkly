const express = require('express');
const path = require('path');
const app = express();

app.use(express.json());

// 1) serve your static UI
const front = path.join(__dirname, 'frontend');
app.use(express.static(front));
app.get('/', (req, res) => {
  res.sendFile(path.join(front, 'index.html'));
});

// 2) your API endpoint
app.post('/api/create', (req, res) => {
  // TODO: generate code, write to DB
  const code = 'abc123';
  const redirectBase = process.env.REDIRECT_BASE_URL;
  res.json({ shortCode: code, shortUrl: `${redirectBase}/${code}` });
});

app.listen(80, () => console.log('Yinkly admin listening on port 80'));
