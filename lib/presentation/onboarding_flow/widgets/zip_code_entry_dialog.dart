import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ZipCodeEntryDialog extends StatefulWidget {
  final Function(String) onZipCodeEntered;
  final VoidCallback onCancel;

  const ZipCodeEntryDialog({
    Key? key,
    required this.onZipCodeEntered,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ZipCodeEntryDialog> createState() => _ZipCodeEntryDialogState();
}

class _ZipCodeEntryDialogState extends State<ZipCodeEntryDialog> {
  final TextEditingController _zipController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _zipController.addListener(_validateZipCode);
  }

  void _validateZipCode() {
    final zipCode = _zipController.text.trim();
    final isValid = RegExp(r'^\d{5}(-\d{4})?$').hasMatch(zipCode);
    if (_isValid != isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'edit_location',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 8.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Enter Your ZIP Code',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Please enter your ZIP code to find food donation organizations in your area.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: _zipController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'ZIP Code',
                hintText: 'e.g., 12345 or 12345-6789',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'location_city',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                            color: AppTheme
                                .lightTheme
                                .colorScheme
                                .onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isValid
                        ? () => widget.onZipCodeEntered(
                            _zipController.text.trim(),
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValid
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
