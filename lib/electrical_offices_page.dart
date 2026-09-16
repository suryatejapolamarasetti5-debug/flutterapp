import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ElectricalOfficesPage extends StatefulWidget {
  const ElectricalOfficesPage({super.key});

  @override
  State<ElectricalOfficesPage> createState() => _ElectricalOfficesPageState();
}

class _ElectricalOfficesPageState extends State<ElectricalOfficesPage> {
  String _searchQuery = '';

  final List<Map<String, String>> _offices = [
    {
      'name': 'APSPDCL - Main Office',
      'address': 'RTC Complex, Visakhapatnam, Andhra Pradesh 530001',
      'phone': '1800-425-0002',
      'email': 'customercare@apspdcl.in',
      'hours': 'Mon-Sat: 9:00 AM - 6:00 PM',
      'type': 'Main Office',
    },
    {
      'name': 'Electrical Division - Zone 1',
      'address': 'MVP Colony, Visakhapatnam, Andhra Pradesh 530017',
      'phone': '0891-2546789',
      'email': 'zone1@apspdcl.in',
      'hours': 'Mon-Sat: 10:00 AM - 5:00 PM',
      'type': 'Division',
    },
    {
      'name': 'Electrical Division - Zone 2',
      'address': 'Dwaraka Nagar, Visakhapatnam, Andhra Pradesh 530016',
      'phone': '0891-2557890',
      'email': 'zone2@apspdcl.in',
      'hours': 'Mon-Sat: 10:00 AM - 5:00 PM',
      'type': 'Division',
    },
    {
      'name': 'Electrical Sub-Station - Gajuwaka',
      'address': 'Gajuwaka, Visakhapatnam, Andhra Pradesh 530026',
      'phone': '0891-2512345',
      'email': 'gajuwaka@apspdcl.in',
      'hours': '24/7 Emergency Service',
      'type': 'Sub-Station',
    },
    {
      'name': 'Electrical Sub-Station - One Town',
      'address': 'One Town, Visakhapatnam, Andhra Pradesh 530003',
      'phone': '0891-2534567',
      'email': 'onetown@apspdcl.in',
      'hours': '24/7 Emergency Service',
      'type': 'Sub-Station',
    },
    {
      'name': 'Complaint & Customer Care Center',
      'address': 'Siripuram, Visakhapatnam, Andhra Pradesh 530003',
      'phone': '1912',
      'email': 'care@apspdcl.in',
      'hours': '24/7 Toll-Free',
      'type': 'Customer Care',
    },
  ];

  List<Map<String, String>> get _filteredOffices {
    if (_searchQuery.isEmpty) return _offices;
    return _offices.where((office) {
      final name = office['name']!.toLowerCase();
      final address = office['address']!.toLowerCase();
      final type = office['type']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          address.contains(query) ||
          type.contains(query);
    }).toList();
  }

  Future<void> _launchUrl(String url, {bool isPhone = false}) async {
    final uri = isPhone ? Uri(scheme: 'tel', path: url) : Uri(scheme: 'mailto', path: url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Main Office':
        return Colors.deepPurple;
      case 'Division':
        return Colors.blue;
      case 'Sub-Station':
        return Colors.orange;
      case 'Customer Care':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Electrical Offices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search offices...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          Expanded(
            child: _filteredOffices.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No offices found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredOffices.length,
                    itemBuilder: (context, index) {
                      final office = _filteredOffices[index];
                      return _buildOfficeCard(office);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeCard(Map<String, String> office) {
    final typeColor = _getTypeColor(office['type']!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    office['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    office['type']!,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.location_on_outlined, office['address']!),
            const SizedBox(height: 8),
            _infoRow(Icons.access_time, office['hours']!),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(office['phone']!, isPhone: true),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(office['email']!),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('Email', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
