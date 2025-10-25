import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../core/app_export.dart';
import './widgets/empty_favorites_widget.dart';
import '../home_screen/widgets/organization_card_widget.dart';
import './widgets/favorites_search_bar.dart';
import './widgets/sort_options_bottom_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isMultiSelectMode = false;
  Set<String> _selectedItems = {};
  String _currentSort = 'recent';
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _isLoading = true;
  DateTime _lastUpdated = DateTime.now();

  List<Map<String, dynamic>> _favoriteOrganizations = [];
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadFavorites();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload favorites when app comes back to foreground
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load favorite IDs from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _favoriteIds = prefs.getStringList('favorite_organizations') ?? [];

      if (_favoriteIds.isEmpty) {
        setState(() {
          _favoriteOrganizations = [];
          _isLoading = false;
        });
        return;
      }

      // Load organizations data from SharedPreferences
      final orgDataJson = prefs.getString('favorite_org_data') ?? '{}';
      final Map<String, dynamic> allOrgData = {};

      try {
        allOrgData.addAll(
          Map<String, dynamic>.from(jsonDecode(orgDataJson) as Map),
        );
      } catch (e) {
        debugPrint('Error parsing favorite org data: $e');
      }

      // Build the list of favorite organizations from stored data
      final List<Map<String, dynamic>> loadedOrgs = [];

      for (final orgId in _favoriteIds) {
        if (allOrgData.containsKey(orgId)) {
          final orgData = Map<String, dynamic>.from(allOrgData[orgId] as Map);
          orgData['isFavorited'] = true;
          loadedOrgs.add(orgData);
        }
      }

      setState(() {
        _favoriteOrganizations = loadedOrgs;
        _isLoading = false;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredOrganizations {
    var filtered = _favoriteOrganizations.where((org) {
      if (_searchQuery.isEmpty) return true;
      final name = (org['name'] as String? ?? '').toLowerCase();
      final address = (org['address'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || address.contains(query);
    }).toList();

    // Sort based on current sort option
    switch (_currentSort) {
      case 'recent':
        // Keep the order as loaded (most recently favorited first)
        break;
      case 'distance':
        filtered.sort((a, b) {
          final distA = a['distance'] as String? ?? '';
          final distB = b['distance'] as String? ?? '';
          if (distA.isEmpty) return 1;
          if (distB.isEmpty) return -1;

          try {
            double distanceA = double.parse(distA.split(' ')[0]);
            double distanceB = double.parse(distB.split(' ')[0]);
            return distanceA.compareTo(distanceB);
          } catch (e) {
            return 0;
          }
        });
        break;
      case 'alphabetical':
        filtered.sort(
          (a, b) => (a['name'] as String? ?? '').compareTo(
            b['name'] as String? ?? '',
          ),
        );
        break;
      case 'last_visited':
        // For now, keep current order
        break;
    }

    return filtered;
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadFavorites();

    setState(() {
      _isRefreshing = false;
    });

    Fluttertoast.showToast(
      msg: "Favorites updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _removeFromFavorites(String organizationId) async {
    try {
      // Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _favoriteIds.remove(organizationId);
      await prefs.setStringList('favorite_organizations', _favoriteIds);

      // Remove from local list
      setState(() {
        _favoriteOrganizations.removeWhere(
          (org) =>
              org['id'].toString() == organizationId ||
              org['mockId'].toString() == organizationId,
        );
      });

      Fluttertoast.showToast(
        msg: "Removed from favorites",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  void _callOrganization(Map<String, dynamic> organization) {
    // Simulate calling functionality
    Fluttertoast.showToast(
      msg: "Calling ${organization['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _getDirections(Map<String, dynamic> organization) {
    // Simulate directions functionality
    Fluttertoast.showToast(
      msg: "Getting directions to ${organization['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedItems.clear();
      }
    });
  }

  void _toggleSelection(String organizationId) {
    setState(() {
      if (_selectedItems.contains(organizationId)) {
        _selectedItems.remove(organizationId);
      } else {
        _selectedItems.add(organizationId);
      }
    });
  }

  Future<void> _removeSelectedItems() async {
    try {
      for (final orgId in _selectedItems) {
        await _removeFromFavorites(orgId);
      }

      setState(() {
        _selectedItems.clear();
        _isMultiSelectMode = false;
      });

      Fluttertoast.showToast(
        msg: "Removed selected items",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error removing selected items: $e');
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortOptionsBottomSheet(
        currentSort: _currentSort,
        onSortChanged: (sortOption) {
          setState(() {
            _currentSort = sortOption;
          });
        },
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrganizations = _filteredOrganizations;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isMultiSelectMode
              ? '${_selectedItems.length} selected'
              : 'Favorites',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          if (_isMultiSelectMode) ...[
            if (_selectedItems.isNotEmpty)
              IconButton(
                onPressed: _removeSelectedItems,
                icon: CustomIconWidget(
                  iconName: 'delete',
                  size: 24,
                  color: DonationAppTheme.lightTheme.colorScheme.error,
                ),
              ),
            IconButton(
              onPressed: _toggleMultiSelect,
              icon: CustomIconWidget(
                iconName: 'close',
                size: 24,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ] else ...[
            if (filteredOrganizations.isNotEmpty)
              IconButton(
                onPressed: _showSortOptions,
                icon: CustomIconWidget(
                  iconName: 'sort',
                  size: 24,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
          ],
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: DonationAppTheme.lightTheme.colorScheme.primary,
              ),
            )
          : filteredOrganizations.isEmpty
          ? EmptyFavoritesWidget(
              onDiscoverTap: () {
                Navigator.pushNamed(context, '/home-screen');
              },
            )
          : Column(
              children: [
                if (!_isMultiSelectMode)
                  FavoritesSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onClear: _clearSearch,
                  ),
                if (_isRefreshing)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              DonationAppTheme.lightTheme.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Updating...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshFavorites,
                    color: DonationAppTheme.lightTheme.primaryColor,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: filteredOrganizations.length,
                      itemBuilder: (context, index) {
                        final organization = filteredOrganizations[index];
                        final organizationId =
                            (organization['id'] ??
                                    organization['mockId'] ??
                                    index)
                                .toString();

                        return OrganizationCardWidget(
                          organization: organization,
                          onTap: () {
                            if (_isMultiSelectMode) {
                              _toggleSelection(organizationId);
                            } else {
                              Navigator.pushNamed(
                                context,
                                '/organization-detail-screen',
                                arguments: organization,
                              );
                            }
                          },
                          onCall: () => _callOrganization(organization),
                          onDirections: () => _getDirections(organization),
                          onFavorite: () =>
                              _removeFromFavorites(organizationId),
                        );
                      },
                    ),
                  ),
                ),
                if (!_isRefreshing)
                  Container(
                    padding: EdgeInsets.all(4.w),
                    child: Text(
                      'Last updated: ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}
