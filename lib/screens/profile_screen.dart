import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xzellium/screens/assessment_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final qualificationController = TextEditingController();
  final githubController = TextEditingController();

  String careerSuggestion = '';
  List<String> skillBadges = [];
  int xp = 3150; // Mocked XP value; replace with actual logic if needed.

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (!mounted) return;

      if (data != null) {
        nameController.text = data['name'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        qualificationController.text = data['qualification'] ?? '';
        githubController.text = data['github'] ?? '';
        careerSuggestion = data['careerSuggestion'] ?? '';
        skillBadges = List<String>.from(data['skillSummary'] ?? []);
        xp = data['xp'] ?? 0;
      }

      setState(() => isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> saveProfile() async {
    await firestore.collection('users').doc(user.uid).set({
      'name': nameController.text.trim(),
      'age': int.tryParse(ageController.text.trim()) ?? 0,
      'qualification': qualificationController.text.trim(),
      'github': githubController.text.trim(),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            backgroundColor: Color(0xFF0E0E12),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE9455A)),
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xFF0E0E12),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.redAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          'Level 5',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildNeumorphicField(nameController, "Full Name"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: buildNeumorphicField(ageController, "Age"),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1D),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '$xp XP',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildNeumorphicField(
                    qualificationController,
                    "Qualification",
                  ),
                  const SizedBox(height: 16),
                  buildNeumorphicField(githubController, "Portfolio"),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: saveProfile,
                    icon: const Icon(Icons.save, color: Colors.black),
                    label: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (skillBadges.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: skillBadges.map(_buildBadge).toList(),
                    ),
                  const SizedBox(height: 24),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: const Color(0xFF1A1A1D),
                    leading: const Icon(Icons.history, color: Colors.redAccent),
                    title: const Text(
                      'View Assessment History',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssessmentHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget buildNeumorphicField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Text(label, style: const TextStyle(color: Colors.redAccent)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    qualificationController.dispose();
    githubController.dispose();
    super.dispose();
  }
}
