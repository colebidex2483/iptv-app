// server.js

const express = require('express');
const cors = require('cors');

const app = express();

// ✅ Parse JSON before any routes
app.use(express.json());

// ✅ Enable CORS (optional but useful for frontend apps)
app.use(cors());

// ✅ Test route (optional)
app.get('/ping', (req, res) => {
  console.log('[server] /ping hit');
  res.json({ message: 'pong' });
});

// ✅ Mount routes AFTER middlewares
const adminRoutes = require('./routes/admin');
app.use('/api/admin', adminRoutes);

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
