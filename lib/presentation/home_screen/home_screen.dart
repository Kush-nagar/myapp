import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../services/places_service.dart'; // <-- make sure this file exists and exposes the methods used below
import '../../widgets/user_profile_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/offline_banner_widget.dart';
import './widgets/organization_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/urgent_needs_banner_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isOnline = true;
  bool _isLoading = false;
  String _currentLocation = "Katy, TX, 77494";
  DateTime _lastUpdated = DateTime.now();
  late AnimationController _refreshController;

  // Places + location
  final PlacesService _placesService = PlacesService();
  Position? _currentPosition;

  // This is the master list (hard-coded demo). We'll filter this into _displayOrganizations.
  final List<Map<String, dynamic>> _masterOrganizations = [
    {
      "id": 1,
      "name": "Downtown Food Bank",
      "logo":
          "https://images.unsplash.com/photo-1593113598332-cd288d649433?w=200&h=200&fit=crop",
      "rating": 4.8,
      "distance": "0.3 mi",
      "currentNeeds": ["Fresh produce", "Canned goods", "Dairy products"],
      "phone": "+1 (555) 123-4567",
      "address": "123 Main St, New York, NY 10001",
      "isFavorited": false,
    },
    {
      "id": 2,
      "name": "Community Kitchen & Shelter",
      "logo":
          "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=200&h=200&fit=crop",
      "rating": 4.6,
      "distance": "0.7 mi",
      "currentNeeds": ["Hot meals", "Volunteers", "Blankets"],
      "phone": "+1 (555) 234-5678",
      "address": "456 Oak Ave, New York, NY 10002",
      "isFavorited": true,
    },
    {
      "id": 3,
      "name": "Hope Center Food Pantry",
      "logo":
          "https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=200&h=200&fit=crop",
      "rating": 4.9,
      "distance": "1.2 mi",
      "currentNeeds": ["Baby formula", "Diapers", "Non-perishables"],
      "phone": "+1 (555) 345-6789",
      "address": "789 Pine St, New York, NY 10003",
      "isFavorited": false,
    },
    {
      "id": 4,
      "name": "Salvation Army Food Services",
      "logo":
          "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=200&h=200&fit=crop",
      "rating": 4.5,
      "distance": "1.8 mi",
      "currentNeeds": ["Clothing", "Food donations", "Monetary support"],
      "phone": "+1 (555) 456-7890",
      "address": "321 Elm St, New York, NY 10004",
      "isFavorited": false,
    },
    {
      "id": 5,
      "name": "Local Harvest Food Hub",
      "logo":
          "https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop",
      "rating": 4.7,
      "distance": "2.1 mi",
      "currentNeeds": ["Fresh vegetables", "Fruits", "Bread"],
      "phone": "+1 (555) 567-8901",
      "address": "654 Maple Dr, New York, NY 10005",
      "isFavorited": false,
    },
    // add more orgs here as needed...
  ];

  // This is the list actually displayed (after filtering). Default will be master list.
  List<Map<String, dynamic>> _displayOrganizations = [];

  /// Helper function to filter out unwanted organizations like "Kedo Snackz"
  bool _shouldShowOrganization(Map<String, dynamic> org) {
    final name = (org['name'] as String?)?.toLowerCase() ?? '';

    // Debug: Print organization names to help track where "Kedo Snackz" comes from
    if (name.contains('kedo') || name.contains('snackz')) {
      debugPrint('🚫 Filtering out organization: "${org['name']}"');
      return false;
    }

    // Add more filter conditions here if needed
    return true;
  }

  /// Filter a list of organizations to remove unwanted ones
  List<Map<String, dynamic>> _filterOrganizations(
    List<Map<String, dynamic>> orgs,
  ) {
    return orgs.where(_shouldShowOrganization).toList();
  }

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _checkConnectivity();
    // initialize with master list first, but filter out unwanted organizations
    _displayOrganizations = _filterOrganizations(_masterOrganizations);
    _loadOrganizations();

    // read arguments after first frame to apply donation filters if present
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePostFrameArgs();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    try {
      _placesService.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _handlePostFrameArgs() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['donationIngredients'] != null) {
      final List<dynamic> donationIngredients = List<dynamic>.from(
        args['donationIngredients'] as List<dynamic>,
      );
      final List<String> names = donationIngredients
          .map((e) => e.toString().toLowerCase())
          .toList();

      // Try to find nearby orgs via Places and apply donation filter to them.
      // If that fails (no matches), fall back to master organizations.
      await _searchNearbyAndApplyDonationFilter(names);
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(milliseconds: 1500));

    setState(() {
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });
  }

  Future<void> _refreshData() async {
    _refreshController.repeat();
    await _checkConnectivity();
    await _loadOrganizations();
    _refreshController.stop();
    _refreshController.reset();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/search-filter-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/favorites-screen');
        break;
      case 3:
        // Navigate to profile (not implemented in this scope)
        break;
    }
  }

  void _onSearchTap() {
    Navigator.pushNamed(context, '/search-filter-screen');
  }

  void _onLocationTap() {
    _showLocationModal();
  }

  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: DonationAppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: DonationAppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Change Location",
              style: DonationAppTheme.lightTheme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter ZIP code or city",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: DonationAppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'my_location',
                color: DonationAppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text("Use Current Location"),
              subtitle: Text("Enable GPS for precise results"),
              onTap: () {
                Navigator.pop(context);
                // Handle location permission and update - we'll try to request it here
                _tryGetCurrentPosition().then((pos) {
                  if (pos != null) {
                    setState(() {
                      _currentLocation =
                          "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Could not get current location")),
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onOrganizationTap(Map<String, dynamic> organization) {
    Navigator.pushNamed(
      context,
      '/organization-detail-screen',
      arguments: organization,
    );
  }

  void _onCallOrganization(Map<String, dynamic> organization) {
    // Handle phone call
    final phone = organization["phone"] as String?;
    if (phone != null) {
      // In a real app, use url_launcher to make phone calls
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Calling $phone")));
    }
  }

  void _onGetDirections(Map<String, dynamic> organization) {
    Navigator.pushNamed(context, '/map-view-screen', arguments: organization);
  }

  void _onToggleFavorite(Map<String, dynamic> organization) {
    setState(() {
      final index = _displayOrganizations.indexWhere(
        (org) => org["id"] == organization["id"],
      );
      if (index != -1) {
        _displayOrganizations[index]["isFavorited"] =
            !(_displayOrganizations[index]["isFavorited"] ?? false);
      }

      // also update master copy if present
      final masterIndex = _masterOrganizations.indexWhere(
        (org) => org["id"] == organization["id"],
      );
      if (masterIndex != -1) {
        _masterOrganizations[masterIndex]["isFavorited"] =
            !(_masterOrganizations[masterIndex]["isFavorited"] ?? false);
      }
    });
  }

  void _onExpandSearch() {
    Navigator.pushNamed(context, '/search-filter-screen');
  }

  void _onMapViewTap() {
    Navigator.pushNamed(context, '/map-view-screen');
  }

  // ---------- Filtering logic ----------
  // A small produce keyword set for matching produce-type donations
  final Set<String> _produceKeywords = {
    'tomato',
    'onion',
    'potato',
    'lettuce',
    'carrot',
    'apple',
    'banana',
    'pepper',
    'cucumber',
    'spinach',
    'broccoli',
    'cabbage',
    'mushroom',
    'garlic',
    'ginger',
    'avocado',
    'cilantro',
    'parsley',
    'strawberry',
    'blueberry',
    'grape',
    'orange',
    'lemon',
    'lime',
    'mango',
    'peach',
    'pear',
    'zucchini',
    'melon',
    'corn',
    'okra',
  };

  // Map the incoming ingredient names to org needs and update _displayOrganizations
  void _applyDonationFilter(List<String> ingredientNames) {
    if (ingredientNames.isEmpty) {
      setState(() {
        _displayOrganizations = _filterOrganizations(_masterOrganizations);
      });
      return;
    }

    // lower-case set for quick check
    final Set<String> ingredientSet = ingredientNames
        .map((e) => e.toLowerCase())
        .toSet();

    // For each organization compute a score (# of matches)
    final List<Map<String, dynamic>> scored = [];

    for (final org in _masterOrganizations) {
      final List<String> needs = (org['currentNeeds'] as List<dynamic>)
          .map((n) => n.toString().toLowerCase())
          .toList();

      int matches = 0;

      // 1) direct substring match: ingredient appears in need text
      for (final ing in ingredientSet) {
        for (final need in needs) {
          if (need.contains(ing)) {
            matches++;
            break;
          }
        }
      }

      // 2) category-level match for produce: if organization asks for produce/vegetables/fruits
      final bool orgWantsProduce = needs.any(
        (n) =>
            n.contains('produce') ||
            n.contains('vegetable') ||
            n.contains('fruit') ||
            n.contains('fresh'),
      );

      if (orgWantsProduce) {
        // if any ingredient is in the produceKeywords, give a match
        if (ingredientSet.any((ing) => _produceKeywords.contains(ing))) {
          // Count each produce ingredient once (to avoid huge weight)
          matches += ingredientSet
              .where((ing) => _produceKeywords.contains(ing))
              .length;
        }
      }

      // 3) canned / non-perishables matching
      final bool orgWantsCanned = needs.any(
        (n) =>
            n.contains('canned') ||
            n.contains('non-perish') ||
            n.contains('non perishable') ||
            n.contains('soda'),
      );
      if (orgWantsCanned) {
        // If ingredient is 'beans' or 'canned' etc, increment
        if (ingredientSet.any(
          (ing) =>
              ing.contains('beans') ||
              ing.contains('soup') ||
              ing.contains('canned') ||
              ing.contains('soda'),
        )) {
          matches += 1;
        }
      }

      if (matches > 0) {
        final orgCopy = Map<String, dynamic>.from(org);
        orgCopy['matchScore'] = matches;
        scored.add(orgCopy);
      }
    }

    // Sort descending by matchScore, then by rating (if present)
    scored.sort((a, b) {
      final aScore = (a['matchScore'] as int?) ?? 0;
      final bScore = (b['matchScore'] as int?) ?? 0;
      if (bScore != aScore) return bScore.compareTo(aScore);
      final aRating = (a['rating'] as num?)?.toDouble() ?? 0.0;
      final bRating = (b['rating'] as num?)?.toDouble() ?? 0.0;
      return bRating.compareTo(aRating);
    });

    // Limit to 8 results. If no matches found, fallback to master list.
    setState(() {
      if (scored.isEmpty) {
        _displayOrganizations = _filterOrganizations(_masterOrganizations);
      } else {
        final filteredResults = scored.take(8).map((m) {
          // Remove matchScore before passing to UI, but keep it if you like
          final Map<String, dynamic> copy = Map<String, dynamic>.from(m);
          //copy.remove('matchScore'); // optional
          return copy;
        }).toList();
        _displayOrganizations = _filterOrganizations(filteredResults);
      }
    });
  }

  // ---------- New: geolocation & places-based filtering ----------
  // (methods unchanged)...
  Future<Position?> _tryGetCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = pos;
      return pos;
    } catch (e) {
      debugPrint('Location failed: $e');
      return null;
    }
  }

  double _metersToMiles(double meters) {
    return meters / 1609.344;
  }

  Future<void> _searchNearbyAndApplyDonationFilter(
    List<String> ingredientNames,
  ) async {
    if (ingredientNames.isEmpty) {
      _applyDonationFilter([]);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pos = await _tryGetCurrentPosition();

      final query = 'food bank';
      final places = await _placesService.textSearch(
        query: query,
        lat: pos?.latitude,
        lng: pos?.longitude,
        radiusMeters: 15000,
      );

      if (places == null || places.isEmpty) {
        _applyDonationFilter(ingredientNames);
        return;
      }

      final List<Map<String, dynamic>> candidateOrgs = [];
      final int maxDetails = 12;
      final sliced = places.take(maxDetails).toList();

      final futures = sliced.map((p) async {
        try {
          final details = await _placesService.getPlaceDetails(p.placeId);

          final List<String> inferredNeeds = [];

          final lowerName = (details.name ?? '').toString().toLowerCase();
          final List<String> typeKeywords =
              (details.types as List<dynamic>?)
                      ?.map((t) => t.toString().toLowerCase())
                      .toList() ??
                  [];

          final isFoodOrg = lowerName.contains('food') ||
              lowerName.contains('pantry') ||
              lowerName.contains('shelter') ||
              lowerName.contains('kitchen') ||
              typeKeywords.any(
                (t) =>
                    t.contains('food') ||
                    t.contains('pantry') ||
                    t.contains('shelter') ||
                    t.contains('point_of_interest'),
              );

          if (isFoodOrg) {
            inferredNeeds.addAll([
              'canned goods',
              'fresh produce',
              'dairy products',
            ]);
          }

          if (typeKeywords.contains('restaurant')) {
            inferredNeeds.add('prepared meals');
          }
          if (typeKeywords.contains('grocery_or_supermarket')) {
            inferredNeeds.add('fresh produce');
            inferredNeeds.add('bread');
          }

          final deduped = inferredNeeds.map((s) => s.toLowerCase()).toSet().toList();

          final distanceText =
              (_currentPosition != null && details.lat != null && details.lng != null)
                  ? "${_metersToMiles(Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, details.lat, details.lng)).toStringAsFixed(1)} mi"
                  : '';

          final org = <String, dynamic>{
            'id': details.placeId.hashCode,
            'placeId': details.placeId,
            'name': details.name ?? '',
            'logo': (details.photoReferences != null && (details.photoReferences as List).isNotEmpty)
                ? _placesService.photoUrlFromReference((details.photoReferences as List).first)
                : '',
            'rating': details.rating ?? 0.0,
            'distance': distanceText,
            'currentNeeds': deduped,
            'phone': details.phone ?? '',
            'address': details.address ?? '',
            'isFavorited': false,
          };

          return org;
        } catch (e) {
          debugPrint('Failed fetching details for ${p.placeId}: $e');
          return null;
        }
      }).toList();

      final results = await Future.wait(futures);
      for (final r in results) {
        if (r != null && _shouldShowOrganization(r)) {
          candidateOrgs.add(r);
        }
      }

      if (candidateOrgs.isNotEmpty) {
        _applyDonationFilterToOrgs(ingredientNames, candidateOrgs);
      } else {
        _applyDonationFilter(ingredientNames);
      }
    } catch (e) {
      debugPrint('Nearby search error: $e');
      _applyDonationFilter(ingredientNames);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyDonationFilterToOrgs(
    List<String> ingredientNames,
    List<Map<String, dynamic>> orgList,
  ) {
    if (ingredientNames.isEmpty) {
      setState(() {
        final limitedOrgs = orgList.take(8).toList();
        _displayOrganizations = _filterOrganizations(limitedOrgs);
      });
      return;
    }

    final Set<String> ingredientSet = ingredientNames.map((e) => e.toLowerCase()).toSet();
    final List<Map<String, dynamic>> scored = [];

    for (final org in orgList) {
      final List<String> needs =
          (org['currentNeeds'] as List<dynamic>?)?.map((n) => n.toString().toLowerCase()).toList() ?? [];

      int matches = 0;

      for (final ing in ingredientSet) {
        for (final need in needs) {
          if (need.contains(ing)) {
            matches++;
            break;
          }
        }
      }

      final bool orgWantsProduce = needs.any(
        (n) => n.contains('produce') || n.contains('vegetable') || n.contains('fruit') || n.contains('fresh'),
      );

      if (orgWantsProduce) {
        if (ingredientSet.any((ing) => _produceKeywords.contains(ing))) {
          matches += ingredientSet.where((ing) => _produceKeywords.contains(ing)).length;
        }
      }

      final bool orgWantsCanned = needs.any(
        (n) => n.contains('canned') || n.contains('non-perish') || n.contains('non perishable'),
      );
      if (orgWantsCanned) {
        if (ingredientSet.any((ing) => ing.contains('beans') || ing.contains('soup') || ing.contains('canned'))) {
          matches += 1;
        }
      }

      if (matches > 0) {
        final orgCopy = Map<String, dynamic>.from(org);
        orgCopy['matchScore'] = matches;
        scored.add(orgCopy);
      }
    }

    scored.sort((a, b) {
      final aScore = (a['matchScore'] as int?) ?? 0;
      final bScore = (b['matchScore'] as int?) ?? 0;
      if (bScore != aScore) return bScore.compareTo(aScore);
      final aRating = (a['rating'] as num?)?.toDouble() ?? 0.0;
      final bRating = (b['rating'] as num?)?.toDouble() ?? 0.0;
      return bRating.compareTo(aRating);
    });

    setState(() {
      if (scored.isEmpty) {
        _displayOrganizations = _filterOrganizations(_masterOrganizations);
      } else {
        final filteredResults = scored.take(8).map((m) {
          final Map<String, dynamic> copy = Map<String, dynamic>.from(m);
          return copy;
        }).toList();
        _displayOrganizations = _filterOrganizations(filteredResults);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: DonationAppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              // Header + search area
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color: DonationAppTheme.lightTheme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: DonationAppTheme.lightTheme.colorScheme.outline.withOpacity(0.08),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    splashColor: DonationAppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                                    highlightColor: DonationAppTheme.lightTheme.colorScheme.primary.withOpacity(0.05),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: CustomIconWidget(
                                        iconName: 'arrow_back',
                                        color: DonationAppTheme.lightTheme.colorScheme.onSurface,
                                        size: 6.w,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Find Organizations",
                                      style: DonationAppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24,
                                        color: DonationAppTheme.lightTheme.colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      "Donate your ingredients to those in need",
                                      style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                        color: DonationAppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 3.w),
                              UserProfileWidget(size: 12.w, showBorder: true),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          SearchBarWidget(
                            currentLocation: _currentLocation,
                            onSearchTap: _onSearchTap,
                            onLocationTap: _onLocationTap,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (!_isOnline) ...[
                      OfflineBannerWidget(lastUpdated: _lastUpdated),
                      SizedBox(height: 2.h),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          "Urgent Needs",
                          style: DonationAppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    UrgentNeedsBannerWidget(),
                    SizedBox(height: 3.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nearby Organizations",
                            style: DonationAppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          if (_isLoading)
                            Container(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  DonationAppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                  ],
                ),
              ),

              // ========== StreamBuilder for Firestore organizations (REPLACEMENT) ==========
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('organizations')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text('Error loading organizations: ${snapshot.error}'),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: DonationAppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  // Map Firestore docs -> display-friendly maps
                  final docs = snapshot.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return {
                      "id": data['mockId'] ?? d.id.hashCode,
                      "placeId": data['placeId'] ?? null, // optional if you store it
                      "name": data['name'] ?? '',
                      "logo": data['image'] ?? '',
                      "rating": (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
                      "distance": (data['distance'] != null) ? data['distance'].toString() : '',
                      "currentNeeds": (data['currentNeeds'] as List<dynamic>?)?.map((e) {
                        if (e is Map && e['item'] != null) return e['item'].toString();
                        return e.toString();
                      }).toList() ?? [],
                      "phone": (data['contact']?['phone']) ?? '',
                      "address": (data['contact']?['address']) ?? '',
                      "isFavorited": false,
                      "raw": data,
                    };
                  }).toList();

                  // Filter both sources (Firestore docs + any filtered list) using your filter guard
                  final filteredDocs = _filterOrganizations(docs);
                  final filteredDisplayOrgs = _filterOrganizations(_displayOrganizations);

                  // Combine them while deduplicating.
                  // Priority: keep Firestore entries first, then append unique filtered orgs.
                  final List<Map<String, dynamic>> combined = [];
                  final Set<String> seenKeys = {};

                  String makeKey(Map<String, dynamic> org) {
                    // prefer placeId -> id -> normalized name
                    final placeId = (org['placeId'] ?? '').toString();
                    if (placeId.isNotEmpty) return 'placeId::$placeId';
                    final id = org['id']?.toString() ?? '';
                    if (id.isNotEmpty) return 'id::$id';
                    final name = (org['name'] ?? '').toString().toLowerCase().trim();
                    return 'name::$name';
                  }

                  // Add firestore items first
                  for (final org in filteredDocs) {
                    final key = makeKey(org);
                    if (!seenKeys.contains(key)) {
                      seenKeys.add(key);
                      combined.add(org);
                    }
                  }

                  // Then append any items from _displayOrganizations that are not already present
                  for (final org in filteredDisplayOrgs) {
                    final key = makeKey(org);
                    if (!seenKeys.contains(key)) {
                      seenKeys.add(key);
                      combined.add(org);
                    }
                  }

                  // If still empty, fallback to master list (filtered)
                  final finalList = combined.isEmpty ? _filterOrganizations(_masterOrganizations) : combined;

                  if (finalList.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyStateWidget(onExpandSearch: _onExpandSearch),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final organization = finalList[index];
                      return OrganizationCardWidget(
                        organization: organization,
                        onTap: () => _onOrganizationTap(organization),
                        onCall: () => _onCallOrganization(organization),
                        onDirections: () => _onGetDirections(organization),
                        onFavorite: () => _onToggleFavorite(organization),
                      );
                    }, childCount: finalList.length),
                  );
                },
              ),
              
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onMapViewTap,
        backgroundColor: DonationAppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'map',
          color: DonationAppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: DonationAppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: DonationAppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: DonationAppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0 ? DonationAppTheme.lightTheme.colorScheme.primary : DonationAppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: _currentIndex == 1 ? DonationAppTheme.lightTheme.colorScheme.primary : DonationAppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'favorite',
              color: _currentIndex == 2 ? DonationAppTheme.lightTheme.colorScheme.primary : DonationAppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3 ? DonationAppTheme.lightTheme.colorScheme.primary : DonationAppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Reciepes',
          ),
        ],
      ),
    );
  }
}