class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role; // LISTENER, ARTIST, ADMIN
  final ArtistProfile? artistProfile;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.artistProfile,
  });

  bool get isArtist => role == 'ARTIST';
  bool get isAdmin => role == 'ADMIN';
  bool get isVerifiedArtist =>
      isArtist && artistProfile?.verificationStatus == 'APPROVED';

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        avatarUrl: json['avatarUrl'],
        role: json['role'] ?? 'LISTENER',
        artistProfile: json['artistProfile'] != null
            ? ArtistProfile.fromJson(json['artistProfile'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl,
        'role': role,
        'artistProfile': artistProfile?.toJson(),
      };
}

class ArtistProfile {
  final String id;
  final String userId;
  final String? bio;
  final String verificationStatus; // PENDING, APPROVED, REJECTED
  final int totalPlays;

  const ArtistProfile({
    required this.id,
    required this.userId,
    this.bio,
    required this.verificationStatus,
    required this.totalPlays,
  });

  factory ArtistProfile.fromJson(Map<String, dynamic> json) => ArtistProfile(
        id: json['id'],
        userId: json['userId'],
        bio: json['bio'],
        verificationStatus: json['verificationStatus'] ?? 'PENDING',
        totalPlays: json['totalPlays'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'bio': bio,
        'verificationStatus': verificationStatus,
        'totalPlays': totalPlays,
      };
}
