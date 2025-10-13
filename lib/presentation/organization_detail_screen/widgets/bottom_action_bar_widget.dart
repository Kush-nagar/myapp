import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';

class BottomActionBarWidget extends StatelessWidget {
  final Map<String, dynamic> organization;

  const BottomActionBarWidget({Key? key, required this.organization})
    : super(key: key);

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
    final Uri mapsUri = Uri.parse(
      'https://maps.google.com/?q=${Uri.encodeComponent(address)}',
    );
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
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: DonationAppTheme.lightTheme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 4.w, 5.w, 3.w),
          child: Row(
            children: [
              // Call Button - Primary Action
              Expanded(
                flex: hasWebsite ? 2 : 3,
                child: _buildPrimaryButton(
                  onPressed: _makePhoneCall,
                  icon: 'phone',
                  label: 'Call Now',
                  backgroundColor:
                      DonationAppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 3.w),

              // Directions Button - Secondary Action
              Expanded(
                flex: hasWebsite ? 2 : 3,
                child: _buildSecondaryButton(
                  onPressed: _openDirections,
                  icon: 'directions',
                  label: 'Directions',
                ),
              ),

              if (hasWebsite) ...[
                SizedBox(width: 3.w),
                // Website Button - Tertiary Action
                Expanded(
                  flex: 1,
                  child: _buildTertiaryButton(
                    onPressed: _visitWebsite,
                    icon: 'language',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      height: 12.w,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: icon, color: foregroundColor, size: 5.w),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                label,
                style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
  }) {
    return Container(
      height: 12.w,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: DonationAppTheme.lightTheme.colorScheme.surface,
          foregroundColor: DonationAppTheme.lightTheme.colorScheme.primary,
          side: BorderSide(
            color: DonationAppTheme.lightTheme.colorScheme.primary.withOpacity(
              0.3,
            ),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: DonationAppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                label,
                style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTertiaryButton({
    required VoidCallback onPressed,
    required String icon,
  }) {
    return Container(
      height: 12.w,
      width: 12.w,
      child: Material(
        color: DonationAppTheme.lightTheme.colorScheme.primaryContainer
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DonationAppTheme.lightTheme.colorScheme.primary
                    .withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: DonationAppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
