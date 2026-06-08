class QuranSurah {
  final int id;
  final String nameArabic;
  final String nameTransliteration;
  final String nameTranslation;
  final int versesCount;
  final String revelationType;
  final String? audioUrl;

  const QuranSurah({
    required this.id,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.nameTranslation,
    required this.versesCount,
    required this.revelationType,
    this.audioUrl,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) => QuranSurah(
        id: json['id'],
        nameArabic: json['nameArabic'],
        nameTransliteration: json['nameTransliteration'],
        nameTranslation: json['nameTranslation'],
        versesCount: json['versesCount'],
        revelationType: json['revelationType'],
        audioUrl: json['audioUrl'],
      );
}
