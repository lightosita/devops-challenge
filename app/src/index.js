const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint — critical for ECS/ALB
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0'
  });
});

app.get('/', (req, res) => {
  res.status(200).json({
    message: 'DevOps Challenge API',
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime()
  });
});

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

// Graceful shutdown — production best practice
process.on('SIGTERM', () => {
  server.close(() => {
    console.log('Process terminated');
    process.exit(0);
  });
});

module.exports = app;