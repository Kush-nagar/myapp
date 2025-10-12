// lib/screens/search_filter/searchfilterscreen.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/app_export.dart';
import '../../services/places_service.dart';
import './widgets/empty_search_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/filter_modal_widget.dart';
import './widgets/organization_card_widget.dart';
import './widgets/search_bar_widget.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({Key? key}) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Keep your existing audio recorder instance name; update type if different.
  final AudioRecorder _audioRecorder = AudioRecorder();

  final PlacesService _placesService = PlacesService();

  List<Map<String, dynamic>> _allOrganizations = [];
  List<Map<String, dynamic>> _filteredOrganizations = [];
  List<String> _recentSearches = [];
  Map<String, dynamic> _activeFilters = {};
  bool _isRecording = false;
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _loadRecentSearches();
    _initLocationAndSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioRecorder.dispose();
    _placesService.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Keep your mock data as fallback (useful while developing without API key)
    _allOrganizations = [
      {
        "id": 1,
        "name": "Central Food Bank",
        "type": "Food Bank",
        "address": "123 Main Street, Downtown",
        "distance": 2.3,
        "rating": 4.8,
        "hours": "Mon-Fri 9AM-5PM",
        "isOpenNow": true,
        "isFavorite": false,
        "urgentNeed": true,
        "donationTypes": ["Canned Goods", "Fresh Produce", "Dairy Products"],
        "image":
            "https://images.pexels.com/photos/6646918/pexels-photo-6646918.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 2,
        "name": "Hope Community Shelter",
        "type": "Shelter",
        "address": "456 Oak Avenue, Midtown",
        "distance": 1.8,
        "rating": 4.5,
        "hours": "24/7 Open",
        "isOpenNow": true,
        "isFavorite": true,
        "urgentNeed": false,
        "donationTypes": ["Prepared Meals", "Canned Goods", "Baked Goods"],
        "image":
            "https://images.pexels.com/photos/6995247/pexels-photo-6995247.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 3,
        "name": "Green Valley Restaurant",
        "type": "Restaurant",
        "address": "789 Pine Street, Uptown",
        "distance": 4.2,
        "rating": 4.2,
        "hours": "Tue-Sun 11AM-9PM",
        "isOpenNow": false,
        "isFavorite": false,
        "urgentNeed": false,
        "donationTypes": ["Fresh Produce", "Prepared Meals"],
        "image":
            "https://images.pexels.com/photos/1267320/pexels-photo-1267320.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 4,
        "name": "Unity Community Center",
        "type": "Community Center",
        "address": "321 Elm Street, Southside",
        "distance": 3.1,
        "rating": 4.6,
        "hours": "Mon-Sat 8AM-6PM",
        "isOpenNow": true,
        "isFavorite": false,
        "urgentNeed": true,
        "donationTypes": ["Canned Goods", "Baked Goods", "Dairy Products"],
        "image":
            "https://images.pexels.com/photos/6646971/pexels-photo-6646971.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 5,
        "name": "Riverside Food Pantry",
        "type": "Food Bank",
        "address": "654 River Road, Eastside",
        "distance": 5.7,
        "rating": 4.3,
        "hours": "Wed-Fri 10AM-4PM",
        "isOpenNow": false,
        "isFavorite": true,
        "urgentNeed": false,
        "donationTypes": ["Fresh Produce", "Canned Goods"],
        "image":
            "https://images.pexels.com/photos/6995220/pexels-photo-6995220.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 6,
        "name": "Helping Hands Shelter",
        "type": "Shelter",
        "address": "987 Cedar Lane, Westside",
        "distance": 2.9,
        "rating": 4.7,
        "hours": "Daily 6AM-10PM",
        "isOpenNow": true,
        "isFavorite": false,
        "urgentNeed": true,
        "donationTypes": ["Prepared Meals", "Dairy Products", "Baked Goods"],
        "image":
            "https://images.pexels.com/photos/6646863/pexels-photo-6646863.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
    ];

    _filteredOrganizations = List.from(_allOrganizations);
  }

  void _loadRecentSearches() {
    // Mock recent searches
    _recentSearches = [
      'food bank near me',
      'shelter',
      'canned goods donation',
      'fresh produce',
      'community center',
    ];
  }

  Future<void> _initLocationAndSearch() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled. You can notify the user or continue with mock data.
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied.
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied.
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
      });

      // Optionally run an initial search (e.g., show local food banks)
      if (_searchController.text.trim().isEmpty) {
        // you can choose a default initial query or keep mock data
        // _performSearch('food bank');
      } else {
        _performSearch(_searchController.text);
      }
    } catch (e) {
      // Keep mock data if location fails
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    // Add to recent searches if not empty and not already present
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
    }

    try {
      // if query empty -> show all mock orgs
      if (query.trim().isEmpty) {
        setState(() {
          _filteredOrganizations = List.from(_allOrganizations);
          _isLoading = false;
        });
        return;
      }

      final lat = _currentPosition?.latitude;
      final lng = _currentPosition?.longitude;

      // Call PlacesService (text search)
      final places = await _placesService.textSearch(
        query: query,
        lat: lat,
        lng: lng,
        radiusMeters: 10000,
      );

      // Map PlaceSummary -> your UI model
      final mapped = places.map((p) {
        final meters = _distanceFromPositionMeters(lat, lng, p.lat, p.lng);
        final miles = meters != null ? _metersToMiles(meters) : null;
        final double? distanceMilesRounded =
            miles != null ? double.parse(miles.toStringAsFixed(1)) : null;

        return <String, dynamic>{
          'id': p.placeId.hashCode,
          'placeId': p.placeId,
          'name': p.name,
          'type': p.types.isNotEmpty ? p.types.first : 'Organization',
          'address': p.address,
          'distance': distanceMilesRounded,
          'rating': p.rating ?? 0.0,
          'hours': p.openNow == true ? 'Open now' : 'Hours not available',
          'isOpenNow': p.openNow ?? false,
          'isFavorite': false,
          'urgentNeed': false,
          'donationTypes': <String>[],
          'image': p.photoReference != null
              ? _placesService.photoUrlFromReference(p.photoReference!)
              : '',
          'raw': p,
        };
      }).toList();

      // sort by distance if available
      mapped.sort((a, b) {
        final aDist = a['distance'] as double?;
        final bDist = b['distance'] as double?;
        if (aDist == null && bDist == null) return 0;
        if (aDist == null) return 1;
        if (bDist == null) return -1;
        return aDist.compareTo(bDist);
      });

      setState(() {
        _filteredOrganizations = mapped;
      });
    } catch (e) {
      // On error, show empty results (or keep mock - choose behavior)
      setState(() {
        _filteredOrganizations = [];
      });
      // Optionally show snackbar
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search failed')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double? _distanceFromPositionMeters(
      double? lat1, double? lng1, double lat2, double lng2) {
    if (lat1 == null || lng1 == null) return null;
    try {
      return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    } catch (e) {
      return null;
    }
  }

  double _metersToMiles(double meters) => (meters / 1609.344);

  Future<void> _startVoiceSearch() async {
    if (_isRecording) {
      await _stopVoiceSearch();
      return;
    }

    try {
      bool hasPermission = await Permission.microphone.request().isGranted;
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Microphone permission is required for voice search')),
        );
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(),
            path: 'voice_search.m4a');
        setState(() {
          _isRecording = true;
        });

        // Auto-stop after 5 seconds
        Future.delayed(Duration(seconds: 5), () {
          if (_isRecording) {
            _stopVoiceSearch();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice search is not available')),
      );
    }
  }

  Future<void> _stopVoiceSearch() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      // Mock voice recognition result -- replace with actual speech-to-text if available
      String mockResult = 'food bank';
      _searchController.text = mockResult;
      await _performSearch(mockResult);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice search: "$mockResult"')),
      );
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }

  void _onRecentSearchTap(String search) {
    _searchController.text = search;
    _performSearch(search);
  }

  void _removeFilter(String category, String value) {
    setState(() {
      if (_activeFilters[category] is List) {
        (_activeFilters[category] as List).remove(value);
        if ((_activeFilters[category] as List).isEmpty) {
          _activeFilters.remove(category);
        }
      } else {
        _activeFilters.remove(category);
      }
    });
    _performSearch(_searchController.text);
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });
    _performSearch(_searchController.text);
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _performSearch(_searchController.text);
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModalWidget(
        currentFilters: _activeFilters,
        onApplyFilters: _applyFilters,
        onClearFilters: _clearAllFilters,
      ),
    );
  }

  void _toggleFavorite(int organizationId) {
    setState(() {
      final index = _filteredOrganizations
          .indexWhere((org) => org['id'] == organizationId);
      if (index != -1) {
        _filteredOrganizations[index]['isFavorite'] =
            !_filteredOrganizations[index]['isFavorite'];
      }

      final allIndex =
          _allOrganizations.indexWhere((org) => org['id'] == organizationId);
      if (allIndex != -1) {
        _allOrganizations[allIndex]['isFavorite'] =
            !_allOrganizations[allIndex]['isFavorite'];
      }
    });
  }

  void _navigateToOrganizationDetail(Map<String, dynamic> organization) async {
    final placeId = organization['placeId'] as String?;
    if (placeId == null) {
      Navigator.pushNamed(
        context,
        '/organization-detail-screen',
        arguments: organization,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final details = await _placesService.getPlaceDetails(placeId);

      final detailArg = {
        'placeId': details.placeId,
        'name': details.name,
        'address': details.address,
        'lat': details.lat,
        'lng': details.lng,
        'phone': details.phone,
        'website': details.website,
        'rating': details.rating,
        'types': details.types,
        'openingHours': details.openingHours,
        'photoUrls': details.photoReferences
            .map((r) => _placesService.photoUrlFromReference(r))
            .toList(),
      };

      Navigator.pushNamed(
        context,
        '/organization-detail-screen',
        arguments: detailArg,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load details')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Search & Filter',
          style: DonationAppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterModal,
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'tune',
                  color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                if (_activeFilters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 4.w,
                        minHeight: 4.w,
                      ),
                      child: Text(
                        '${_getTotalFilterCount()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/map-view-screen'),
            icon: CustomIconWidget(
              iconName: 'map',
              color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(4.w),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: (q) => _performSearch(q),
              onVoiceSearch: _startVoiceSearch,
              onClear: _clearSearch,
              recentSearches: _recentSearches,
              onRecentSearchTap: _onRecentSearchTap,
            ),
          ),

          // Filter chips
          FilterChipsWidget(
            activeFilters: _activeFilters,
            onRemoveFilter: _removeFilter,
            onClearAll: _clearAllFilters,
          ),

          // Results
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: DonationAppTheme.lightTheme.primaryColor,
                    ),
                  )
                : _filteredOrganizations.isEmpty
                    ? EmptySearchWidget(
                        searchQuery: _searchController.text,
                        onSuggestionTap: _onSuggestionTap,
                      )
                    : ListView.builder(
                        itemCount: _filteredOrganizations.length,
                        itemBuilder: (context, index) {
                          final organization = _filteredOrganizations[index];
                          return OrganizationCardWidget(
                            organization: organization,
                            onTap: () =>
                                _navigateToOrganizationDetail(organization),
                            onFavorite: () =>
                                _toggleFavorite(organization['id']),
                          );
                        },
                      ),
          ),
        ],
      ),  
    );
  }

  int _getTotalFilterCount() {
    int count = 0;
    _activeFilters.forEach((key, value) {
      if (value is List && (value).isNotEmpty) {
        count += (value).length;
      } else if (value is String && value.isNotEmpty) {
        count += 1;
      } else if (value is bool && value == true) {
        count += 1;
      } else if (value is double && value > 0) {
        count += 1;
      }
    });
    return count;
  }
}
