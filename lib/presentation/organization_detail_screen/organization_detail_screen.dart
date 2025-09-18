import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/about_section_widget.dart';
import './widgets/bottom_action_bar_widget.dart';
import './widgets/current_needs_widget.dart';
import './widgets/donation_guidelines_widget.dart';
import './widgets/hours_contact_widget.dart';
import './widgets/organization_header_widget.dart';
import './widgets/reviews_section_widget.dart';
import './widgets/sticky_header_widget.dart';

class OrganizationDetailScreen extends StatefulWidget {
  const OrganizationDetailScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;
  bool _isFavorite = false;
  bool _isLoading = true;
  Map<String, dynamic>? _organizationData;

  // Mock organization data
  final Map<String, dynamic> _mockOrganization = {
    "id": 1,
    "name": "Community Food Bank of Greater Springfield",
    "image":
        "https://images.unsplash.com/photo-1593113598332-cd288d649433?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "rating": 4.8,
    "distance": "2.3 miles",
    "description":
        """The Community Food Bank of Greater Springfield has been serving our local community for over 25 years, providing essential food assistance to families in need. Our mission is to alleviate hunger and promote food security through comprehensive programs that address both immediate needs and long-term solutions.

We operate with the belief that access to nutritious food is a basic human right. Our dedicated team of volunteers and staff work tirelessly to collect, sort, and distribute food donations to partner agencies, soup kitchens, and directly to families facing food insecurity.

Beyond food distribution, we offer nutrition education programs, cooking classes, and community garden initiatives that empower individuals and families to make healthy choices and develop sustainable food practices.""",
    "services": [
      "Food Distribution",
      "Nutrition Education",
      "Community Garden",
      "Emergency Relief",
      "Senior Programs"
    ],
    "currentNeeds": [
      {
        "item": "Canned Vegetables",
        "priority": "urgent",
        "description":
            "Low sodium varieties preferred. Corn, green beans, and mixed vegetables are most needed.",
        "quantity": "500+ cans"
      },
      {
        "item": "Baby Formula",
        "priority": "high",
        "description":
            "Unopened containers only. All brands accepted for infants 0-12 months.",
        "quantity": "50+ containers"
      },
      {
        "item": "Rice and Pasta",
        "priority": "medium",
        "description":
            "Bulk quantities of rice, pasta, and other shelf-stable grains.",
        "quantity": "200+ lbs"
      },
      {
        "item": "Personal Hygiene Items",
        "priority": "medium",
        "description":
            "Toothbrushes, toothpaste, soap, shampoo, and feminine hygiene products.",
        "quantity": "100+ items"
      },
      {
        "item": "Winter Clothing",
        "priority": "low",
        "description":
            "Clean, gently used coats, hats, gloves, and warm clothing for all ages.",
        "quantity": "Various sizes"
      }
    ],
    "donationGuidelines": {
      "acceptedItems": [
        "Non-perishable food",
        "Canned goods",
        "Baby formula",
        "Personal care items",
        "Cleaning supplies",
        "New clothing",
        "Monetary donations"
      ],
      "restrictions": [
        "No expired food",
        "No homemade items",
        "No opened containers",
        "No alcohol or tobacco",
        "No damaged goods",
        "No used undergarments"
      ],
      "procedures": [
        "Call ahead to schedule large donations",
        "Bring donations to the main entrance during operating hours",
        "Check in with reception desk upon arrival",
        "Volunteers will help unload and sort donations",
        "Donation receipt available upon request for tax purposes"
      ]
    },
    "hours": {
      "monday": "9:00 AM - 5:00 PM",
      "tuesday": "9:00 AM - 5:00 PM",
      "wednesday": "9:00 AM - 7:00 PM",
      "thursday": "9:00 AM - 5:00 PM",
      "friday": "9:00 AM - 5:00 PM",
      "saturday": "8:00 AM - 2:00 PM",
      "sunday": "Closed"
    },
    "contact": {
      "phone": "(555) 123-4567",
      "email": "info@springfieldfoodbank.org",
      "address": "1234 Community Drive, Springfield, IL 62701",
      "website": "https://www.springfieldfoodbank.org"
    },
    "reviews": [
      {
        "userName": "Sarah Johnson",
        "rating": 5,
        "date": "2 weeks ago",
        "comment":
            "Amazing organization! The staff is incredibly helpful and compassionate. They made a difficult time in our lives much easier to manage."
      },
      {
        "userName": "Michael Chen",
        "rating": 5,
        "date": "1 month ago",
        "comment":
            "I volunteer here regularly and it's inspiring to see the impact we make in the community. Well-organized and efficient operations."
      },
      {
        "userName": "Lisa Rodriguez",
        "rating": 4,
        "date": "1 month ago",
        "comment":
            "Great place to donate food and volunteer. The only suggestion would be extended weekend hours for working families."
      },
      {
        "userName": "David Thompson",
        "rating": 5,
        "date": "2 months ago",
        "comment":
            "Professional and caring staff. They treat everyone with dignity and respect. Highly recommend supporting this organization."
      },
      {
        "userName": "Jennifer Wilson",
        "rating": 5,
        "date": "2 months ago",
        "comment":
            "The nutrition education programs are excellent. My family learned so much about healthy eating on a budget."
      },
      {
        "userName": "Robert Martinez",
        "rating": 4,
        "date": "3 months ago",
        "comment":
            "Clean facility with organized distribution process. Wait times can be long during peak hours but staff does their best."
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrganizationData();
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 200;
    if (shouldShow != _showStickyHeader) {
      setState(() {
        _showStickyHeader = shouldShow;
      });
    }
  }

  Future<void> _loadOrganizationData() async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 1500));

    setState(() {
      _organizationData = _mockOrganization;
      _isLoading = false;
    });
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_organizations') ?? [];
    setState(() {
      _isFavorite = favoriteIds.contains(_mockOrganization['id'].toString());
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_organizations') ?? [];
    final orgId = _mockOrganization['id'].toString();

    if (_isFavorite) {
      favoriteIds.remove(orgId);
    } else {
      favoriteIds.add(orgId);
    }

    await prefs.setStringList('favorite_organizations', favoriteIds);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareOrganization() async {
    final organization = _organizationData!;
    final shareText = '''
Check out ${organization['name']}!

Rating: ${organization['rating']}/5 ⭐
Distance: ${organization['distance']}

Contact: ${(organization['contact'] as Map<String, dynamic>)['phone']}
Address: ${(organization['contact'] as Map<String, dynamic>)['address']}

${(organization['contact'] as Map<String, dynamic>).containsKey('website') ? 'Website: ${(organization['contact'] as Map<String, dynamic>)['website']}' : ''}

Shared via FoodBridge App
    '''
        .trim();

    await Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Organization details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: DonationAppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading organization details...',
              style: DonationAppTheme.lightTheme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: DonationAppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: DonationAppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: DonationAppTheme.lightTheme.colorScheme.error,
                size: 15.w,
              ),
              SizedBox(height: 2.h),
              Text(
                'Unable to load organization details',
                style: DonationAppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Please check your internet connection and try again.',
                style: DonationAppTheme.lightTheme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _organizationData = null;
                  });
                  _loadOrganizationData();
                },
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_organizationData == null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header with hero image
              SliverToBoxAdapter(
                child: OrganizationHeaderWidget(
                  organization: _organizationData!,
                  isFavorite: _isFavorite,
                  onFavoriteToggle: _toggleFavorite,
                  onShare: _shareOrganization,
                ),
              ),
              // Content sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    AboutSectionWidget(organization: _organizationData!),
                    CurrentNeedsWidget(organization: _organizationData!),
                    DonationGuidelinesWidget(organization: _organizationData!),
                    HoursContactWidget(organization: _organizationData!),
                    ReviewsSectionWidget(organization: _organizationData!),
                    SizedBox(height: 12.h), // Space for bottom action bar
                  ],
                ),
              ),
            ],
          ),
          // Sticky header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: StickyHeaderWidget(
              organization: _organizationData!,
              isVisible: _showStickyHeader,
            ),
          ),
          // Bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBarWidget(
              organization: _organizationData!,
            ),
          ),
        ],
      ),
    );
  }
}
