require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const nasheedRoutes = require('./routes/nasheed.routes');
const quranRoutes = require('./routes/quran.routes');
const artistRoutes = require('./routes/artist.routes');
const statsRoutes = require('./routes/stats.routes');
const { errorHandler } = require('./middleware/error.middleware');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/nasheeds', nasheedRoutes);
app.use('/api/quran', quranRoutes);
app.use('/api/artists', artistRoutes);
app.use('/api/stats', statsRoutes);

app.get('/health', (req, res) => res.json({ status: 'ok', time: new Date() }));

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`NashidPril backend running on port ${PORT}`);
});

module.exports = app;
