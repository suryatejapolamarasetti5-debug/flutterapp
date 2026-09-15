import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'database_helper.dart';

class NearbyIssuesPage extends StatefulWidget {
  const NearbyIssuesPage({super.key});

  @override
  State<NearbyIssuesPage> createState() => _NearbyIssuesPageState();
}

class _NearbyIssuesPageState extends State<NearbyIssuesPage> {
  GoogleMapController? mapController;

  Position? currentPosition;

  bool isLoading = true;
  String errorMessage = '';

  Set<Marker> markers = {};

  // Default location if GPS is unavailable.
  // This is only the initial map position.
  static const LatLng defaultLocation = LatLng(
    17.6868,
    83.2185,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  // ==========================================================
  // INITIALIZE MAP
  // ==========================================================

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadComplaints();
  }

  // ==========================================================
  // GET CURRENT LOCATION
  // ==========================================================

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          errorMessage =
              'Location service is disabled. '
              'You can still view the map.';
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage =
              'Location permission was denied.';
        });
        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        setState(() {
          errorMessage =
              'Location permission is permanently denied. '
              'Please enable it from Settings.';
        });
        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Unable to get current location.';
      });
    }
  }

  // ==========================================================
  // LOAD COMPLAINTS FROM DATABASE
  // ==========================================================

  Future<void> _loadComplaints() async {
    try {
      final complaints =
          await DatabaseHelper.instance.getComplaints();

      final Set<Marker> newMarkers = {};

      for (final complaint in complaints) {
        final latitude = complaint['latitude'];
        final longitude = complaint['longitude'];

        // Skip complaints without GPS coordinates.
        if (latitude == null || longitude == null) {
          continue;
        }

        final double? lat =
            double.tryParse(latitude.toString());

        final double? lng =
            double.tryParse(longitude.toString());

        if (lat == null || lng == null) {
          continue;
        }

        final String id =
            'SL-${complaint['id'].toString().padLeft(3, '0')}';

        final String status =
            complaint['status']?.toString() ?? 'Pending';

        newMarkers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lng),
            icon: _markerColor(status),
            infoWindow: InfoWindow(
              title: complaint['complaint_type']
                      ?.toString() ??
                  'Streetlight Issue',
              snippet:
                  '$id • ${complaint['location']}',
              onTap: () {
                _showComplaintDetails(complaint);
              },
            ),
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        markers = newMarkers;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load complaints.';
      });
    }
  }

  // ==========================================================
  // MARKER COLORS
  // ==========================================================

  BitmapDescriptor _markerColor(String status) {
    switch (status) {
      case 'Resolved':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        );

      case 'In Progress':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );

      default:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
    }
  }

  // ==========================================================
  // MAP CREATED
  // ==========================================================

  void _onMapCreated(
    GoogleMapController controller,
  ) {
    mapController = controller;
  }

  // ==========================================================
  // MOVE TO CURRENT LOCATION
  // ==========================================================

  Future<void> _goToCurrentLocation() async {
    if (currentPosition == null) {
      await _getCurrentLocation();
    }

    if (currentPosition == null ||
        mapController == null) {
      return;
    }

    await mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        15,
      ),
    );
  }

  // ==========================================================
  // COMPLAINT DETAILS
  // ==========================================================

  void _showComplaintDetails(
    Map<String, dynamic> complaint,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            10,
            24,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                complaint['complaint_type']
                        ?.toString() ??
                    'Streetlight Issue',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _detailRow(
                Icons.confirmation_number_outlined,
                'Complaint ID',
                'SL-${complaint['id'].toString().padLeft(3, '0')}',
              ),

              _detailRow(
                Icons.location_on_outlined,
                'Location',
                complaint['location']?.toString() ??
                    'Unknown',
              ),

              _detailRow(
                Icons.priority_high,
                'Priority',
                complaint['priority']?.toString() ??
                    'Unknown',
              ),

              _detailRow(
                Icons.sync,
                'Status',
                complaint['status']?.toString() ??
                    'Pending',
              ),

              const SizedBox(height: 8),

              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                complaint['description']?.toString() ??
                    'No description available.',
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LEGEND
  // ==========================================================

  Widget _buildLegend() {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [
            _legendItem(
              Colors.red,
              'Pending',
            ),
            _legendItem(
              Colors.orange,
              'In Progress',
            ),
            _legendItem(
              Colors.green,
              'Resolved',
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(
    Color color,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter = currentPosition != null
        ? LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          )
        : defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Streetlight Issues',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              setState(() {
                isLoading = true;
              });

              await _initializeMap();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(
              target: mapCenter,
              zoom: 13,
            ),

            onMapCreated: _onMapCreated,

            markers: markers,

            myLocationEnabled:
                currentPosition != null,

            myLocationButtonEnabled: false,

            zoomControlsEnabled: false,

            mapToolbarEnabled: true,

            compassEnabled: true,
          ),

          // Loading indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Error / information message
          if (errorMessage.isNotEmpty)
            Positioned(
              top: 15,
              left: 15,
              right: 15,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Legend
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildLegend(),
          ),
        ],
      ),

      // Current location button
      floatingActionButton:
          FloatingActionButton(
        tooltip: 'My Location',
        onPressed: _goToCurrentLocation,
        child: const Icon(
          Icons.my_location,
        ),
      ),
    );
  }

}