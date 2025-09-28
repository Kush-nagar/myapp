// lib/services/places_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Small typed results returned by the wrapper
class PlaceSummary {
  final String placeId;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final double? rating;
  final int? userRatingsTotal;
  final List<String> types;
  final String? icon;
  final String? photoReference;

  PlaceSummary({
    required this.placeId,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.rating,
    this.userRatingsTotal,
    this.types = const [],
    this.icon,
    this.photoReference,
  });
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? website;
  final double? rating;
  final int? userRatingsTotal;
  final List<String> types;
  final bool? openNow;
  final List<String> photoReferences;
  final Map<String, dynamic> raw;

  PlaceDetails({
    required this.placeId,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.phone,
    this.website,
    this.rating,
    this.userRatingsTotal,
    this.types = const [],
    this.openNow,
    this.photoReferences = const [],
    required this.raw,
  });
}

class PlacesService {
  final String apiKey;
  final String base = 'https://maps.googleapis.com/maps/api/place';

  PlacesService({required this.apiKey});

  Future<List<PlaceSummary>> nearbySearch({
    required double lat,
    required double lng,
    int radius = 5000,
    String keyword = 'food bank',
    int maxResults = 20,
  }) async {
    final uri = Uri.parse(
      '$base/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$radius'
      '&keyword=${Uri.encodeQueryComponent(keyword)}'
      '&key=$apiKey',
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Places API error ${resp.statusCode}: ${resp.body}');
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = (map['results'] as List<dynamic>?) ?? [];

    final list = results.take(maxResults).map<PlaceSummary>((r) {
      final geometry = r['geometry'] ?? {};
      final loc = geometry['location'] ?? {};
      String? photoRef;
      if (r['photos'] != null && (r['photos'] as List).isNotEmpty) {
        photoRef = r['photos'][0]['photo_reference'] as String?;
      }
      return PlaceSummary(
        placeId: r['place_id'] as String,
        name: r['name'] as String? ?? 'Unknown',
        address: r['vicinity'] as String? ?? r['formatted_address'] as String?,
        lat: (loc['lat'] as num?)?.toDouble(),
        lng: (loc['lng'] as num?)?.toDouble(),
        rating: (r['rating'] as num?)?.toDouble(),
        userRatingsTotal: (r['user_ratings_total'] as num?)?.toInt(),
        types: (r['types'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
        icon: r['icon'] as String?,
        photoReference: photoRef,
      );
    }).toList();

    return list;
  }

  Future<List<PlaceSummary>> textSearch({
    required String query,
    int maxResults = 20,
  }) async {
    final uri = Uri.parse(
      '$base/textsearch/json?query=${Uri.encodeQueryComponent(query)}&key=$apiKey',
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Places TextSearch error ${resp.statusCode}: ${resp.body}');
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = (map['results'] as List<dynamic>?) ?? [];
    return results.take(maxResults).map<PlaceSummary>((r) {
      final geometry = r['geometry'] ?? {};
      final loc = geometry['location'] ?? {};
      String? photoRef;
      if (r['photos'] != null && (r['photos'] as List).isNotEmpty) {
        photoRef = r['photos'][0]['photo_reference'] as String?;
      }
      return PlaceSummary(
        placeId: r['place_id'] as String,
        name: r['name'] as String? ?? 'Unknown',
        address: r['formatted_address'] as String? ?? r['vicinity'] as String?,
        lat: (loc['lat'] as num?)?.toDouble(),
        lng: (loc['lng'] as num?)?.toDouble(),
        rating: (r['rating'] as num?)?.toDouble(),
        userRatingsTotal: (r['user_ratings_total'] as num?)?.toInt(),
        types: (r['types'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
        icon: r['icon'] as String?,
        photoReference: photoRef,
      );
    }).toList();
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final fields = [
      'place_id',
      'name',
      'formatted_address',
      'geometry',
      'formatted_phone_number',
      'opening_hours',
      'website',
      'photo',
      'rating',
      'user_ratings_total',
      'types'
    ].join(',');

    final uri = Uri.parse(
      '$base/details/json?place_id=${Uri.encodeQueryComponent(placeId)}&fields=$fields&key=$apiKey',
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Places Details error ${resp.statusCode}: ${resp.body}');
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final result = map['result'] as Map<String, dynamic>? ?? {};

    final geometry = result['geometry'] ?? {};
    final loc = (geometry['location'] ?? {});
    final photos = (result['photos'] as List<dynamic>?)
            ?.map((p) => p['photo_reference'] as String)
            .toList() ??
        [];

    final openNow = result['opening_hours'] != null
        ? (result['opening_hours']['open_now'] as bool?) ?? false
        : null;

    return PlaceDetails(
      placeId: result['place_id'] as String? ?? placeId,
      name: result['name'] as String? ?? 'Unknown',
      address: result['formatted_address'] as String?,
      lat: (loc['lat'] as num?)?.toDouble(),
      lng: (loc['lng'] as num?)?.toDouble(),
      phone: result['formatted_phone_number'] as String?,
      website: result['website'] as String?,
      rating: (result['rating'] as num?)?.toDouble(),
      userRatingsTotal: (result['user_ratings_total'] as num?)?.toInt(),
      types: (result['types'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
      openNow: openNow,
      photoReferences: photos,
      raw: result,
    );
  }

  String photoUrl(String photoReference, {int maxWidth = 800}) {
    return '$base/photo?maxwidth=$maxWidth&photoreference=${Uri.encodeComponent(photoReference)}&key=$apiKey';
  }
}