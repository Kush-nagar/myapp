// lib/presentation/get_organization_data/get_organization_data.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_routes.dart';

class GetOrganizationDataScreen extends StatefulWidget {
  const GetOrganizationDataScreen({Key? key}) : super(key: key);

  @override
  State<GetOrganizationDataScreen> createState() =>
      _GetOrganizationDataScreenState();
}

class NeedItem {
  String item;
  String priority; // low, medium, high
  String description;
  String customDescription; // used if description == 'Custom'
  String quantity;

  NeedItem({
    this.item = '',
    this.priority = 'low',
    this.description = 'Fresh, unbruised',
    this.customDescription = '',
    this.quantity = '',
  });

  Map<String, dynamic> toMap() => {
    'item': item.trim(),
    'priority': priority,
    'description': description == 'Custom'
        ? customDescription.trim()
        : description,
    'quantity': quantity.trim(),
  };
}

class _GetOrganizationDataScreenState extends State<GetOrganizationDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final ratingCtrl = TextEditingController(text: '3.6');
  final distanceCtrl = TextEditingController(text: '1.0');
  final descriptionCtrl = TextEditingController();
  final servicesCtrl = TextEditingController(
    text: 'Holiday Meal Boxes,SNAP Enrollment Help,Cooking Classes',
  );
  // keep needsCtrl as legacy: we parse default if present, but UI uses _needsList
  final needsCtrl = TextEditingController(
    text:
        'Fresh Produce|low|Fresh, unbruised|14,Toilet Paper|medium|Toilet Paper - sealed|194',
  );
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();

  bool _saving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // The in-memory editable list (used by UI)
  final List<NeedItem> _needsList = [];

  // Common descriptions for the dropdown
  final List<String> _commonDescriptions = [
    'Fresh, unbruised',
    'Sealed packaging',
    'Unopened/packaged',
    'Toilet Paper - sealed',
    'Child-proof packaging',
    'No glass containers',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _initNeedsFromRaw(needsCtrl.text);
  }

  void _initNeedsFromRaw(String raw) {
    _needsList.clear();
    if (raw.trim().isEmpty) {
      // start with one empty row
      _needsList.add(NeedItem());
      return;
    }

    // Parse the legacy format: item|priority|description|quantity, ...
    final parts = raw.split(',');
    for (final p in parts) {
      final fields = p.split('|').map((s) => s.trim()).toList();
      if (fields.length >= 4) {
        final desc = fields[2];
        final isCommon = _commonDescriptions.contains(desc);
        final need = NeedItem(
          item: fields[0],
          priority: fields[1].isNotEmpty ? fields[1] : 'low',
          description: isCommon ? desc : 'Custom',
          customDescription: isCommon ? '' : desc,
          quantity: fields[3],
        );
        _needsList.add(need);
      }
    }

    if (_needsList.isEmpty) _needsList.add(NeedItem());
  }

  void _addNeedRow() {
    setState(() {
      _needsList.add(NeedItem());
    });
  }

  void _removeNeedRow(int index) {
    if (_needsList.length == 1) {
      // keep at least one row
      setState(() {
        _needsList[0] = NeedItem();
      });
      return;
    }
    setState(() {
      _needsList.removeAt(index);
    });
  }

  bool _validateNeeds() {
    // ensure at least one meaningful need and required fields present
    for (final need in _needsList) {
      if (need.item.trim().isEmpty) return false;
      if (need.quantity.trim().isEmpty) return false;
      if (need.description == 'Custom' &&
          need.customDescription.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          imageCtrl.text = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('organization_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(_selectedImage!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
      return null;
    }
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final needsValid = _validateNeeds();
    if (!formValid || !needsValid) {
      if (!needsValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all needs rows (item & quantity).'),
          ),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not signed in')));
      return;
    }

    setState(() => _saving = true);

    // Upload image if selected
    String? uploadedImageUrl;
    if (_selectedImage != null) {
      uploadedImageUrl = await _uploadImage();
      if (uploadedImageUrl == null && mounted) {
        setState(() => _saving = false);
        return;
      }
    }

    final docRef = FirebaseFirestore.instance
        .collection('organizations')
        .doc(user.uid);

    final data = {
      'mockId': DateTime.now().millisecondsSinceEpoch,
      'name': nameCtrl.text.trim(),
      'image':
          uploadedImageUrl ??
          (imageCtrl.text.trim().isEmpty
              ? 'https://images.unsplash.com/photo-1546554137-f86b9593a222?auto=format&fit=crop&w=1400&q=60'
              : imageCtrl.text.trim()),
      'rating': double.tryParse(ratingCtrl.text) ?? 3.6,
      'distance': double.tryParse(distanceCtrl.text) ?? 1.0,
      'description': descriptionCtrl.text.trim(),
      'services': servicesCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'currentNeeds': _needsList.map((n) => n.toMap()).toList(),
      'donationGuidelines': {
        'acceptedItems': [
          'Baby supplies',
          'Dry goods',
          'Canned goods',
          'Bottled water',
        ],
        'restrictions': [
          'Securely sealed packages only',
          'No home-cooked perishable foods',
        ],
        'procedures': ['Drop off at front desk', 'Book pickup online'],
      },
      'contact': {
        'phone': phoneCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'website': websiteCtrl.text.trim(),
      },
      'ownerUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(data);
      if (mounted) {
        setState(() => _saving = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showSuccessDialog() {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.9),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 42,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Successfully Saved!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Your organization profile has been uploaded and saved successfully.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Stay Here',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.home);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Go to Home',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.9),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 42,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Save Failed',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Error Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'An error occurred while saving your organization profile.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 60),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          error,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: theme.colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    imageCtrl.dispose();
    ratingCtrl.dispose();
    distanceCtrl.dispose();
    descriptionCtrl.dispose();
    servicesCtrl.dispose();
    needsCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    websiteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Organization Profile',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _saving
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Saving organization details...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: 24,
                left: size.width * 0.02,
                right: size.width * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.08),
                            theme.colorScheme.primary.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.business,
                                  size: 28,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Organization Information',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Complete your profile details',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.65),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Basic Information Card
                    _buildSectionCard(
                      context,
                      title: 'Basic Information',
                      icon: Icons.info_outline,
                      children: [
                        _buildTextField(
                          controller: nameCtrl,
                          label: 'Organization Name',
                          hint: 'e.g., Community Food Bank',
                          icon: Icons.label_outline,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        // Image Upload Section
                        _buildImageUploadSection(),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: ratingCtrl,
                                label: 'Rating',
                                hint: '3.6',
                                icon: Icons.star_outline,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: distanceCtrl,
                                label: 'Distance (km)',
                                hint: '1.0',
                                icon: Icons.location_on_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: descriptionCtrl,
                          label: 'Description',
                          hint: 'Brief description of your organization',
                          icon: Icons.description_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),

                    // Services & Needs Card
                    _buildSectionCard(
                      context,
                      title: 'Services & Needs',
                      icon: Icons.category_outlined,
                      children: [
                        _buildTextField(
                          controller: servicesCtrl,
                          label: 'Services Offered',
                          hint: 'Separate with commas',
                          icon: Icons.handshake_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        // New Needs Editor
                        _buildNeedsEditor(),
                      ],
                    ),

                    // Contact Information Card
                    _buildSectionCard(
                      context,
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                      children: [
                        _buildTextField(
                          controller: phoneCtrl,
                          label: 'Phone Number',
                          hint: '+1 (555) 123-4567',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: emailCtrl,
                          label: 'Email Address',
                          hint: 'contact@organization.org',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: addressCtrl,
                          label: 'Physical Address',
                          hint: '123 Main St, City, State ZIP',
                          icon: Icons.location_city_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: websiteCtrl,
                          label: 'Website',
                          hint: 'https://www.organization.org',
                          icon: Icons.language_outlined,
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_outlined, size: 22),
                          label: const Text(
                            'Save Organization Profile',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            shadowColor: theme.colorScheme.primary.withOpacity(
                              0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildImageUploadSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organization Image',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedImage != null
                        ? 'Image selected'
                        : 'Upload an image or enter URL below',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    imageCtrl.clear();
                  });
                },
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: imageCtrl,
          decoration: InputDecoration(
            labelText: 'Or enter Image URL',
            labelStyle: const TextStyle(fontSize: 13),
            hintText: 'https://example.com/image.jpg',
            hintStyle: const TextStyle(fontSize: 12),
            prefixIcon: const Icon(Icons.link, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13),
          enabled: _selectedImage == null,
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _selectedImage = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildNeedsEditor() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Current Needs',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Add items needed with quantity, priority, and description.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.65),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),

        // Editable rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _needsList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final need = _needsList[index];
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // Row 1: Item Name and Quantity
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextFormField(
                          initialValue: need.item,
                          decoration: InputDecoration(
                            labelText: 'Item',
                            labelStyle: const TextStyle(fontSize: 12),
                            hintText: 'e.g., Fresh Produce',
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13),
                          onChanged: (v) => need.item = v,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: need.quantity,
                          decoration: InputDecoration(
                            labelText: 'Qty',
                            labelStyle: const TextStyle(fontSize: 12),
                            hintText: '14',
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => need.quantity = v,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Req';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Remove button
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _removeNeedRow(index),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          tooltip: 'Remove',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.error
                                .withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: Priority and Description
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          value: need.priority,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'low',
                              child: Text(
                                'Low',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'medium',
                              child: Text(
                                'Med',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'high',
                              child: Text(
                                'High',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => need.priority = v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 8,
                        child: DropdownButtonFormField<String>(
                          value:
                              need.description == 'Custom' &&
                                  need.customDescription.isNotEmpty
                              ? 'Custom'
                              : need.description,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface,
                          ),
                          items: _commonDescriptions
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                need.description = v;
                                if (v != 'Custom') need.customDescription = '';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  // Custom description field if needed
                  if (need.description == 'Custom') ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: need.customDescription,
                      decoration: InputDecoration(
                        labelText: 'Custom Description',
                        labelStyle: const TextStyle(fontSize: 12),
                        hintText: 'e.g., Needs refrigeration',
                        hintStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                      onChanged: (v) => need.customDescription = v,
                      validator: (v) {
                        if (need.description == 'Custom' &&
                            (v == null || v.trim().isEmpty)) {
                          return 'Please provide a description';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _addNeedRow,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Flexible(
              child: Text(
                'Add multiple needs — all will be saved',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
