const express = require('express');
const { getSurahs, getSurah } = require('../controllers/quran.controller');

const router = express.Router();

router.get('/', getSurahs);
router.get('/:id', getSurah);

module.exports = router;
