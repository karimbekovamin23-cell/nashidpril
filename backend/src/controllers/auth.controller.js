const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const signToken = (userId) =>
  jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '30d' });

const googleLogin = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ message: 'idToken required' });

    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    const { sub: googleId, email, name, picture } = payload;

    let user = await prisma.user.findUnique({ where: { googleId } });
    const isNew = !user;

    if (!user) {
      user = await prisma.user.create({
        data: { googleId, email, name, avatarUrl: picture },
      });
    }

    const token = signToken(user.id);
    res.json({ token, user, isNew });
  } catch (err) {
    next(err);
  }
};

const selectRole = async (req, res, next) => {
  try {
    const { role } = req.body;
    if (!['LISTENER', 'ARTIST'].includes(role)) {
      return res.status(400).json({ message: 'Role must be LISTENER or ARTIST' });
    }

    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: { role },
    });

    if (role === 'ARTIST') {
      await prisma.artistProfile.upsert({
        where: { userId: user.id },
        update: {},
        create: { userId: user.id },
      });
    }

    res.json({ user });
  } catch (err) {
    next(err);
  }
};

const getMe = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { artistProfile: true },
    });
    res.json({ user });
  } catch (err) {
    next(err);
  }
};

module.exports = { googleLogin, selectRole, getMe };
