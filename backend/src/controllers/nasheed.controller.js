const { PrismaClient } = require('@prisma/client');
const { uploadFile, deleteFile } = require('../services/s3.service');

const prisma = new PrismaClient();

const getNasheeds = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, artistId, sort = 'newest' } = req.query;
    const skip = (page - 1) * limit;

    const where = { isPublished: true };
    if (artistId) where.artistId = artistId;

    const orderBy =
      sort === 'popular' ? { playsCount: 'desc' } :
      sort === 'liked'   ? { likesCount: 'desc' } :
                           { createdAt: 'desc' };

    const [nasheeds, total] = await Promise.all([
      prisma.nasheed.findMany({
        where,
        include: { artist: { select: { id: true, name: true, avatarUrl: true } } },
        orderBy,
        skip: Number(skip),
        take: Number(limit),
      }),
      prisma.nasheed.count({ where }),
    ]);

    res.json({ nasheeds, total, page: Number(page), limit: Number(limit) });
  } catch (err) {
    next(err);
  }
};

const getNasheed = async (req, res, next) => {
  try {
    const nasheed = await prisma.nasheed.findUnique({
      where: { id: req.params.id },
      include: { artist: { select: { id: true, name: true, avatarUrl: true } } },
    });
    if (!nasheed) return res.status(404).json({ message: 'Nasheed not found' });
    res.json({ nasheed });
  } catch (err) {
    next(err);
  }
};

const searchNasheeds = async (req, res, next) => {
  try {
    const { q = '', page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const nasheeds = await prisma.nasheed.findMany({
      where: {
        isPublished: true,
        OR: [
          { title: { contains: q, mode: 'insensitive' } },
          { description: { contains: q, mode: 'insensitive' } },
          { artist: { name: { contains: q, mode: 'insensitive' } } },
        ],
      },
      include: { artist: { select: { id: true, name: true, avatarUrl: true } } },
      skip: Number(skip),
      take: Number(limit),
    });

    res.json({ nasheeds });
  } catch (err) {
    next(err);
  }
};

const uploadNasheed = async (req, res, next) => {
  try {
    const { title, description } = req.body;
    if (!title) return res.status(400).json({ message: 'Title required' });

    const audioFile = req.files?.audio?.[0];
    const coverFile = req.files?.cover?.[0];

    if (!audioFile) return res.status(400).json({ message: 'Audio file required' });

    const [audioUrl, coverUrl] = await Promise.all([
      uploadFile(audioFile.buffer, audioFile.mimetype, 'nasheeds/audio'),
      coverFile ? uploadFile(coverFile.buffer, coverFile.mimetype, 'nasheeds/covers') : null,
    ]);

    const nasheed = await prisma.nasheed.create({
      data: {
        artistId: req.user.id,
        title,
        description,
        audioUrl,
        coverUrl,
        duration: Number(req.body.duration) || 0,
      },
      include: { artist: { select: { id: true, name: true, avatarUrl: true } } },
    });

    res.status(201).json({ nasheed });
  } catch (err) {
    next(err);
  }
};

const deleteNasheed = async (req, res, next) => {
  try {
    const nasheed = await prisma.nasheed.findUnique({ where: { id: req.params.id } });
    if (!nasheed) return res.status(404).json({ message: 'Nasheed not found' });
    if (nasheed.artistId !== req.user.id && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    await Promise.all([
      deleteFile(nasheed.audioUrl),
      nasheed.coverUrl ? deleteFile(nasheed.coverUrl) : null,
    ]);

    await prisma.nasheed.delete({ where: { id: req.params.id } });
    res.json({ message: 'Deleted' });
  } catch (err) {
    next(err);
  }
};

const likeNasheed = async (req, res, next) => {
  try {
    await prisma.$transaction([
      prisma.like.create({ data: { userId: req.user.id, nasheedId: req.params.id } }),
      prisma.nasheed.update({ where: { id: req.params.id }, data: { likesCount: { increment: 1 } } }),
    ]);
    res.json({ liked: true });
  } catch {
    res.json({ liked: false });
  }
};

const unlikeNasheed = async (req, res, next) => {
  try {
    await prisma.$transaction([
      prisma.like.delete({ where: { userId_nasheedId: { userId: req.user.id, nasheedId: req.params.id } } }),
      prisma.nasheed.update({ where: { id: req.params.id }, data: { likesCount: { decrement: 1 } } }),
    ]);
    res.json({ liked: false });
  } catch (err) {
    next(err);
  }
};

const recordPlay = async (req, res, next) => {
  try {
    const { duration = 0 } = req.body;
    await prisma.$transaction([
      prisma.playHistory.create({
        data: { userId: req.user.id, nasheedId: req.params.id, duration: Number(duration) },
      }),
      prisma.nasheed.update({
        where: { id: req.params.id },
        data: { playsCount: { increment: 1 } },
      }),
    ]);
    res.json({ recorded: true });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getNasheeds, getNasheed, uploadNasheed, deleteNasheed,
  likeNasheed, unlikeNasheed, recordPlay, searchNasheeds,
};
