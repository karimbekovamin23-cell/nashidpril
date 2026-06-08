const express = require('express');
const { googleLogin, selectRole, getMe } = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

// POST /api/auth/google  — обмен Google ID-токена на JWT
router.post('/google', googleLogin);

// POST /api/auth/role    — выбор роли при первой регистрации
router.post('/role', authenticate, selectRole);

// GET  /api/auth/me      — текущий пользователь
router.get('/me', authenticate, getMe);

module.exports = router;
