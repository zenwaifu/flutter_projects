import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/mypet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';

class DonationSubmitScreen extends StatefulWidget {
  final MyPet pet;
  final User user;

  const DonationSubmitScreen({
    super.key,
    required this.pet,
    required this.user,
  });

  @override
  State<DonationSubmitScreen> createState() => _DonationSubmitScreenState();
}

class _DonationSubmitScreenState extends State<DonationSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final midPink = const Color.fromRGBO(245, 154, 185, 1); //245, 210, 210
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedDonationType;
  bool isSubmitting = false;

  final List<Map<String, dynamic>> donationTypes = [
    {'type': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange.shade300},
    {'type': 'Medical', 'icon': Icons.medical_services, 'color': Colors.red.shade300},
    {'type': 'Money', 'icon': Icons.monetization_on, 'color': Colors.green.shade300},
  ];

  String getPetImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    return "${MyConfig.baseUrl}/pawpal/assets/$imagePath";
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Make a Donation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink,
        foregroundColor: bgCream,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // PET INFO CARD
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Pet Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              getPetImageUrl(widget.pet.imagePaths!.first),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: const Icon(Icons.pets, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Pet Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.pet.petName ?? 'Unknown Pet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: mainPink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.pet.petType ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: midPink.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: midPink),
                                  ),
                                  child: Text(
                                    widget.pet.petCategory ?? 'Needs Help',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: midPink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DONATION TYPE SELECTION
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.volunteer_activism, color: mainPink),
                              SizedBox(width: 8),
                              Text(
                                'Select Donation Type',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: mainPink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Donation Type Buttons
                          Row(
                            children: donationTypes.map((type) {
                              final isSelected = selectedDonationType == type['type'];
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _donationTypeButton(
                                    type: type['type'],
                                    icon: type['icon'],
                                    color: type['color'],
                                    isSelected: isSelected,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DONATION DETAILS FORM
                  if (selectedDonationType != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note, color: mainPink),
                                SizedBox(width: 8),
                                Text(
                                  'Donation Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: mainPink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Amount field (for Money)
                            if (selectedDonationType == 'Money')
                              TextFormField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Donation Amount',
                                  prefixText: 'RM ',
                                  hintText: '0.00',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons.attach_money, color: midPink),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter amount';
                                  }
                                  if (double.tryParse(val.trim()) == null) {
                                    return 'Please enter valid amount';
                                  }
                                  if (double.parse(val.trim()) <= 0) {
                                    return 'Amount must be greater than 0';
                                  }
                                  return null;
                                },
                              ),

                            // Description field (for Food/Medical)
                            if (selectedDonationType == 'Food' || selectedDonationType == 'Medical')
                              TextFormField(
                                controller: descriptionController,
                                maxLines: 6,
                                maxLength: 200,
                                decoration: InputDecoration(
                                  labelText: 'What are you donating?',
                                  hintText: 'Describe your donation...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: mainPink, width: 1),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons.description, color: midPink),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please describe your donation';
                                  }
                                  if (val.trim().length < 10) {
                                    return 'Please write at least 10 characters';
                                  }
                                  return null;
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // SUBMIT BUTTON
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: midPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (isSubmitting || selectedDonationType == null)
                          ? null
                          : submitDonation,
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        isSubmitting ? 'Submitting...' : 'Submit Donation',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _donationTypeButton({
    required String type,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedDonationType = type;
          // Clear fields when switching type
          amountController.clear();
          descriptionController.clear();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => isSubmitting = true);

    try {
      final body = {
        'pet_id': widget.pet.petId,
        'user_id': widget.user.user_id,
        'donation_type': selectedDonationType,
        'amount': selectedDonationType == 'Money' ? amountController.text.trim() : null,
        'description': selectedDonationType != 'Money' ? descriptionController.text.trim() : null,
      };

      final response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_donation.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (!mounted) return;
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Donation submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to submit donation'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }
}