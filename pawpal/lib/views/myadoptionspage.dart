import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/models/adoption.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAdoptionsPage extends StatefulWidget {
  final User? user;
  
  const MyAdoptionsPage({super.key, required this.user});

  @override
  State<MyAdoptionsPage> createState() => _MyAdoptionsPageState();
}

class _MyAdoptionsPageState extends State<MyAdoptionsPage> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);
  
  List<Adoption> adoptionsList = [];
  bool isLoading = false;
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    loadAdoptions();
  }

  String getPetImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return "${MyConfig.baseUrl}/pawpal/assets/$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: const Text(
          'My Adoption Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : adoptionsList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await loadAdoptions();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: adoptionsList.length,
                    itemBuilder: (context, index) {
                      return _buildAdoptionCard(adoptionsList[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 80, color: mainPink.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No Adoption Requests Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: mainPink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find a pet and request to adopt!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionCard(Adoption adoption) {
    Color statusColor;
    IconData statusIcon;
    
    switch (adoption.status?.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAdoptionDetails(adoption),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: adoption.petImage != null
                    ? Image.network(
                        getPetImageUrl(adoption.petImage),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.pets, size: 40),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 40),
                      ),
              ),
              const SizedBox(width: 12),
              
              // Pet Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adoption.petName ?? 'Unknown Pet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adoption.petType ?? 'Unknown Type',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            adoption.status?.toUpperCase() ?? 'PENDING',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      'Owner: ${adoption.ownerName ?? "Unknown"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(Icons.arrow_forward_ios, size: 16, color: mainPink),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdoptionDetails(Adoption adoption) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: bgCream,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    // Title
                    Text(
                      'Adoption Request Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Pet Image
                    if (adoption.petImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          getPetImageUrl(adoption.petImage),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    _infoRow('Pet Name', adoption.petName),
                    _infoRow('Pet Type', adoption.petType),
                    _infoRow('Status', adoption.status?.toUpperCase()),
                    _infoRow('Requested On', 
                      adoption.updatedAt != null 
                        ? formatter.format(DateTime.parse(adoption.updatedAt!))
                        : 'N/A'),
                    
                    const Divider(height: 30),
                    
                    Text(
                      'Your Motivation:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adoption.motivation ?? 'No motivation provided',
                      style: const TextStyle(fontSize: 14),
                    ),
                    
                    const Divider(height: 30),
                    
                    Text(
                      'Owner Contact:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoRow('Name', adoption.ownerName),
                    _infoRow('Email', adoption.ownerEmail),
                    _infoRow('Phone', adoption.ownerPhone),
                    
                    const SizedBox(height: 20),
                    
                    // Contact Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _contactButton(
                          Icons.call,
                          'Call',
                          () => launchUrl(
                            Uri.parse('tel:${adoption.ownerPhone}'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        _contactButton(
                          Icons.message,
                          'SMS',
                          () => launchUrl(
                            Uri.parse('sms:${adoption.ownerPhone}'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        _contactButton(
                          Icons.email,
                          'Email',
                          () => launchUrl(
                            Uri.parse('mailto:${adoption.ownerEmail}'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: mainPink, size: 30),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: mainPink),
        ),
      ],
    );
  }

  Future<void> loadAdoptions() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${MyConfig.baseUrl}/pawpal/api/get_my_adoptions.php?user_id=${widget.user?.user_id}',
        ),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          setState(() {
            adoptionsList = (result['data'] as List)
                .map((item) => Adoption.fromJson(item))
                .toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading adoptions: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}