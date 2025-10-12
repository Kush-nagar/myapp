import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSummary {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double? rating;
  final bool? openNow;
  final List<String> types;
  final String? photoReference;

  PlaceSummary({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.rating,
    this.openNow,
    this.types = const [],
    this.photoReference,
  });
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? phone;
  final String? website;
  final double? rating;
  final List<String> types;
  final bool? openNow;
  final List<String> photoReferences;
  final String? openingHours; // simplified string

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.phone,
    this.website,
    this.rating,
    this.types = const [],
    this.openNow,
    this.photoReferences = const [],
    this.openingHours,
  });
}

class PlacesService {
  final String _apiKey = 'AIzaSyC2Ei8wsfT5dJuF9s3lkZC3je2G1NEzTB0';
  final http.Client _client;

  PlacesService({http.Client? client}) : _client = client ?? http.Client();

  /// Text search using user's query and optional location (lat,lng) + radius (meters)
  Future<List<PlaceSummary>> textSearch({
    required String query,
    double? lat,
    double? lng,
    int radiusMeters = 5000,
  }) async {
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/textsearch/json', {
      'query': query,
      if (lat != null && lng != null) 'location': '$lat,$lng',
      if (lat != null && lng != null) 'radius': '$radiusMeters',
      'key': _apiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200)
      throw Exception('Places API failed: ${res.statusCode}');
    final Map body = json.decode(res.body);

    if (body['status'] != 'OK' && body['status'] != 'ZERO_RESULTS') {
      // you may want to handle OVER_QUERY_LIMIT, REQUEST_DENIED, etc.
      throw Exception(
          'Places API error: ${body['status']}: ${body['error_message'] ?? ''}');
    }

    final results = (body['results'] as List<dynamic>? ?? []);
    return results.map((r) {
      final geometry = r['geometry'] ?? {};
      final loc = (geometry['location'] ?? {});
      String? photoRef;
      if (r['photos'] != null && (r['photos'] as List).isNotEmpty) {
        photoRef = r['photos'][0]['photo_reference'] as String?;
      }
      return PlaceSummary(
        placeId: r['place_id'],
        name: r['name'] ?? '',
        address: r['formatted_address'] ?? r['vicinity'] ?? '',
        lat: (loc['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (loc['lng'] as num?)?.toDouble() ?? 0.0,
        rating: (r['rating'] as num?)?.toDouble(),
        openNow: (r['opening_hours'] != null)
            ? r['opening_hours']['open_now'] as bool?
            : null,
        types: (r['types'] as List?)?.map((t) => t.toString()).toList() ?? [],
        photoReference: photoRef,
      );
    }).toList();
  }

  /// Get details for a place
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    // specify fields you need to reduce quota/cost
    final fields = [
      'name',
      'formatted_address',
      'geometry',
      'formatted_phone_number',
      'website',
      'rating',
      'types',
      'opening_hours',
      'photos'
    ].join(',');

    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'fields': fields,
      'key': _apiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200)
      throw Exception('Place details failed: ${res.statusCode}');
    final Map body = json.decode(res.body);
    if (body['status'] != 'OK') {
      throw Exception('Place details error: ${body['status']}');
    }
    final r = body['result'] as Map<String, dynamic>;
    final geometry = r['geometry'] ?? {};
    final loc = (geometry['location'] ?? {});
    final List<String> photos = [];
    if (r['photos'] != null) {
      for (final p in (r['photos'] as List)) {
        if (p['photo_reference'] != null) photos.add(p['photo_reference']);
      }
    }
    // simple opening hours string
    String? openingHours;
    if (r['opening_hours'] != null &&
        r['opening_hours']['weekday_text'] != null) {
      openingHours = (r['opening_hours']['weekday_text'] as List).join('\n');
    }

    return PlaceDetails(
      placeId: placeId,
      name: r['name'] ?? '',
      address: r['formatted_address'] ?? '',
      lat: (loc['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (loc['lng'] as num?)?.toDouble() ?? 0.0,
      phone: r['formatted_phone_number'],
      website: r['website'],
      rating: (r['rating'] as num?)?.toDouble(),
      types: (r['types'] as List?)?.map((t) => t.toString()).toList() ?? [],
      openNow: r['opening_hours'] != null
          ? r['opening_hours']['open_now'] as bool?
          : null,
      photoReferences: photos,
      openingHours: openingHours,
    );
  }

  /// Convert a photo reference to a URL
  String photoUrlFromReference(String photoReference, {int maxWidth = 800}) {
    final params = {
      'photoreference': photoReference,
      'maxwidth': '$maxWidth',
      'key': _apiKey,
    };
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/photo', params);
    return uri.toString();
  }

  void dispose() => _client.close();
}
