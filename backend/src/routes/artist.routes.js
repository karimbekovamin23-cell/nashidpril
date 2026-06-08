const express = require('express');
const multer = require('multer');
const {
  getArtist,
  submitVerification,
  reviewVerification,
  getArtistNasheeds,
} = require('../controllers/artist.controller');
const { authenticate, requireAdmin } = require('../middleware/auth.middleware');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });

router.get('/:id', getArtist);
router.get('/:id/nasheeds', getArtistNasheeds);

router.post(
  '/verification',
  authenticate,
  upload.single('document'),
  submitVerification
);

// Admin: approve/reject artist
router.patch('/:id/verification', authenticate, requireAdmin, reviewVerification);

module.exports = router;
