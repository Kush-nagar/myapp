import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_favorites_widget.dart';
import './widgets/favorite_organization_card.dart';
import './widgets/favorites_search_bar.dart';
import './widgets/sort_options_bottom_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isMultiSelectMode = false;
  Set<int> _selectedItems = {};
  String _currentSort = 'recent';
  String _searchQuery = '';
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for favorite organizations
  final List<Map<String, dynamic>> _favoriteOrganizations = [
    {
      "id": 1,
      "name": "City Food Bank",
      "logo":
          "https://images.pexels.com/photos/6646918/pexels-photo-6646918.jpeg?auto=compress&cs=tinysrgb&w=400",
      "distance": "0.8 miles",
      "lastVisit": "2 days ago",
      "isOpen": true,
      "phone": "+1 (555) 123-4567",
      "website": "https://cityfoodbank.org",
      "address": "123 Main St, City, State 12345",
      "donationType": "Food",
      "addedDate": DateTime.now().subtract(Duration(days: 5)),
      "lastVisitDate": DateTime.now().subtract(Duration(days: 2)),
    },
    {
      "id": 2,
      "name": "Hope Shelter",
      "logo":
          "https://images.pexels.com/photos/6646919/pexels-photo-6646919.jpeg?auto=compress&cs=tinysrgb&w=400",
      "distance": "1.2 miles",
      "lastVisit": "1 week ago",
      "isOpen": false,
      "phone": "+1 (555) 234-5678",
      "website": "https://hopeshelter.org",
      "address": "456 Oak Ave, City, State 12345",
      "donationType": "Clothing",
      "addedDate": DateTime.now().subtract(Duration(days: 12)),
      "lastVisitDate": DateTime.now().subtract(Duration(days: 7)),
    },
    {
      "id": 3,
      "name": "Community Kitchen",
      "logo":
          "https://images.pexels.com/photos/6646920/pexels-photo-6646920.jpeg?auto=compress&cs=tinysrgb&w=400",
      "distance": "2.1 miles",
      "lastVisit": "3 days ago",
      "isOpen": true,
      "phone": "+1 (555) 345-6789",
      "website": "https://communitykitchen.org",
      "address": "789 Pine St, City, State 12345",
      "donationType": "Food",
      "addedDate": DateTime.now().subtract(Duration(days: 8)),
      "lastVisitDate": DateTime.now().subtract(Duration(days: 3)),
    },
    {
      "id": 4,
      "name": "Helping Hands Foundation",
      "logo":
          "https://images.pexels.com/photos/6646921/pexels-photo-6646921.jpeg?auto=compress&cs=tinysrgb&w=400",
      "distance": "3.5 miles",
      "lastVisit": "Never",
      "isOpen": true,
      "phone": "+1 (555) 456-7890",
      "website": "https://helpinghands.org",
      "address": "321 Elm St, City, State 12345",
      "donationType": "General",
      "addedDate": DateTime.now().subtract(Duration(days: 1)),
      "lastVisitDate": null,
    },
  ];

  List<Map<String, dynamic>> get _filteredOrganizations {
    var filtered = _favoriteOrganizations.where((org) {
      if (_searchQuery.isEmpty) return true;
      return (org['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (org['donationType'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort based on current sort option
    switch (_currentSort) {
      case 'recent':
        filtered.sort((a, b) =>
            (b['addedDate'] as DateTime).compareTo(a['addedDate'] as DateTime));
        break;
      case 'distance':
        filtered.sort((a, b) {
          double distanceA =
              double.parse((a['distance'] as String).split(' ')[0]);
          double distanceB =
              double.parse((b['distance'] as String).split(' ')[0]);
          return distanceA.compareTo(distanceB);
        });
        break;
      case 'alphabetical':
        filtered.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case 'last_visited':
        filtered.sort((a, b) {
          DateTime? dateA = a['lastVisitDate'] as DateTime?;
          DateTime? dateB = b['lastVisitDate'] as DateTime?;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        break;
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });

    Fluttertoast.showToast(
      msg: "Favorites updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _removeFromFavorites(int organizationId) {
    setState(() {
      _favoriteOrganizations.removeWhere((org) => org['id'] == organizationId);
    });

    Fluttertoast.showToast(
      msg: "Removed from favorites",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareOrganization(Map<String, dynamic> organization) {
    // Simulate sharing functionality
    Fluttertoast.showToast(
      msg: "Sharing ${organization['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
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

  void _visitWebsite(Map<String, dynamic> organization) {
    // Simulate website visit
    Fluttertoast.showToast(
      msg: "Opening ${organization['name']} website",
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

  void _toggleSelection(int organizationId) {
    setState(() {
      if (_selectedItems.contains(organizationId)) {
        _selectedItems.remove(organizationId);
      } else {
        _selectedItems.add(organizationId);
      }
    });
  }

  void _removeSelectedItems() {
    setState(() {
      _favoriteOrganizations
          .removeWhere((org) => _selectedItems.contains(org['id']));
      _selectedItems.clear();
      _isMultiSelectMode = false;
    });

    Fluttertoast.showToast(
      msg: "Removed selected items",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
      body: filteredOrganizations.isEmpty
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
                        final organizationId = organization['id'] as int;

                        return FavoriteOrganizationCard(
                          organization: organization,
                          isSelected: _selectedItems.contains(organizationId),
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
                          onLongPress: () {
                            if (!_isMultiSelectMode) {
                              _toggleMultiSelect();
                              _toggleSelection(organizationId);
                            }
                          },
                          onRemove: () => _removeFromFavorites(organizationId),
                          onShare: () => _shareOrganization(organization),
                          onCall: () => _callOrganization(organization),
                          onDirections: () => _getDirections(organization),
                          onWebsite: () => _visitWebsite(organization),
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
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}
