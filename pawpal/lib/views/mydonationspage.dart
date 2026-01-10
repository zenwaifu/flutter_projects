import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/models/donation.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';

class MyDonationsPage extends StatefulWidget {
  final User? user;
  
  const MyDonationsPage({super.key, required this.user});

  @override
  State<MyDonationsPage> createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final midPink = const Color.fromRGBO(245, 154, 185, 1); //245, 210, 210
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);
  
  List<Donation> donationsList = [];
  bool isLoading = false;
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    loadDonations();
  }

  String getPetImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    // Remove any leading slashes or "../assets/" prefix
    String cleanPath = imagePath.replaceAll('../assets/', '').replaceAll('assets/', '');
    return "${MyConfig.baseUrl}/pawpal/assets/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: const Text(
          'My Donations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donationsList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await loadDonations();
                  },
                  child: Column(
                    children: [
                      // Summary Card
                      _buildSummaryCard(),
                      
                      // Donations List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: donationsList.length,
                          itemBuilder: (context, index) {
                            return _buildDonationCard(donationsList[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  Widget _buildSummaryCard() {
    int totalDonations = donationsList.length;
    double totalMoney = donationsList
        .where((d) => d.donationType == 'Money')
        .fold<double>(0.0, (sum, d) => sum + (double.tryParse((d.amount ?? '0').toString()) ?? 0));
    int foodDonations = donationsList
        .where((d) => d.donationType == 'Food')
        .length;
    int medicalDonations = donationsList
        .where((d) => d.donationType == 'Medical')
        .length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your Donation Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: mainPink,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(Icons.volunteer_activism, '$totalDonations', 'Total'),
                _summaryItem(Icons.monetization_on, 'RM${totalMoney.toStringAsFixed(2)}', 'Money'),
                _summaryItem(Icons.fastfood, '$foodDonations', 'Food'),
                _summaryItem(Icons.medical_services, '$medicalDonations', 'Medical'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: mainPink),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            size: 80,
            color: mainPink.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Donations Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: mainPink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help pets in need by making a donation!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    IconData typeIcon;
    Color typeColor;
    
    switch (donation.donationType) {
      case 'Money':
        typeIcon = Icons.monetization_on;
        typeColor = Colors.green;
        break;
      case 'Food':
        typeIcon = Icons.fastfood;
        typeColor = Colors.orange;
        break;
      case 'Medical':
        typeIcon = Icons.medical_services;
        typeColor = Colors.red;
        break;
      default:
        typeIcon = Icons.volunteer_activism;
        typeColor = mainPink;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDonationDetails(donation),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: donation.petImage != null && donation.petImage!.isNotEmpty
                    ? Image.network(
                        getPetImageUrl(donation.petImage),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.pets, size: 30),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 30),
                      ),
              ),
              const SizedBox(width: 12),
              
              // Donation Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.petName ?? 'Unknown Pet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: typeColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 14, color: typeColor),
                          const SizedBox(width: 4),
                          Text(
                            donation.donationType ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Amount or Description Preview
                    if (donation.donationType == 'Money')
                      Text(
                        'RM ${donation.amount}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: midPink,
                        ),
                      )
                    else
                      Text(
                        donation.description ?? 'No description',
                        style: TextStyle(fontSize: 12, color: midPink),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 4),
                    Text(
                      donation.donationDate != null
                          ? formatter.format(DateTime.parse(donation.donationDate!))
                          : 'N/A',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              Icon(Icons.arrow_forward_ios, size: 16, color: mainPink),
            ],
          ),
        ),
      ),
    );
  }

  void _showDonationDetails(Donation donation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
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
                    
                    Text(
                      'Donation Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    if (donation.petImage != null && donation.petImage!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          getPetImageUrl(donation.petImage),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, size: 60),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    _infoRow('Pet Name', donation.petName),
                    _infoRow('Pet Type', donation.petType),
                    _infoRow('Donation Type', donation.donationType),
                    
                    if (donation.donationType == 'Money')
                      _infoRow('Amount', 'RM ${donation.amount}'),
                    
                    _infoRow(
                      'Date',
                      donation.donationDate != null
                          ? formatter.format(DateTime.parse(donation.donationDate!))
                          : 'N/A',
                    ),
                    
                    if (donation.description != null &&
                        donation.description!.isNotEmpty) ...[
                      const Divider(height: 30),
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: mainPink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        donation.description!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: mainPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mainPink),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: mainPink),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Thank you for your generous donation!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: mainPink,
                              ),
                            ),
                          ),
                        ],
                      ),
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
            width: 120,
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

  Future<void> loadDonations() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${MyConfig.baseUrl}/pawpal/api/get_my_donations.php?user_id=${widget.user?.user_id}',
        ),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          setState(() {
            donationsList = (result['data'] as List)
                .map((item) => Donation.fromJson(item))
                .toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading donations: $e'),
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