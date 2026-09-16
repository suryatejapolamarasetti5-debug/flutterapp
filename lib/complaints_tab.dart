import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'database_helper.dart';
import 'theme.dart';
import 'animations.dart';

class ComplaintsTab extends StatefulWidget {
  const ComplaintsTab({super.key});

  @override
  State<ComplaintsTab> createState() => ComplaintsTabState();
}

class ComplaintsTabState extends State<ComplaintsTab> {
  final List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  bool get isAdmin =>
      AuthService.currentUser?['role']?.toString() == 'admin';
  String? get userName => AuthService.currentUserName;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final data = await DatabaseHelper.instance.getComplaints();
    final currentUserId = AuthService.currentUserId;
    final visibleComplaints = isAdmin || currentUserId == null
        ? data
        : data
            .where((complaint) => complaint['user_id'] == currentUserId)
            .toList();

    final formatted = visibleComplaints.map((complaint) {
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
        'hasPhoto':
            photoValue != null && photoValue.toString().isNotEmpty,
        'photo': _decodeComplaintPhoto(photoValue),
      };
    }).toList();

    if (!mounted) return;

    setState(() {
      complaints
        ..clear()
        ..addAll(formatted);
      isLoading = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final pending =
        complaints.where((c) => c['status'] == 'Pending').length;
    final progress =
        complaints.where((c) => c['status'] == 'In Progress').length;
    final resolved =
        complaints.where((c) => c['status'] == 'Resolved').length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedStatusHeader(
              title: isAdmin ? 'Complaints' : 'My Complaints',
              subtitle: isAdmin
                  ? 'All complaints across users'
                  : (userName == null
                      ? 'Browse reported streetlight issues'
                      : 'Track complaints by $userName'),
              isActive: true,
            ),

            const SizedBox(height: 22),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
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
                    color: AppThemes.statusPending,
                  ),
                  _summaryCard(
                    'In Progress',
                    '$progress',
                    Icons.sync,
                    color: AppThemes.statusInProgress,
                  ),
                  _summaryCard(
                    'Resolved',
                    '$resolved',
                    Icons.check_circle_outline,
                    color: AppThemes.statusResolved,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              if (complaints.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 55,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'No complaints yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your submitted complaints will appear here.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...complaints.map(
                  (complaint) => isAdmin
                      ? _adminComplaintCard(complaint)
                      : _complaintCard(complaint),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final accentColor = color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 165,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: accentColor),
                  const SizedBox(width: 8),
                  BlinkingDot(color: accentColor, size: 8),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
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

  Widget _complaintCard(Map<String, dynamic> complaint) {
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      '${complaint['id']} • ${complaint['location']}',
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

              _statusBadge(complaint['status']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminComplaintCard(Map<String, dynamic> complaint) {
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

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.12),
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
        return AppThemes.statusResolved;
      case 'In Progress':
        return AppThemes.statusInProgress;
      case 'Rejected':
        return AppThemes.statusRejected;
      default:
        return AppThemes.statusPending;
    }
  }

  void _showComplaintDetails(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            complaint['type'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Complaint ID', complaint['id']),
                _detailRow('Location', complaint['location']),
                _detailRow('Priority', complaint['priority']),
                _detailRow('Date', complaint['date']),

                const SizedBox(height: 10),

                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(complaint['description']),

                const SizedBox(height: 18),

                const Text(
                  'Current Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _statusBadge(complaint['status']),

                const SizedBox(height: 18),

                const Text(
                  'Photo Evidence',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (complaint['photo'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: const Center(
                      child: Text('No photo uploaded'),
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

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAdminComplaintDetails(Map<String, dynamic> complaint) {
    String selectedStatus = complaint['status'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Manage Complaint',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(complaint['description']),

                    const SizedBox(height: 20),

                    const Text(
                      'Photo Evidence',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (complaint['photo'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: const Center(
                          child: Text('No photo uploaded'),
                        ),
                      ),

                    const SizedBox(height: 20),

                    const Text(
                      'Update Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sync),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _statusBadge(selectedStatus),
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
                    final scaffoldMessenger =
                        ScaffoldMessenger.of(dialogCtx);
                    final dialogNavigator =
                        Navigator.of(dialogContext);

                    final complaintId = complaint['dbId'];

                    if (complaintId == null) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Complaint ID not found.'),
                        ),
                      );
                      return;
                    }

                    await DatabaseHelper.instance
                        .updateComplaintStatus(
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
                        content: Text(
                          'Complaint status updated successfully.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Update Status'),
                ),
              ],
            );
          },
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}