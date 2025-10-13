// lib/screens/map_view/mapview_screen.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/places_service.dart';
import './widgets/map_controls.dart';
import './widgets/map_search_bar.dart';
import './widgets/organization_info_card.dart';
import './widgets/organization_list_bottom_sheet.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedOrganization;
  bool _isLoading = true;
  bool _showBottomSheet = false;
  MapType _currentMapType = MapType.normal;
  // ignore: unused_field
  String _searchQuery = '';
  List<Map<String, dynamic>> _placesResults = [];
  final PlacesService _placesService = PlacesService();

  // 30 miles in meters
  static const int _radiusMeters = 48280;

  // keep an internal map of placeId -> markerId
  final Map<String, Marker> _placeMarkers = {};

  @override
  void initState() {
    super.initState();
    _initializeMapAndPlaces();
  }

  Future<void> _initializeMapAndPlaces() async {
    try {
      await _getCurrentLocation();
      if (_currentPosition != null) {
        // Run an initial nearby search for donation-related places
        await _searchNearbyDefaults();
      }
    } catch (e) {
      debugPrint('Error initializing map and places: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.location.request();
        if (!permission.isGranted) {
          // Permission denied: fallback to default coords (San Francisco) but still continue
          _currentPosition = Position(
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _currentPosition = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  /// Search a set of default donation-related queries and merge results.
  Future<void> _searchNearbyDefaults() async {
    if (_currentPosition == null) return;

    final queries = [
      'food bank',
      'food pantry',
      'shelter',
      'community center',
      'donation center',
      'soup kitchen',
    ];

    final Set<String> seenPlaceIds = {};
    final List<Map<String, dynamic>> results = [];

    for (final q in queries) {
      try {
        final places = await _placesService.textSearch(
          query: q,
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          radiusMeters: _radiusMeters,
        );

        for (final p in places) {
          if (seenPlaceIds.contains(p.placeId)) continue;
          seenPlaceIds.add(p.placeId);

          final double? distanceMiles = _computeDistanceMiles(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            p.lat,
            p.lng,
          );

          results.add(_mapPlaceToOrg(p, distanceMiles));
        }
      } catch (e) {
        debugPrint('Places search failed for "$q": $e');
      }
    }

    // sort by distance (nulls last)
    results.sort((a, b) {
      final ad = a['distance'] as double?;
      final bd = b['distance'] as double?;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });

    setState(() {
      _placesResults = results;
      _showBottomSheet = results.isNotEmpty;
    });

    _createMarkersFromPlacesResults();
  }

  Map<String, dynamic> _mapPlaceToOrg(dynamic p, double? distanceMiles) {
    // p is PlaceSummary from PlacesService
    return <String, dynamic>{
      'id': p.placeId, // keep placeId as id
      'placeId': p.placeId,
      'name': p.name ?? '',
      'type': (p.types != null && p.types.isNotEmpty)
          ? p.types.first
          : 'organization',
      'latitude': p.lat,
      'longitude': p.lng,
      'rating': p.rating ?? 0.0,
      'distance': distanceMiles != null
          ? double.parse(distanceMiles.toStringAsFixed(1))
          : null,
      'phone': null,
      'address': p.address ?? '',
      'currentNeeds':
          '', // app-specific (you can load from backend keyed by placeId)
      'operatingHours': p.openNow == true ? 'Open now' : 'Hours not available',
      'description': '',
      'photoReference': p.photoReference,
      'image': p.photoReference != null
          ? _placesService.photoUrlFromReference(
              p.photoReference!,
              maxWidth: 800,
            )
          : '',
      'raw': p,
    };
  }

  double? _computeDistanceMiles(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    try {
      final meters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
      return meters / 1609.344;
    } catch (e) {
      return null;
    }
  }

  void _createMarkersFromPlacesResults() {
    final Map<String, Marker> markers = {};

    // user marker
    if (_currentPosition != null) {
      markers['user_location'] = Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You'),
      );
    }

    for (final org in _placesResults) {
      final placeId = org['placeId'] as String;
      final lat = org['latitude'] as double;
      final lng = org['longitude'] as double;
      final type = org['type'] as String? ?? 'organization';

      final marker = Marker(
        markerId: MarkerId(placeId),
        position: LatLng(lat, lng),
        icon: _getMarkerIconForType(type),
        infoWindow: InfoWindow(
          title: org['name'] as String?,
          snippet: (org['rating'] != null)
              ? '${org['rating']} ⭐ • ${org['distance'] ?? '--'} mi'
              : null,
        ),
        onTap: () {
          _onMarkerTapped(org);
        },
      );

      markers[placeId] = marker;
    }

    setState(() {
      _markers = markers.values.toSet();
      _placeMarkers
        ..clear()
        ..addAll(markers);
    });
  }

  BitmapDescriptor _getMarkerIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'food_bank':
      case 'food_pantry':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'shelter':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'restaurant':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _onMarkerTapped(Map<String, dynamic> organization) {
    setState(() {
      _selectedOrganization = organization;
      _showBottomSheet = false;
    });
    // optionally animate camera to marker
    if (_mapController != null) {
      final lat = organization['latitude'] as double;
      final lng = organization['longitude'] as double;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          13.5,
        ),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    // Optionally update visible organizations based on viewport
  }

  /// Called by search bar. If query empty -> restore nearby defaults; otherwise run text search.
  Future<void> _onSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
      _selectedOrganization = null;
    });

    try {
      if (query.trim().isEmpty) {
        await _searchNearbyDefaults();
        return;
      }

      final lat = _currentPosition?.latitude;
      final lng = _currentPosition?.longitude;

      // Use Places textSearch centering on user location
      final places = await _placesService.textSearch(
        query: query,
        lat: lat,
        lng: lng,
        radiusMeters: _radiusMeters,
      );

      final List<Map<String, dynamic>> results = places.map((p) {
        final double? distanceMiles = (lat != null && lng != null)
            ? _computeDistanceMiles(lat, lng, p.lat, p.lng)
            : null;
        return _mapPlaceToOrg(p, distanceMiles);
      }).toList();

      results.sort((a, b) {
        final ad = a['distance'] as double?;
        final bd = b['distance'] as double?;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });

      setState(() {
        _placesResults = results;
        _showBottomSheet = results.isNotEmpty;
      });

      _createMarkersFromPlacesResults();

      // If there is at least one result, animate camera to first result
      if (results.isNotEmpty && _mapController != null) {
        final first = results.first;
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(first['latitude'] as double, first['longitude'] as double),
            14.0,
          ),
        );
      }
    } catch (e) {
      debugPrint('Search failed: $e');
      // leave _placesResults empty on failure
      setState(() {
        _placesResults = [];
        _showBottomSheet = false;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Future<void> _goToCurrentLocation() async {
    if (_mapController != null && _currentPosition != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          16.0,
        ),
      );
    }
  }

  Future<void> _zoomIn() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  Future<void> _zoomOut() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  Future<void> _callOrganization(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _getDirections(double lat, double lng) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _viewOrganizationDetails(Map<String, dynamic> organization) {
    // Pass the whole organization map so the detail screen will display
    // the exact name/address/photo provided by the tapped map/list item.
    Navigator.pushNamed(
      context,
      '/organization-detail-screen',
      arguments: organization,
    );
  }

  void _showOrganizationsList() {
    setState(() {
      _showBottomSheet = true;
      _selectedOrganization = null;
    });
  }

  void _hideBottomSheet() {
    setState(() {
      _showBottomSheet = false;
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _placesService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
        backgroundColor: DonationAppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: DonationAppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'list',
              color: DonationAppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            onPressed: _showOrganizationsList,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading map...',
                    style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                        : const LatLng(37.7749, -122.4194),
                    zoom: 13.5,
                  ),
                  markers: _markers,
                  mapType: _currentMapType,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Search Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: MapSearchBar(
                    onSearch: _onSearch,
                    onFilterTap: () {
                      Navigator.pushNamed(context, '/search-filter-screen');
                    },
                  ),
                ),

                // Map Controls
                MapControls(
                  onCurrentLocation: _goToCurrentLocation,
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onMapTypeToggle: _toggleMapType,
                  currentMapType: _currentMapType == MapType.satellite
                      ? 'satellite'
                      : 'normal',
                ),

                // Selected Organization Info Card
                if (_selectedOrganization != null)
                  Positioned(
                    bottom: 2.h,
                    left: 0,
                    right: 0,
                    child: OrganizationInfoCard(
                      organization: _selectedOrganization!,
                      onCall: () => _callOrganization(
                        _selectedOrganization!['phone'] as String?,
                      ),
                      onDirections: () => _getDirections(
                        _selectedOrganization!['latitude'] as double,
                        _selectedOrganization!['longitude'] as double,
                      ),
                      onViewDetails: () =>
                          _viewOrganizationDetails(_selectedOrganization!),
                    ),
                  ),

                // Organization List Bottom Sheet
                if (_showBottomSheet)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: OrganizationListBottomSheet(
                      organizations: _placesResults,
                      onOrganizationTap: (organization) {
                        _onMarkerTapped(organization);
                        // Animate to organization location
                        if (_mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(
                                organization['latitude'] as double,
                                organization['longitude'] as double,
                              ),
                              15.0,
                            ),
                          );
                        }
                      },
                      onClose: _hideBottomSheet,
                    ),
                  ),
              ],
            ),
    );
  }
}
