import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/mock_organizations.dart';
import './widgets/about_section_widget.dart';
import './widgets/bottom_action_bar_widget.dart';
import './widgets/current_needs_widget.dart';
import './widgets/donation_guidelines_widget.dart';
import './widgets/hours_contact_widget.dart';
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
  bool _loadError = false;

  Map<String, dynamic>? _organizationData;

  // --- STATUS: state + options + color mapping
  String _orgStatus = 'Not started';
  static const List<String> _statusOptions = [
    'Not started',
    'In progress',
    'Completed',
  ];
  static const Map<String, Color> _statusColors = {
    'Not started': Color.fromARGB(255, 0, 153, 255),
    'In progress': Color(0xFFFFA726), // amber/orange
    'Completed': Color(0xFF66BB6A), // green
  };
  // --- END STATUS

  // Get a random organization from mock data as fallback/default
  Map<String, dynamic> _getRandomMockOrganization() {
    final random = Random();
    final randomOrg =
        mockOrganizations[random.nextInt(mockOrganizations.length)];

    // Convert mockId to id for consistency with existing code
    final org = Map<String, dynamic>.from(randomOrg);
    org['id'] = org['mockId'];

    return org;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrganizationData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 180;
    if (shouldShow != _showStickyHeader) {
      setState(() {
        _showStickyHeader = shouldShow;
      });
    }
  }

  /// Preferential address extraction from incoming args
  String? _extractAddress(Map<String, dynamic> args) {
    if (args.isEmpty) return null;

    // 1) contact.address
    if (args['contact'] is Map) {
      final contact = args['contact'] as Map;
      final addr = contact['address']?.toString();
      if (addr != null && addr.isNotEmpty) return addr;
    }

    // 2) address
    final address = args['address']?.toString();
    if (address != null && address.isNotEmpty) return address;

    // 3) vicinity (Google Places short address)
    final vicinity = args['vicinity']?.toString();
    if (vicinity != null && vicinity.isNotEmpty) return vicinity;

    // 4) formatted_address (Places API)
    final formatted = args['formatted_address']?.toString();
    if (formatted != null && formatted.isNotEmpty) return formatted;

    // 5) location string (some sources)
    final location = args['location']?.toString();
    if (location != null && location.isNotEmpty) return location;

    return null;
  }

  Map<String, dynamic> _mergeArgs(Map<String, dynamic> args) {
    final combined = Map<String, dynamic>.from(_getRandomMockOrganization());

    // Copy top-level straightforward fields if provided
    final copyKeys = [
      'id',
      'name',
      'image',
      'photo', // alternate photo key
      'rating',
      'distance',
      'description',
      'services',
      'currentNeeds',
      'donationGuidelines',
      'hours',
      'reviews',
      'phone',
      'website', // keep website here for direct override
    ];

    for (final k in copyKeys) {
      if (args.containsKey(k) &&
          args[k] != null &&
          args[k].toString().isNotEmpty) {
        combined[k] = args[k];
      }
    }

    // Priority: use 'image' from args if present (Firebase Storage URL from Firestore)
    // then fall back to 'logo' field (for backwards compatibility with Places API data)
    if (args['image'] != null && args['image'].toString().isNotEmpty) {
      combined['image'] = args['image'];
    } else if (args['logo'] != null && args['logo'].toString().isNotEmpty) {
      combined['image'] = args['logo'];
    }

    // Merge/override contact map sensibly
    final existingContact = <String, dynamic>{};
    if (combined['contact'] is Map) {
      existingContact.addAll(Map<String, dynamic>.from(combined['contact']));
    }

    if (args['contact'] is Map) {
      existingContact.addAll(Map<String, dynamic>.from(args['contact'] as Map));
    } else {
      // top-level phone / website -> contact
      if (args['phone'] != null && args['phone'].toString().isNotEmpty) {
        existingContact['phone'] = args['phone'];
      }
      if (args['website'] != null && args['website'].toString().isNotEmpty) {
        existingContact['website'] = args['website'];
      }
    }

    // If args provide any address-like fields, use them to override contact.address
    final addrFromArgs = _extractAddress(args);
    if (addrFromArgs != null && addrFromArgs.isNotEmpty) {
      existingContact['address'] = addrFromArgs;
    } else if (args['address'] is String &&
        (args['address'] as String).isNotEmpty) {
      existingContact['address'] = args['address'];
    }

    // -- NEW: prefer website from args.contact or args top-level; ensure combined['website'] exists
    String? websiteFromArgs;
    if (args['contact'] is Map) {
      final contactArg = args['contact'] as Map;
      if (contactArg['website'] != null &&
          contactArg['website'].toString().isNotEmpty) {
        websiteFromArgs = contactArg['website'].toString();
      }
    }
    if (websiteFromArgs == null &&
        args['website'] != null &&
        args['website'].toString().isNotEmpty) {
      websiteFromArgs = args['website'].toString();
    }

    if (websiteFromArgs != null && websiteFromArgs.isNotEmpty) {
      existingContact['website'] = websiteFromArgs;
      combined['website'] = websiteFromArgs;
    } else {
      // if no website in args, keep whatever was in the mock combined map (if any)
      if (combined['contact'] is Map) {
        final cont = combined['contact'] as Map;
        if (cont['website'] != null && cont['website'].toString().isNotEmpty) {
          combined['website'] = cont['website'];
          existingContact['website'] = cont['website'];
        }
      } else if (combined['website'] != null) {
        existingContact['website'] = combined['website'];
      }
    }

    combined['contact'] = existingContact;

    // geometry/location lat/lng merging (optional)
    if (args['geometry'] is Map) {
      final geo = args['geometry'] as Map;
      if (geo['location'] is Map) {
        final loc = geo['location'] as Map;
        if (loc['lat'] != null && loc['lng'] != null) {
          combined['latitude'] = loc['lat'];
          combined['longitude'] = loc['lng'];
        }
      }
    } else {
      if (args['latitude'] != null && args['longitude'] != null) {
        combined['latitude'] = args['latitude'];
        combined['longitude'] = args['longitude'];
      }
    }

    return combined;
  }

  Future<void> _loadOrganizationData() async {
    setState(() {
      _isLoading = true;
      _loadError = false;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 650));
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args.isNotEmpty) {
        // Merge args into mock and ensure name & address reflect the tapped item
        _organizationData = _mergeArgs(args);
      } else {
        _organizationData = _getRandomMockOrganization();
      }

      await _loadFavoriteStatus();
      // --- STATUS: load saved status for this organization
      await _loadOrgStatus();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load org error: $e');
      setState(() {
        _loadError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_organizations') ?? [];
    final id = _organizationData != null
        ? (_organizationData!['id']?.toString() ?? '')
        : '';

    setState(() {
      _isFavorite = id.isNotEmpty && favoriteIds.contains(id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_organizations') ?? [];
    final orgId = _organizationData != null
        ? (_organizationData!['id']?.toString() ?? '')
        : '';

    if (orgId.isEmpty) return;

    if (_isFavorite) {
      favoriteIds.remove(orgId);
    } else {
      favoriteIds.add(orgId);
    }

    await prefs.setStringList('favorite_organizations', favoriteIds);

    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareOrganization() async {
    final organization = _organizationData!;
    final contact = (organization['contact'] as Map<String, dynamic>?) ?? {};

    final shareText =
        '''
Check out ${organization['name']}! ${organization['rating'] != null ? 'Rating: ${organization['rating']}/5 ⭐\n' : ''}
${organization['distance'] != null ? 'Distance: ${organization['distance']}\n' : ''}
Contact: ${contact['phone'] ?? '—'}
Address: ${contact['address'] ?? '—'}
${contact['website'] != null ? '\nWebsite: ${contact['website']}' : ''}
Shared via FoodBridge App
'''
            .trim();

    await Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Organization details copied to clipboard')),
    );
  }

  // --- STATUS: load and save methods
  Future<void> _loadOrgStatus() async {
    if (_organizationData == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'org_status_${_organizationData!['id']?.toString() ?? ''}';
    final saved = prefs.getString(key);
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _orgStatus = saved;
      });
    } else {
      setState(() {
        _orgStatus = 'Not started';
      });
    }
  }

  Future<void> _saveOrgStatus(String status) async {
    if (_organizationData == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'org_status_${_organizationData!['id']?.toString() ?? ''}';
    await prefs.setString(key, status);
    setState(() {
      _orgStatus = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated: $status'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  // --- END STATUS

  Widget _buildLoadingState() {
    // simple skeleton placeholders
    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 28.h,
              color: DonationAppTheme.lightTheme.colorScheme.surface,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 12.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: DonationAppTheme
                          .lightTheme
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(height: 2.h),
                itemBuilder: (_, __) => Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: DonationAppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  height: 18.h,
                ),
              ),
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
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: DonationAppTheme.lightTheme.colorScheme.error,
                size: 18.w,
              ),
              SizedBox(height: 3.h),
              Text(
                'Couldn’t load details',
                style: DonationAppTheme.lightTheme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Please check your internet connection or try again later.',
                style: DonationAppTheme.lightTheme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _loadError = false;
                      });
                      _loadOrganizationData();
                    },
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text('Retry'),
                  ),
                  SizedBox(width: 4.w),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    label: const Text('Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final imageUrl = _organizationData?['image'] as String? ?? '';
    final name = _organizationData?['name'] as String? ?? 'Organization';
    final rating = _organizationData?['rating'];
    final distance = _organizationData?['distance'];
    final address =
        (_organizationData?['contact'] as Map<String, dynamic>?)?['address'];

    return SliverAppBar(
      pinned: true,
      stretch: true,
      elevation: 0,
      expandedHeight: 34.h,
      backgroundColor: DonationAppTheme.lightTheme.colorScheme.surface,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: DonationAppTheme.lightTheme.colorScheme.onSurface,
          size: 6.w,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          onPressed: _toggleFavorite,
          icon: Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
              ],
            ),
            child: CustomIconWidget(
              iconName: _isFavorite ? 'favorite' : 'favorite_border',
              color: _isFavorite
                  ? Colors.red
                  : DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ),
          tooltip: _isFavorite ? 'Unfavorite' : 'Add to favorites',
        ),
        IconButton(
          onPressed: _shareOrganization,
          icon: Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
              ],
            ),
            child: CustomIconWidget(
              iconName: 'share',
              color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ),
          tooltip: 'Share',
        ),
        SizedBox(width: 2.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        centerTitle: false,
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showStickyHeader ? 1.0 : 0.0,
          child: Text(
            name,
            style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: DonationAppTheme.lightTheme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: DonationAppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.06),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: DonationAppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.06),
                ),
              )
            else
              Container(
                color: DonationAppTheme.lightTheme.colorScheme.onSurface
                    .withOpacity(0.06),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.05),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // Bottom badge area
            Positioned(
              left: 4.w,
              bottom: 3.h,
              right: 4.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: DonationAppTheme
                              .lightTheme
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (address != null) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            address,
                            style: DonationAppTheme
                                .lightTheme
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rating != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'star',
                                color: DonationAppTheme.getAccentColor(true),
                                size: 3.5.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                (rating is double)
                                    ? rating.toStringAsFixed(1)
                                    : rating.toString(),
                                style: DonationAppTheme
                                    .lightTheme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      if (distance != null) SizedBox(height: 1.h),
                      if (distance != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.8.h,
                          ),
                          decoration: BoxDecoration(
                            color: DonationAppTheme
                                .lightTheme
                                .colorScheme
                                .surface
                                .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            distance.toString(),
                            style: DonationAppTheme
                                .lightTheme
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }

  // --- STATUS: the actual dropdown widget (used inside a section card)
  Widget _buildStatusDropdown() {
    final color = _statusColors[_orgStatus] ?? Colors.grey;

    return Row(
      children: [
        // colored indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _orgStatus,
            items: _statusOptions
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _statusColors[s] ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(s),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              _saveOrgStatus(val);
            },
            decoration: InputDecoration(
              labelText: 'Organization status',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: DonationAppTheme.lightTheme.colorScheme.background,
            ),
          ),
        ),
      ],
    );
  }
  // --- END STATUS

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingState();
    if (_loadError || _organizationData == null) return _buildErrorState();

    // Use slivers for a smooth header + content scroll
    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildHeader(context),

              // Content: cards for each section for consistent visual hierarchy
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Column(
                    children: [
                      // --- STATUS: insert a small card with dropdown so each org has its own status
                      _sectionCard(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: _buildStatusDropdown(),
                        ),
                      ),

                      // About
                      _sectionCard(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: AboutSectionWidget(
                            organization: _organizationData!,
                          ),
                        ),
                      ),

                      // Current needs
                      _sectionCard(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: CurrentNeedsWidget(
                            organization: _organizationData!,
                          ),
                        ),
                      ),

                      // Donation Guidelines
                      _sectionCard(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: DonationGuidelinesWidget(
                            organization: _organizationData!,
                          ),
                        ),
                      ),

                      // Hours & Contact
                      _sectionCard(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: HoursContactWidget(
                            organization: _organizationData!,
                          ),
                        ),
                      ),

                      // Reviews
                      _sectionCard(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: ReviewsSectionWidget(
                            organization: _organizationData!,
                          ),
                        ),
                      ),

                      SizedBox(height: 14.h), // bottom spacing for action bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky header (reuses your widget for consistency)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: StickyHeaderWidget(
              organization: _organizationData!,
              isVisible: _showStickyHeader,
            ),
          ),

          // Bottom action bar (keeps your existing bottom bar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBarWidget(organization: _organizationData!),
          ),
        ],
      ),
    );
  }
}
