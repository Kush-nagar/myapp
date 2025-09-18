import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  final AudioRecorder _audioRecorder = AudioRecorder();

  List<Map<String, dynamic>> _allOrganizations = [];
  List<Map<String, dynamic>> _filteredOrganizations = [];
  List<String> _recentSearches = [];
  Map<String, dynamic> _activeFilters = {};
  bool _isRecording = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _loadMockData() {
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

  void _performSearch(String query) {
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

    // Filter organizations based on search query and active filters
    List<Map<String, dynamic>> filtered = _allOrganizations.where((org) {
      bool matchesSearch = query.isEmpty ||
          (org['name'] as String).toLowerCase().contains(query.toLowerCase()) ||
          (org['type'] as String).toLowerCase().contains(query.toLowerCase()) ||
          (org['address'] as String)
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          (org['donationTypes'] as List).any((type) =>
              (type as String).toLowerCase().contains(query.toLowerCase()));

      return matchesSearch && _matchesFilters(org);
    }).toList();

    // Sort by distance
    filtered.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    setState(() {
      _filteredOrganizations = filtered;
      _isLoading = false;
    });
  }

  bool _matchesFilters(Map<String, dynamic> org) {
    // Organization type filter
    if (_activeFilters['organizationType'] != null &&
        (_activeFilters['organizationType'] as List).isNotEmpty) {
      if (!(_activeFilters['organizationType'] as List).contains(org['type'])) {
        return false;
      }
    }

    // Donation types filter
    if (_activeFilters['donationTypes'] != null &&
        (_activeFilters['donationTypes'] as List).isNotEmpty) {
      bool hasMatchingType = (org['donationTypes'] as List).any(
          (type) => (_activeFilters['donationTypes'] as List).contains(type));
      if (!hasMatchingType) return false;
    }

    // Distance filter
    if (_activeFilters['distance'] != null && _activeFilters['distance'] > 0) {
      if ((org['distance'] as double) > _activeFilters['distance']) {
        return false;
      }
    }

    // Open now filter
    if (_activeFilters['openNow'] == true && org['isOpenNow'] != true) {
      return false;
    }

    // High rating filter
    if (_activeFilters['highRating'] == true &&
        (org['rating'] as double) < 4.0) {
      return false;
    }

    return true;
  }

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

      // Mock voice recognition result
      String mockResult = 'food bank';
      _searchController.text = mockResult;
      _performSearch(mockResult);

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

  void _navigateToOrganizationDetail(Map<String, dynamic> organization) {
    Navigator.pushNamed(
      context,
      '/organization-detail-screen',
      arguments: organization,
    );
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
              onChanged: _performSearch,
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
