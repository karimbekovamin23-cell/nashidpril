import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nasheed.dart';
import '../services/api_service.dart';

final nasheedsProvider = FutureProvider.family<List<Nasheed>, String>((ref, sort) async {
  return ApiService().getNasheeds(sort: sort);
});

final searchProvider = FutureProvider.family<List<Nasheed>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return ApiService().searchNasheeds(query);
});

final likedNasheedsProvider = FutureProvider<List<Nasheed>>((ref) async {
  return ApiService().getLikedNasheeds();
});

final artistNasheedsProvider = FutureProvider.family<List<Nasheed>, String>((ref, artistId) async {
  return ApiService().getArtistNasheeds(artistId);
});
