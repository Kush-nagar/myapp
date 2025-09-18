import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
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
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredOrganizations = [];

  // Mock data for food donation organizations
  final List<Map<String, dynamic>> _organizations = [
    {
      "id": 1,
      "name": "Central Food Bank",
      "type": "food_bank",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "rating": 4.5,
      "distance": 1.2,
      "phone": "+1 (555) 123-4567",
      "address": "123 Main Street, San Francisco, CA 94102",
      "currentNeeds":
          "Canned goods, fresh produce, and non-perishable items urgently needed",
      "operatingHours": "Mon-Fri: 9AM-5PM, Sat: 10AM-3PM",
      "description":
          "Serving the community for over 20 years, providing food assistance to families in need."
    },
    {
      "id": 2,
      "name": "Hope Shelter",
      "type": "shelter",
      "latitude": 37.7849,
      "longitude": -122.4094,
      "rating": 4.2,
      "distance": 2.1,
      "phone": "+1 (555) 234-5678",
      "address": "456 Oak Avenue, San Francisco, CA 94103",
      "currentNeeds": "Hot meals for dinner service and breakfast items",
      "operatingHours": "24/7 - Meal service: 7AM-9AM, 6PM-8PM",
      "description":
          "Emergency shelter providing meals and temporary housing for homeless individuals."
    },
    {
      "id": 3,
      "name": "Green Valley Restaurant",
      "type": "restaurant",
      "latitude": 37.7649,
      "longitude": -122.4294,
      "rating": 4.8,
      "distance": 0.8,
      "phone": "+1 (555) 345-6789",
      "address": "789 Pine Street, San Francisco, CA 94104",
      "currentNeeds":
          "Accepting food donations from restaurants and catering services",
      "operatingHours": "Daily: 11AM-10PM",
      "description":
          "Farm-to-table restaurant partnering with local food banks to reduce food waste."
    },
    {
      "id": 4,
      "name": "Community Kitchen",
      "type": "food_bank",
      "latitude": 37.7549,
      "longitude": -122.4394,
      "rating": 4.3,
      "distance": 3.5,
      "phone": "+1 (555) 456-7890",
      "address": "321 Elm Street, San Francisco, CA 94105",
      "currentNeeds": "Volunteers needed for food preparation and distribution",
      "operatingHours": "Tue-Thu: 10AM-6PM, Sat: 9AM-4PM",
      "description":
          "Volunteer-run kitchen preparing meals for low-income families and seniors."
    },
    {
      "id": 5,
      "name": "Safe Haven Shelter",
      "type": "shelter",
      "latitude": 37.7449,
      "longitude": -122.4494,
      "rating": 4.0,
      "distance": 4.2,
      "phone": "+1 (555) 567-8901",
      "address": "654 Cedar Road, San Francisco, CA 94106",
      "currentNeeds": "Breakfast items and hygiene products",
      "operatingHours": "24/7 - Check-in: 6PM-10PM",
      "description":
          "Family shelter providing temporary housing and meal services for families with children."
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      _createMarkers();
      _filteredOrganizations = List.from(_organizations);
    } catch (e) {
      debugPrint('Error initializing map: $e');
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
          // Use default location if permission denied
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
      // Use default San Francisco location
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

  void _createMarkers() {
    final Set<Marker> markers = {};

    // Add user location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add organization markers
    for (final org in _organizations) {
      final lat = org['latitude'] as double;
      final lng = org['longitude'] as double;
      final type = org['type'] as String;

      markers.add(
        Marker(
          markerId: MarkerId(org['id'].toString()),
          position: LatLng(lat, lng),
          icon: _getMarkerIcon(type),
          infoWindow: InfoWindow(
            title: org['name'] as String,
            snippet: '${org['rating']} ⭐ • ${org['distance']} km',
          ),
          onTap: () => _onMarkerTapped(org),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    switch (type) {
      case 'food_bank':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'shelter':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'restaurant':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _onMarkerTapped(Map<String, dynamic> organization) {
    setState(() {
      _selectedOrganization = organization;
      _showBottomSheet = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14.0,
        ),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    // Update organizations list based on current viewport
    _updateVisibleOrganizations();
  }

  void _updateVisibleOrganizations() {
    // This would typically filter organizations based on map bounds
    // For now, we'll show all organizations
    if (mounted) {
      setState(() {
        _filteredOrganizations = _organizations
            .where((org) =>
                _searchQuery.isEmpty ||
                (org['name'] as String)
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _updateVisibleOrganizations();
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _goToCurrentLocation() async {
    if (_mapController != null && _currentPosition != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          16.0,
        ),
      );
    }
  }

  void _zoomIn() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() async {
    if (_mapController != null) {
      await _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  void _callOrganization(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _getDirections(double lat, double lng) async {
    final Uri mapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _viewOrganizationDetails(Map<String, dynamic> organization) {
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
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : const LatLng(37.7749, -122.4194),
                    zoom: 14.0,
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
                          _selectedOrganization!['phone'] as String),
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
                      organizations: _filteredOrganizations,
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
                              16.0,
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
