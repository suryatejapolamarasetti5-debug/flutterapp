
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'database_helper.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'package:geolocator/geolocator.dart';
import 'nearby_issues_page.dart';

class ComplaintHome extends StatefulWidget {
  final String userRole;

  const ComplaintHome({
    super.key,
    this.userRole = 'user',
  });

  @override
  State<ComplaintHome> createState() => _ComplaintHomeState();
}

class _ComplaintHomeState extends State<ComplaintHome> {
  bool get isAdmin => widget.userRole == 'admin';
  int selectedIndex = 0;
  String searchQuery = '';
  String selectedFilter = 'All';

  String _formatComplaintDate(dynamic value) {
    if (value == null) {
      return 'Unknown date';
    }

    try {
      final parsed = DateTime.parse(value.toString());
      final month = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][parsed.month - 1];
      return '${parsed.day} $month ${parsed.year}';
    } catch (_) {
      return value.toString();
    }
  }

  Uint8List? _decodeComplaintPhoto(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }

    try {
      return base64Decode(value.toString());
    } catch (_) {
      return null;
    }
  }

  final List<Map<String, dynamic>> complaints = [
    {
      'id': 'SL-001',
      'type': 'Streetlight Not Working',
      'location': 'Main Road',
      'priority': 'High',
      'description': 'Streetlight is completely switched off.',
      'status': 'Pending',
      'date': '06 Sep 2026',
      'hasPhoto': false,
    },
    {
      'id': 'SL-002',
      'type': 'Flickering Light',
      'location': 'Market Area',
      'priority': 'Medium',
      'description': 'Light keeps flickering during the night.',
      'status': 'In Progress',
      'date': '05 Sep 2026',
      'hasPhoto': false,
    },
    {
      'id': 'SL-003',
      'type': 'Damaged Pole',
      'location': 'Bus Stop',
      'priority': 'High',
      'description': 'Streetlight pole appears to be damaged.',
      'status': 'Resolved',
      'date': '03 Sep 2026',
      'hasPhoto': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb),
            SizedBox(width: 10),
            Text(
              'StreetLight',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 10),
        ],
      ),

      drawer: _buildDrawer(),

      body: _buildBody(),

      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Report Issue'),
            )
          : null,
    );
  }

  // ==========================================================
  // DRAWER
  // ==========================================================

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'StreetLight',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Complaint Management System',
                    textAlign: TextAlign.center,
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

            const Divider(),

            _drawerItem(
              Icons.dashboard_outlined,
              'Dashboard',
              0,
            ),
            _drawerItem(
              Icons.add_circle_outline,
              'Report Complaint',
              1,
            ),
            _drawerItem(
              Icons.list_alt_outlined,
              'My Complaints',
              2,
            ),
            _drawerItem(
              Icons.info_outline,
              'About',
              3,
            ),
                   _drawerItem(
  Icons.map_outlined,
  'Nearby Issues',
  5,
),
      
         if (isAdmin)
  _drawerItem(
    Icons.admin_panel_settings_outlined,
    'Admin Dashboard',
    4,
  ),
           const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                AuthService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    int index,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedIndex == index,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        Navigator.pop(context);
      },
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    switch (selectedIndex) {
      case 1:
        return _reportComplaintPage();
      case 2:
        return _complaintsPage();
      case 3:
        return _aboutPage();
      case 4:
        return _adminDashboardPage();
      case 5:
        return const NearbyIssuesPage();
      default:
        return _dashboardPage();
    }
  }

  // ==========================================================
  // DASHBOARD
  // ==========================================================

  Widget _dashboardPage() {
    final pending =
        complaints.where((c) => c['status'] == 'Pending').length;

    final progress =
        complaints.where((c) => c['status'] == 'In Progress').length;

    final resolved =
        complaints.where((c) => c['status'] == 'Resolved').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome 👋',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Report streetlight problems and track their progress.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 30),

          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: [
              _summaryCard(
                'Total',
                '${complaints.length}',
                Icons.assignment_outlined,
              ),
              _summaryCard(
                'Pending',
                '$pending',
                Icons.pending_actions,
              ),
              _summaryCard(
                'In Progress',
                '$progress',
                Icons.sync,
              ),
              _summaryCard(
                'Resolved',
                '$resolved',
                Icons.check_circle_outline,
              ),
            ],
          ),

          const SizedBox(height: 35),

          const Text(
            'Recent Complaints',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...complaints.take(5).map(
                (complaint) => _complaintCard(complaint),
              ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),

              const SizedBox(height: 15),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                title,
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
    );
  }

  // ==========================================================
  // COMPLAINT CARD
  // ==========================================================

  Widget _complaintCard(
    Map<String, dynamic> complaint,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showComplaintDetails(complaint);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint['type'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${complaint['id']} • '
                      '${complaint['location']}',
                    ),

                    const SizedBox(height: 4),

                    Text(
                      complaint['date'],
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

              const SizedBox(width: 8),

              _statusBadge(
                complaint['status'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _statusColor(status)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;

      case 'In Progress':
        return Colors.orange;

      default:
        return Colors.red;
    }
  }

  // ==========================================================
  // REPORT COMPLAINT
  // ==========================================================

  Widget _reportComplaintPage() {
    return const _ComplaintForm();
  }

  // ==========================================================
  // MY COMPLAINTS
  // ==========================================================

  Widget _complaintsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'My Complaints',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Track all complaints submitted by you.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 25),

          if (complaints.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Text(
                  'No complaints submitted yet.',
                ),
              ),
            )
          else
            ...complaints.map(
              (complaint) => _complaintCard(complaint),
            ),
        ],
      ),
    );
  }
  // ==========================================================
  // ADMIN DASHBOARD
  // ==========================================================

  Widget _adminDashboardPage() {
    final pending = complaints
        .where((c) => c['status'] == 'Pending')
        .length;

    final progress = complaints
        .where((c) => c['status'] == 'In Progress')
        .length;

    final resolved = complaints
        .where((c) => c['status'] == 'Resolved')
        .length;

    final filteredComplaints = complaints.where((complaint) {
      final query = searchQuery.toLowerCase().trim();

      final matchesSearch =
          complaint['id'].toString().toLowerCase().contains(query) ||
              complaint['type'].toString().toLowerCase().contains(query) ||
              complaint['location'].toString().toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' || complaint['status'] == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and monitor streetlight complaints.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: [
              _summaryCard(
                'Total Complaints',
                '${complaints.length}',
                Icons.assignment_outlined,
              ),
              _summaryCard(
                'Pending',
                '$pending',
                Icons.pending_actions,
              ),
              _summaryCard(
                'In Progress',
                '$progress',
                Icons.sync,
              ),
              _summaryCard(
                'Resolved',
                '$resolved',
                Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 35),
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by ID, type or location...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterButton('All'),
                _filterButton('Pending'),
                _filterButton('In Progress'),
                _filterButton('Resolved'),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Complaints',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${filteredComplaints.length} found',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (filteredComplaints.isEmpty)
            _noComplaintsFound()
          else
            ...filteredComplaints.map(
              (complaint) => _adminComplaintCard(complaint),
            ),
        ],
      ),
    );
  }

  Widget _filterButton(String filter) {
    final bool isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = filter;
          });
        },
      ),
    );
  }

  Widget _noComplaintsFound() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 55,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.4),
          ),
          const SizedBox(height: 15),
          const Text(
            'No complaints found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search or filter.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminComplaintCard(
    Map<String, dynamic> complaint,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint['type'],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _statusBadge(complaint['status']),
              ],
            ),
            const SizedBox(height: 10),
            Text('${complaint['id']} • ${complaint['location']}'),
            const SizedBox(height: 5),
            Text(
              complaint['date'],
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showAdminComplaintDetails(complaint);
                },
                icon: const Icon(Icons.manage_search),
                label: const Text('Manage Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDetails(
    Map<String, dynamic> complaint,
  ) {
    showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          complaint['type'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Complaint ID',
                complaint['id'],
              ),

              _detailRow(
                'Location',
                complaint['location'],
              ),

              _detailRow(
                'Priority',
                complaint['priority'],
              ),

              _detailRow(
                'Date',
                complaint['date'],
              ),

              const SizedBox(height: 10),

              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                complaint['description'],
              ),

              const SizedBox(height: 18),

              const Text(
                'Current Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _statusBadge(
                complaint['status'],
              ),

              const SizedBox(height: 18),

              const Text(
                'Photo Evidence',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (complaint['photo'] != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.memory(
                    complaint['photo'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'No photo uploaded',
                    ),
                  ),
                ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
  Widget _adminDetailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
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

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

 void _showAdminComplaintDetails(
  Map<String, dynamic> complaint,
) {
  if (!isAdmin) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Only administrators can manage complaints.',
        ),
      ),
    );
    return;
  }

  String selectedStatus = complaint['status'];

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          var alertDialog = AlertDialog(
            title: const Text(
              'Manage Complaint',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    complaint['type'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _adminDetailRow(
                    Icons.confirmation_number_outlined,
                    'Complaint ID',
                    complaint['id'],
                  ),

                  _adminDetailRow(
                    Icons.location_on_outlined,
                    'Location',
                    complaint['location'],
                  ),

                  _adminDetailRow(
                    Icons.priority_high,
                    'Priority',
                    complaint['priority'],
                  ),

                  _adminDetailRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    complaint['date'],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    complaint['description'],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Photo Evidence',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (complaint['photo'] != null)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: Image.memory(
                        complaint['photo'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'No photo uploaded',
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  const Text(
                    'Update Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,

                    decoration:
                        const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.sync),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'In Progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'Resolved',
                        child: Text('Resolved'),
                      ),
                    ],

                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedStatus = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Text(
                        'Current: ',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      _statusBadge(
                        selectedStatus,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final dialogNavigator = Navigator.of(dialogContext);

                  if (!isAdmin) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Only administrators can update complaints.',
                        ),
                      ),
                    );
                    return;
                  }

                  final complaintId = complaint['dbId'];

                  if (complaintId == null) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Complaint ID not found.'),
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;

                  await DatabaseHelper.instance.updateComplaintStatus(
                    complaintId,
                    selectedStatus,
                  );

                  if (!mounted) return;

                  setState(() {
                    complaint['status'] = selectedStatus;
                  });

                  dialogNavigator.pop();

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Complaint status updated successfully.'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Update Status'),
              ),
            ],
          );

          return alertDialog;
        },
      );
    },
  );
}
  Widget _aboutPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About StreetLight',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'StreetLight Complaint Management System '
                    'provides citizens with a simple digital '
                    'platform to report streetlight problems '
                    'and monitor their resolution status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'The system allows citizens to submit '
                    'complaints with location, priority, '
                    'description and photo evidence. '
                    'Administrators can review complaints '
                    'and update their status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // END OF COMPLAINT HOME STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final data = await DatabaseHelper.instance.getComplaints();
    final currentUserId = AuthService.currentUserId;
    final visibleComplaints = isAdmin || currentUserId == null
        ? data
        : data
            .where((complaint) =>
                complaint['user_id'] == currentUserId)
            .toList();

    if (!mounted) return;

    setState(() {
      complaints.clear();

      complaints.addAll(
        visibleComplaints.map((complaint) {
          final photoValue = complaint['image_path'];

          return {
            'id': 'SL-${complaint['id'].toString().padLeft(3, '0')}',
            'dbId': complaint['id'],
            'type': complaint['complaint_type'],
            'location': complaint['location'],
            'priority': complaint['priority'],
            'description': complaint['description'],
            'status': complaint['status'],
            'date': _formatComplaintDate(complaint['created_at']),
            'hasPhoto': photoValue != null && photoValue.toString().isNotEmpty,
            'photo': _decodeComplaintPhoto(photoValue),
          };
        }),
      );
    });
  }
}
// ============================================================
// COMPLAINT FORM
// ============================================================
class _ComplaintForm extends StatefulWidget {
  const _ComplaintForm();

  @override
  State<_ComplaintForm> createState() =>
      _ComplaintFormState();
}

class _ComplaintFormState
    extends State<_ComplaintForm> {
  final _formKey = GlobalKey<FormState>();

  final locationController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  String complaintType =
      'Streetlight Not Working';

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
    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();

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
          constraints: const BoxConstraints(
            maxWidth: 750,
          ),
          child: Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

                    const SizedBox(height: 30),

                    // COMPLAINT TYPE
                    DropdownButtonFormField<String>(
                      initialValue: complaintType,
                      decoration:
                          const InputDecoration(
                        labelText: 'Complaint Type',
                        border:
                            OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.report_problem_outlined,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value:
                              'Streetlight Not Working',
                          child: Text(
                            'Streetlight Not Working',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Flickering Light',
                          child: Text(
                            'Flickering Light',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Damaged Pole',
                          child: Text(
                            'Damaged Pole',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Broken Light Cover',
                          child: Text(
                            'Broken Light Cover',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          complaintType =
                              value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // LOCATION
                    TextFormField(
                      controller:
                          locationController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Location',
                        hintText:
                            'Example: Main Road near Bus Stop',
                        border:
                            OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
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
        color: Theme.of(context)
            .colorScheme
            .primary,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
                    const SizedBox(height: 20),

                    // PRIORITY
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration:
                          const InputDecoration(
                        labelText: 'Priority',
                        border:
                            OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.priority_high,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Low',
                          child: Text('Low'),
                        ),
                        DropdownMenuItem(
                          value: 'Medium',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: 'High',
                          child: Text('High'),
                        ),
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
                      controller:
                          descriptionController,
                      maxLines: 5,
                      decoration:
                          const InputDecoration(
                        labelText: 'Description',
                        hintText:
                            'Describe the streetlight problem...',
                        border:
                            OutlineInputBorder(),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            bottom: 75,
                          ),
                          child: Icon(
                            Icons.description_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
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
                            borderRadius:
                                BorderRadius.circular(
                                    12),
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
                              backgroundColor:
                                  Colors.black54,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage =
                                        null;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: _pickImage,
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons
                                    .add_a_photo_outlined,
                                size: 40,
                                color: Theme.of(
                                        context)
                                    .colorScheme
                                    .primary,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              const Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                'Tap to select an image',
                                style: TextStyle(
                                  color: Theme.of(
                                          context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(
                                        alpha: 0.6,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // SUBMIT
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _submitComplaint,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Submit Complaint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
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

    final parent =
        context.findAncestorStateOfType<_ComplaintHomeState>();

    if (parent == null) {
      return;
    }

    try {
      final userId = AuthService.currentUserId;

      if (userId == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to submit a complaint.'),
          ),
        );
        return;
      }

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

      await parent._loadComplaints();

      if (!mounted) return;

      parent.setState(() {
        parent.selectedIndex = 2;
      });

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
          content: Text(
            'Complaint submitted successfully!',
          ),
        ),
      );
    } catch (e) {
      debugPrint('SUBMIT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit complaint: $e',
          ),
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