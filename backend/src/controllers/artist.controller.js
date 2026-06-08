const { PrismaClient } = require('@prisma/client');
const { uploadFile } = require('../services/s3.service');

const prisma = new PrismaClient();

const getArtist = async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.id },
      select: {
        id: true, name: true, avatarUrl: true, role: true,
        artistProfile: true,
        _count: { select: { nasheeds: true, followers: true } },
      },
    });
    if (!user) return res.status(404).json({ message: 'Artist not found' });
    res.json({ artist: user });
  } catch (err) {
    next(err);
  }
};

const getArtistNasheeds = async (req, res, next) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const nasheeds = await prisma.nasheed.findMany({
      where: { artistId: req.params.id, isPublished: true },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: Number(limit),
    });
    res.json({ nasheeds });
  } catch (err) {
    next(err);
  }
};

const submitVerification = async (req, res, next) => {
  try {
    const { bio } = req.body;
    let docUrl = null;

    if (req.file) {
      docUrl = await uploadFile(req.file.buffer, req.file.mimetype, 'verification-docs');
    }

    const profile = await prisma.artistProfile.upsert({
      where: { userId: req.user.id },
      update: {
        bio,
        verificationDocUrl: docUrl,
        verificationStatus: 'PENDING',
      },
      create: {
        userId: req.user.id,
        bio,
        verificationDocUrl: docUrl,
      },
    });

    res.json({ profile });
  } catch (err) {
    next(err);
  }
};

const reviewVerification = async (req, res, next) => {
  try {
    const { status, note } = req.body;
    if (!['APPROVED', 'REJECTED'].includes(status)) {
      return res.status(400).json({ message: 'Status must be APPROVED or REJECTED' });
    }

    const profile = await prisma.artistProfile.update({
      where: { userId: req.params.id },
      data: { verificationStatus: status, verificationNote: note },
    });

    res.json({ profile });
  } catch (err) {
    next(err);
  }
};

module.exports = { getArtist, getArtistNasheeds, submitVerification, reviewVerification };
