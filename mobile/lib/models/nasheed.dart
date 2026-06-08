class Nasheed {
  final String id;
  final String artistId;
  final String title;
  final String? description;
  final String audioUrl;
  final String? coverUrl;
  final int duration; // seconds
  final int playsCount;
  final int likesCount;
  final bool isPublished;
  final DateTime createdAt;
  final NasheedArtist? artist;
  bool isLiked;

  Nasheed({
    required this.id,
    required this.artistId,
    required this.title,
    this.description,
    required this.audioUrl,
    this.coverUrl,
    required this.duration,
    required this.playsCount,
    required this.likesCount,
    required this.isPublished,
    required this.createdAt,
    this.artist,
    this.isLiked = false,
  });

  String get durationFormatted {
    final m = duration ~/ 60;
    final s = duration % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  factory Nasheed.fromJson(Map<String, dynamic> json) => Nasheed(
        id: json['id'],
        artistId: json['artistId'],
        title: json['title'],
        description: json['description'],
        audioUrl: json['audioUrl'],
        coverUrl: json['coverUrl'],
        duration: json['duration'] ?? 0,
        playsCount: json['playsCount'] ?? 0,
        likesCount: json['likesCount'] ?? 0,
        isPublished: json['isPublished'] ?? true,
        createdAt: DateTime.parse(json['createdAt']),
        artist: json['artist'] != null ? NasheedArtist.fromJson(json['artist']) : null,
        isLiked: json['isLiked'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'artistId': artistId,
        'title': title,
        'description': description,
        'audioUrl': audioUrl,
        'coverUrl': coverUrl,
        'duration': duration,
        'playsCount': playsCount,
        'likesCount': likesCount,
        'isPublished': isPublished,
        'createdAt': createdAt.toIso8601String(),
      };

  Nasheed copyWith({bool? isLiked}) => Nasheed(
        id: id,
        artistId: artistId,
        title: title,
        description: description,
        audioUrl: audioUrl,
        coverUrl: coverUrl,
        duration: duration,
        playsCount: playsCount,
        likesCount: likesCount + (isLiked != null && isLiked != this.isLiked ? (isLiked ? 1 : -1) : 0),
        isPublished: isPublished,
        createdAt: createdAt,
        artist: artist,
        isLiked: isLiked ?? this.isLiked,
      );
}

class NasheedArtist {
  final String id;
  final String name;
  final String? avatarUrl;

  const NasheedArtist({required this.id, required this.name, this.avatarUrl});

  factory NasheedArtist.fromJson(Map<String, dynamic> json) => NasheedArtist(
        id: json['id'],
        name: json['name'],
        avatarUrl: json['avatarUrl'],
      );
}
