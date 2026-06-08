const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const getSurahs = async (req, res, next) => {
  try {
    const surahs = await prisma.quranSurah.findMany({ orderBy: { id: 'asc' } });
    res.json({ surahs });
  } catch (err) {
    next(err);
  }
};

const getSurah = async (req, res, next) => {
  try {
    const surah = await prisma.quranSurah.findUnique({ where: { id: Number(req.params.id) } });
    if (!surah) return res.status(404).json({ message: 'Surah not found' });
    res.json({ surah });
  } catch (err) {
    next(err);
  }
};

module.exports = { getSurahs, getSurah };
