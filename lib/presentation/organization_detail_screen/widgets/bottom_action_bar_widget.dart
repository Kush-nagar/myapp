import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class BottomActionBarWidget extends StatelessWidget {
  final Map<String, dynamic> organization;

  const BottomActionBarWidget({
    Key? key,
    required this.organization,
  }) : super(key: key);

  Future<void> _makePhoneCall() async {
    final contact = organization['contact'] as Map<String, dynamic>;
    final Uri phoneUri = Uri(scheme: 'tel', path: contact['phone'] as String);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _openDirections() async {
    final contact = organization['contact'] as Map<String, dynamic>;
    final address = contact['address'] as String;
    final Uri mapsUri =
        Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _visitWebsite() async {
    final contact = organization['contact'] as Map<String, dynamic>;
    if (contact.containsKey('website')) {
      final Uri websiteUri = Uri.parse(contact['website'] as String);
      if (await canLaunchUrl(websiteUri)) {
        await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = organization['contact'] as Map<String, dynamic>;
    final hasWebsite = contact.containsKey('website');

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Call Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _makePhoneCall,
                icon: CustomIconWidget(
                  iconName: 'phone',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: Text(
                  'Call',
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DonationAppTheme.lightTheme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Directions Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openDirections,
                icon: CustomIconWidget(
                  iconName: 'directions',
                  color: DonationAppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                label: Text(
                  'Directions',
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  side: BorderSide(
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (hasWebsite) ...[
              SizedBox(width: 3.w),
              // Website Button
              Expanded(
                child: TextButton.icon(
                  onPressed: _visitWebsite,
                  icon: CustomIconWidget(
                    iconName: 'language',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  label: Text(
                    'Website',
                    style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
