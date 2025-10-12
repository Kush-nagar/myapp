import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/offline_banner_widget.dart';
import './widgets/organization_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/urgent_needs_banner_widget.dart';

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

  final List<Map<String, dynamic>> _organizations = [
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
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _checkConnectivity();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
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
              style: DonationAppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                // Handle location permission and update
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Calling $phone")),
      );
    }
  }

  void _onGetDirections(Map<String, dynamic> organization) {
    Navigator.pushNamed(context, '/map-view-screen', arguments: organization);
  }

  void _onToggleFavorite(Map<String, dynamic> organization) {
    setState(() {
      final index =
          _organizations.indexWhere((org) => org["id"] == organization["id"]);
      if (index != -1) {
        _organizations[index]["isFavorited"] =
            !(_organizations[index]["isFavorited"] ?? false);
      }
    });
  }

  void _onExpandSearch() {
    Navigator.pushNamed(context, '/search-filter-screen');
  }

  void _onMapViewTap() {
    Navigator.pushNamed(context, '/map-view-screen');
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
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    SearchBarWidget(
                      currentLocation: _currentLocation,
                      onSearchTap: _onSearchTap,
                      onLocationTap: _onLocationTap,
                    ),
                    if (!_isOnline) ...[
                      OfflineBannerWidget(lastUpdated: _lastUpdated),
                    ],
                    SizedBox(height: 2.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          "Urgent Needs",
                          style: DonationAppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    UrgentNeedsBannerWidget(),
                    SizedBox(height: 3.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nearby Organizations",
                            style: DonationAppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  DonationAppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
              _isLoading
                  ? SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: DonationAppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : _organizations.isEmpty
                      ? SliverFillRemaining(
                          child: EmptyStateWidget(
                            onExpandSearch: _onExpandSearch,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final organization = _organizations[index];
                              return OrganizationCardWidget(
                                organization: organization,
                                onTap: () => _onOrganizationTap(organization),
                                onCall: () => _onCallOrganization(organization),
                                onDirections: () =>
                                    _onGetDirections(organization),
                                onFavorite: () =>
                                    _onToggleFavorite(organization),
                              );
                            },
                            childCount: _organizations.length,
                          ),
                        ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
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
        unselectedItemColor:
            DonationAppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0
                  ? DonationAppTheme.lightTheme.colorScheme.primary
                  : DonationAppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'search',
              color: _currentIndex == 1
                  ? DonationAppTheme.lightTheme.colorScheme.primary
                  : DonationAppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'favorite',
              color: _currentIndex == 2
                  ? DonationAppTheme.lightTheme.colorScheme.primary
                  : DonationAppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3
                  ? DonationAppTheme.lightTheme.colorScheme.primary
                  : DonationAppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 24,
            ),
            label: 'Reciepes',
          ),
        ],
      ),
    );
  }
}
