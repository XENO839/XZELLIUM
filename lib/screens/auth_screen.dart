// Updated AuthScreen with Xzellium theme + Career Dropdown + Verification + Firestore Sync
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedCareer;
  String? redirectAfterLogin;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> careers = [
    "Software Engineer",
    "Software Developer",
    "Data Analyst",
    "DevOps Engineer",
    "Machine Learning Engineer",
    "Cybersecurity Analyst",
    "Database Administrator",
    "Cloud Engineer",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    redirectAfterLogin = args?['redirectAfterLogin'];
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      _controller.reset();
      _controller.forward();
    });
  }

  Future<void> handleAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        (!isLogin && (username.isEmpty || selectedCareer == null))) {
      showSnack("Please fill in all required fields.");
      return;
    }

    if (!isLogin && password != confirmPasswordController.text.trim()) {
      showSnack("Passwords do not match.");
      return;
    }

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!_auth.currentUser!.emailVerified) {
          showSnack("Please verify your email before logging in.");
          await _auth.signOut();
          return;
        }

        final uid = _auth.currentUser!.uid;
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        showSnack("Login successful!");
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = userCredential.user!.uid;
        await _firestore.collection('users').doc(uid).set({
          'username': username,
          'email': email,
          'careerPath': selectedCareer!,
          'createdAt': FieldValue.serverTimestamp(),
          'skillsToLearn': [],
          'skillsToTeach': [],
          'userType': 'normal',
        });

        await _auth.currentUser!.sendEmailVerification();
        showSnack("Verification email sent! Please check your inbox.");
      }

      if (mounted && isLogin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          redirectAfterLogin ?? '/home',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found' => "No user found for that email.",
        'wrong-password' => "Wrong password.",
        'email-already-in-use' => "Email already registered.",
        'weak-password' => "Weak password. Use 6+ characters.",
        _ => "Error: ${e.message}",
      };
      showSnack(msg);
    } catch (e) {
      showSnack("Unexpected error: $e");
    }
  }

  void showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void showPasswordResetDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1D),
        title: const Text(
          "Reset Password",
          style: TextStyle(color: Color(0xFF00E6D0)),
        ),
        content: TextField(
          controller: resetController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isEmpty) return;
              try {
                await _auth.sendPasswordResetEmail(email: email);
                Navigator.pop(context);
                showSnack("Reset link sent to $email");
              } catch (e) {
                showSnack("Error: $e");
              }
            },
            child: const Text(
              "Send Link",
              style: TextStyle(color: Color(0xFF00E6D0)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1C),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  isLogin ? 'Welcome Back' : 'Create Account',
                  style: GoogleFonts.sora(
                    color: const Color(0xFF00E6D0),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isLogin) ...[
                  _buildInputField('Username', usernameController),
                  const SizedBox(height: 16),
                  _buildDropdownField(),
                  const SizedBox(height: 16),
                ],
                _buildInputField('Email', emailController),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'Password',
                  passwordController,
                  showPassword,
                  () => setState(() => showPassword = !showPassword),
                ),
                if (!isLogin)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildPasswordField(
                      'Confirm Password',
                      confirmPasswordController,
                      showConfirmPassword,
                      () => setState(
                        () => showConfirmPassword = !showConfirmPassword,
                      ),
                    ),
                  ),
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: showPasswordResetDialog,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color(0xFF00E6D0)),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0xFF4C00FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  onPressed: handleAuth,
                  child: Text(
                    isLogin ? 'Login' : 'Sign Up',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: toggleForm,
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Login",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  ),
                  child: const Text(
                    "Continue as Guest",
                    style: TextStyle(color: Color(0xFF00E6D0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1A1D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1A1D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedCareer,
      dropdownColor: const Color(0xFF1A1A1D),
      style: const TextStyle(color: Colors.white),
      items: careers
          .map((career) => DropdownMenuItem(value: career, child: Text(career)))
          .toList(),
      onChanged: (val) => setState(() => selectedCareer = val),
      decoration: InputDecoration(
        labelText: 'Select Career Path',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1A1D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
