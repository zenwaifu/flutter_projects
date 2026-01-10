import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainscreen.dart';
import 'registerscreen.dart';

/// Login screen with username-based authentication
/// Uses SharedPreferences for session management
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  bool isRemember = false;
  String savedUsername = "";

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    loadPreferences();

    // Setup fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Green gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: screenWidth < 500 ? screenWidth * 0.9 : 400,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      "Property Inspector",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      "Login to your account",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Username field
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        hintText: "Enter username",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Remember me checkbox
                    Row(
                      children: [
                        const Text(
                          "Remember Me",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Checkbox(
                          value: isRemember,
                          checkColor: Colors.white,
                          activeColor: const Color(0xFF1B5E20),
                          side: const BorderSide(color: Colors.white),
                          onChanged: (value) async {
                            final prefs = await SharedPreferences.getInstance();
                            if (value == true) {
                              if (usernameController.text.trim().isEmpty) {
                                showMessage("Please enter username first!");
                                return;
                              }
                              await prefs.setBool('remember', true);
                              showMessage("Preference saved!");
                            } else {
                              await prefs.setBool('remember', false);
                              usernameController.clear();
                              showMessage("Preference removed!");
                            }
                            setState(() => isRemember = value!);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1B5E20),
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: handleLogin,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Register link
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Create New Account",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle login button press
  void handleLogin() async {
    final username = usernameController.text.trim();

    // Validation
    if (savedUsername.isEmpty) {
      showMessage("Please register an account first!");
      return;
    }

    if (username.isEmpty) {
      showMessage("Please enter your username!");
      return;
    }

    if (username != savedUsername) {
      showMessage("Invalid username!");
      return;
    }

    // Save login session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    // Navigate to main screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  /// Show snackbar message
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: const Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Load saved preferences
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      savedUsername = prefs.getString('username') ?? '';
      isRemember = prefs.getBool('remember') ?? false;

      // Auto-fill username if remember me is checked
      if (isRemember && savedUsername.isNotEmpty) {
        usernameController.text = savedUsername;
      }

      // Auto-login if already logged in
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (isLoggedIn && savedUsername.isNotEmpty && mounted) {
        // Small delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading preferences: $e');
      // Continue without saved preferences
      if (mounted) setState(() {});
    }
  }
}