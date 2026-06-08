const express = require('express');
const multer = require('multer');
const {
  getNasheeds,
  getNasheed,
  uploadNasheed,
  deleteNasheed,
  likeNasheed,
  unlikeNasheed,
  recordPlay,
  searchNasheeds,
} = require('../controllers/nasheed.controller');
const { authenticate, requireArtist } = require('../middleware/auth.middleware');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 100 * 1024 * 1024 } });

// Public
router.get('/', getNasheeds);
router.get('/search', searchNasheeds);
router.get('/:id', getNasheed);

// Authenticated
router.post('/:id/play', authenticate, recordPlay);
router.post('/:id/like', authenticate, likeNasheed);
router.delete('/:id/like', authenticate, unlikeNasheed);

// Artists only
router.post(
  '/',
  authenticate,
  requireArtist,
  upload.fields([{ name: 'audio', maxCount: 1 }, { name: 'cover', maxCount: 1 }]),
  uploadNasheed
);
router.delete('/:id', authenticate, requireArtist, deleteNasheed);

module.exports = router;
