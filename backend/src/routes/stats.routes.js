const express = require('express');
const { getArtistStats, getNasheedStats } = require('../controllers/stats.controller');
const { authenticate, requireArtist } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/artist', authenticate, requireArtist, getArtistStats);
router.get('/nasheed/:id', authenticate, getNasheedStats);

module.exports = router;
