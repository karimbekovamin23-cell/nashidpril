const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const authenticate = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await prisma.user.findUnique({ where: { id: decoded.userId } });
    if (!user || !user.isActive) {
      return res.status(401).json({ message: 'Invalid token' });
    }
    req.user = user;
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

const requireArtist = async (req, res, next) => {
  if (req.user.role !== 'ARTIST' && req.user.role !== 'ADMIN') {
    return res.status(403).json({ message: 'Artist access required' });
  }
  const artistProfile = await prisma.artistProfile.findUnique({
    where: { userId: req.user.id },
  });
  if (!artistProfile || artistProfile.verificationStatus !== 'APPROVED') {
    return res.status(403).json({ message: 'Artist verification required' });
  }
  req.artistProfile = artistProfile;
  next();
};

const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'ADMIN') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  next();
};

module.exports = { authenticate, requireArtist, requireAdmin };
