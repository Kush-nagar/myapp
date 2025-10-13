import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class HoursContactWidget extends StatefulWidget {
  final Map<String, dynamic> organization;

  const HoursContactWidget({Key? key, required this.organization})
    : super(key: key);

  @override
  State<HoursContactWidget> createState() => _HoursContactWidgetState();
}

class _HoursContactWidgetState extends State<HoursContactWidget> {
  bool isExpanded = false;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _openWebsite(BuildContext context, String? rawUrl) async {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No website available')));
      return;
    }

    String urlString = rawUrl.trim();
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid website URL')));
      return;
    }

    try {
      final can = await canLaunchUrl(uri);
      if (!can) {
        debugPrint('Cannot launch url: $uri');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No app available to open this link')),
        );
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('launchUrl returned false for $uri');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the website')),
        );
      }
    } catch (e, st) {
      debugPrint('openWebsite error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error opening website')));
    }
  }

  Future<void> _openMaps(String address) async {
    final Uri mapsUri = Uri.parse(
      'https://maps.google.com/?q=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  String _getCurrentDayStatus() {
    final now = DateTime.now();
    final dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final currentDay = dayNames[now.weekday - 1];
    final hours = widget.organization['hours'] as Map<String, dynamic>;

    if (hours.containsKey(currentDay)) {
      final todayHours = hours[currentDay] as String;
      if (todayHours.toLowerCase() == 'closed') {
        return 'Closed Today';
      } else {
        return 'Open Today: $todayHours';
      }
    }
    return 'Hours Not Available';
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.organization['contact'] as Map<String, dynamic>;
    final hours = widget.organization['hours'] as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Hours & Contact',
                        style: DonationAppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            // Current Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: DonationAppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getCurrentDayStatus(),
                style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (isExpanded) ...[
              SizedBox(height: 2.h),
              // Operating Hours
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: DonationAppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: DonationAppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operating Hours',
                      style: DonationAppTheme.lightTheme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 1.h),
                    ...hours.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key.toString().toUpperCase(),
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              entry.value as String,
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              // Contact Information
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: DonationAppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: DonationAppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: DonationAppTheme.lightTheme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 1.h),
                    // Phone
                    GestureDetector(
                      onTap: () => _makePhoneCall(contact['phone'] as String),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'phone',
                            color:
                                DonationAppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              contact['phone'] as String,
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: DonationAppTheme
                                        .lightTheme
                                        .colorScheme
                                        .primary,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Address
                    GestureDetector(
                      onTap: () => _openMaps(contact['address'] as String),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color:
                                DonationAppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              contact['address'] as String,
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: DonationAppTheme
                                        .lightTheme
                                        .colorScheme
                                        .primary,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (contact.containsKey('website')) ...[
                      SizedBox(height: 1.h),
                      // Website
                      GestureDetector(
                        onTap: () =>
                            _openWebsite(context, contact['website'] as String),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'language',
                              color: DonationAppTheme
                                  .lightTheme
                                  .colorScheme
                                  .primary,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                'Visit Website',
                                style: DonationAppTheme
                                    .lightTheme
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: DonationAppTheme
                                          .lightTheme
                                          .colorScheme
                                          .primary,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
