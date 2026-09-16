import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'auth_service.dart';
import 'database_helper.dart';
import 'animations.dart';
import 'theme.dart';

class ComplaintForm extends StatefulWidget {
  final VoidCallback? onComplaintSubmitted;
  final VoidCallback? onNotLoggedIn;

  const ComplaintForm({
    super.key,
    this.onComplaintSubmitted,
    this.onNotLoggedIn,
  });

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();

  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  String complaintType = 'Streetlight Not Working';
  String priority = 'Medium';

  Uint8List? selectedImage;
  double? latitude;
  double? longitude;

  bool gettingLocation = false;

  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report a Streetlight Issue',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Provide accurate information so the '
                      'issue can be resolved quickly.',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (AuthService.currentUserId == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: const [
                            BlinkingDot(color: AppThemes.statusPending),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You need to be logged in to submit a complaint.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    // COMPLAINT TYPE
                    DropdownButtonFormField<String>(
                      initialValue: complaintType,
                      decoration: const InputDecoration(
                        labelText: 'Complaint Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.report_problem_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Streetlight Not Working',
                          child: Text('Streetlight Not Working'),
                        ),
                        DropdownMenuItem(
                          value: 'Flickering Light',
                          child: Text('Flickering Light'),
                        ),
                        DropdownMenuItem(
                          value: 'Damaged Pole',
                          child: Text('Damaged Pole'),
                        ),
                        DropdownMenuItem(
                          value: 'Broken Light Cover',
                          child: Text('Broken Light Cover'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          complaintType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // LOCATION
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Example: Main Road near Bus Stop',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            gettingLocation ? null : _getCurrentLocation,
                        icon: gettingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          gettingLocation
                              ? 'Getting Location...'
                              : 'Use Current Location',
                        ),
                      ),
                    ),

                    if (latitude != null && longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Location captured: '
                          '${latitude!.toStringAsFixed(6)}, '
                          '${longitude!.toStringAsFixed(6)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // PRIORITY
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          priority = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // DESCRIPTION
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the streetlight problem...',
                        border: OutlineInputBorder(),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 75),
                          child: Icon(Icons.description_outlined),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe the problem';
                        }

                        if (value.trim().length < 10) {
                          return 'Please provide more details';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    // PHOTO
                    const Text(
                      'Photo Evidence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              selectedImage!,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned(
                            top: 10,
                            right: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Tap to select an image',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // SUBMIT
                    BreathingGlow(
                      color: Theme.of(context).colorScheme.primary,
                      minRadius: 6,
                      maxRadius: 12,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitComplaint,
                          icon: const Icon(Icons.send),
                          label: const Text(
                            'Submit Complaint',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = AuthService.currentUserId;

    if (userId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a complaint.'),
        ),
      );

      widget.onNotLoggedIn?.call();
      return;
    }

    try {
      final imageData = selectedImage == null
          ? null
          : base64Encode(selectedImage!);

      await DatabaseHelper.instance.insertComplaint(
        userId,
        complaintType,
        locationController.text.trim(),
        descriptionController.text.trim(),
        priority,
        'Pending',
        imageData,
        DateTime.now().toIso8601String(),
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return;

      widget.onComplaintSubmitted?.call();

      locationController.clear();
      descriptionController.clear();

      setState(() {
        complaintType = 'Streetlight Not Working';
        priority = 'Medium';
        selectedImage = null;
        latitude = null;
        longitude = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted successfully!'),
        ),
      );
    } catch (e) {
      debugPrint('SUBMIT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit complaint: $e'),
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      gettingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services.'),
          ),
        );

        if (!mounted) return;

        setState(() {
          latitude = null;
          longitude = null;
          gettingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required.'),
          ),
        );

        if (!mounted) return;

        setState(() {
          latitude = null;
          longitude = null;
          gettingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        locationController.text =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        gettingLocation = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location captured.'),
        ),
      );
    } catch (e) {
      debugPrint('LOCATION ERROR: $e');

      if (!mounted) return;

      setState(() {
        latitude = null;
        longitude = null;
        gettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to get location: $e'),
        ),
      );
    }
  }
}