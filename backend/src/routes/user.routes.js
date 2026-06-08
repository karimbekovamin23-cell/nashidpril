const express = require('express');
const multer = require('multer');
const { getProfile, updateProfile, getLikedNasheeds, getHistory, followArtist, unfollowArtist } = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

router.get('/:id', getProfile);
router.patch('/me', authenticate, upload.single('avatar'), updateProfile);
router.get('/me/liked', authenticate, getLikedNasheeds);
router.get('/me/history', authenticate, getHistory);
router.post('/:id/follow', authenticate, followArtist);
router.delete('/:id/follow', authenticate, unfollowArtist);

module.exports = router;
