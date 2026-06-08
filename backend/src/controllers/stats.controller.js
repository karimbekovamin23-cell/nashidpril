const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const getArtistStats = async (req, res, next) => {
  try {
    const nasheedsStats = await prisma.nasheed.findMany({
      where: { artistId: req.user.id },
      select: { id: true, title: true, playsCount: true, likesCount: true, createdAt: true },
      orderBy: { playsCount: 'desc' },
    });

    const totalPlays = nasheedsStats.reduce((sum, n) => sum + Number(n.playsCount), 0);
    const totalLikes = nasheedsStats.reduce((sum, n) => sum + n.likesCount, 0);
    const followersCount = await prisma.follow.count({ where: { followedId: req.user.id } });

    // Plays per day last 30 days
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const recentPlays = await prisma.playHistory.groupBy({
      by: ['nasheedId'],
      where: {
        nasheed: { artistId: req.user.id },
        playedAt: { gte: thirtyDaysAgo },
      },
      _count: { id: true },
    });

    res.json({ totalPlays, totalLikes, followersCount, nasheedsStats, recentPlays });
  } catch (err) {
    next(err);
  }
};

const getNasheedStats = async (req, res, next) => {
  try {
    const nasheed = await prisma.nasheed.findUnique({
      where: { id: req.params.id },
      select: { id: true, title: true, playsCount: true, likesCount: true, artistId: true },
    });
    if (!nasheed) return res.status(404).json({ message: 'Nasheed not found' });
    if (nasheed.artistId !== req.user.id && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const dailyPlays = await prisma.playHistory.findMany({
      where: { nasheedId: req.params.id, playedAt: { gte: thirtyDaysAgo } },
      orderBy: { playedAt: 'asc' },
    });

    res.json({ nasheed, dailyPlays });
  } catch (err) {
    next(err);
  }
};

module.exports = { getArtistStats, getNasheedStats };
