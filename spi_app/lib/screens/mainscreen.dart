import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/inspection_provider.dart';
import '../widgets/inspection_tile.dart';
import 'add_inspection.dart';
import 'loginscreen.dart';

/// Main screen showing list of all property inspections
/// Displays inspection tiles with refresh and logout options
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Color palette
  final darkGreen = const Color(0xFF1B5E20);
  final midGreen = const Color(0xFF4CAF50);
  final lightGreen = const Color(0xFFC8E6C9);

  @override
  void initState() {
    super.initState();
    // Load inspections after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionProvider>().loadInspections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InspectionProvider>();
    final inspections = provider.inspections;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: lightGreen,
      
      // Floating action button for adding new inspection
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddInspectionScreen(),
            ),
          );
          // Reload inspections after returning
          if (mounted) {
            context.read<InspectionProvider>().loadInspections();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("New Inspection"),
      ),

      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [lightGreen, midGreen, darkGreen],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top bar with title and action buttons
                Stack(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fact_check_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Property Inspections',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${inspections.length} inspection${inspections.length != 1 ? 's' : ''} recorded',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Refresh button
                    Positioned(
                      right: 50,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        tooltip: "Refresh",
                        onPressed: () {
                          context.read<InspectionProvider>().loadInspections();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Refreshed",
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: darkGreen,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Logout button
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        tooltip: "Logout",
                        onPressed: showLogoutDialog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: provider.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: darkGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading inspections...",
                          style: TextStyle(
                            color: midGreen,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : inspections.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Empty state icon
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: midGreen.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: midGreen.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.assignment_outlined,
                                size: 80,
                                color: midGreen,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Empty state text
                            Text(
                              "No Inspections Yet",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: darkGreen,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "Start recording property inspections\nby tapping the button below",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: midGreen,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Add button
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddInspectionScreen(),
                                  ),
                                );
                                if (mounted) {
                                  context.read<InspectionProvider>().loadInspections();
                                }
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text("Add First Inspection"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: darkGreen,
                        onRefresh: () async {
                          await context.read<InspectionProvider>().loadInspections();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: inspections.length,
                          itemBuilder: (_, index) {
                            return InspectionTile(
                              inspection: inspections[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// Show logout confirmation dialog
  void showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  "Logout Confirmation",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: midGreen,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkGreen,
                          side: BorderSide(color: darkGreen, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Logout button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () async {
                          // Clear login session
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', false);
                          
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
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
  }
}