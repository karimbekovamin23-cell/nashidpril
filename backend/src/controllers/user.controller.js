const { PrismaClient } = require('@prisma/client');
const { uploadFile } = require('../services/s3.service');

const prisma = new PrismaClient();

const getProfile = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.id },
      select: {
        id: true, name: true, avatarUrl: true, role: true, createdAt: true,
        artistProfile: true,
        _count: { select: { nasheeds: true, followers: true, following: true } },
      },
    });
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ user });
  } catch (err) {
    next(err);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const { name, bio } = req.body;
    let avatarUrl;

    if (req.file) {
      avatarUrl = await uploadFile(req.file.buffer, req.file.mimetype, 'avatars');
    }

    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: { ...(name && { name }), ...(avatarUrl && { avatarUrl }) },
    });

    if (bio !== undefined && req.user.role === 'ARTIST') {
      await prisma.artistProfile.update({ where: { userId: req.user.id }, data: { bio } });
    }

    res.json({ user });
  } catch (err) {
    next(err);
  }
};

const getLikedNasheeds = async (req, res, next) => {
  try {
    const likes = await prisma.like.findMany({
      where: { userId: req.user.id },
      include: { nasheed: { include: { artist: { select: { id: true, name: true, avatarUrl: true } } } } },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ nasheeds: likes.map((l) => l.nasheed) });
  } catch (err) {
    next(err);
  }
};

const getHistory = async (req, res, next) => {
  try {
    const { limit = 50 } = req.query;
    const history = await prisma.playHistory.findMany({
      where: { userId: req.user.id },
      include: { nasheed: { include: { artist: { select: { id: true, name: true, avatarUrl: true } } } } },
      orderBy: { playedAt: 'desc' },
      take: Number(limit),
    });
    res.json({ history });
  } catch (err) {
    next(err);
  }
};

const followArtist = async (req, res, next) => {
  try {
    await prisma.follow.create({ data: { followerId: req.user.id, followedId: req.params.id } });
    res.json({ following: true });
  } catch {
    res.json({ following: false });
  }
};

const unfollowArtist = async (req, res, next) => {
  try {
    await prisma.follow.delete({
      where: { followerId_followedId: { followerId: req.user.id, followedId: req.params.id } },
    });
    res.json({ following: false });
  } catch (err) {
    next(err);
  }
};

module.exports = { getProfile, updateProfile, getLikedNasheeds, getHistory, followArtist, unfollowArtist };
