import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data()?['notificationsEnabled'] != null) {
        setState(() {
          notificationsEnabled = doc['notificationsEnabled'];
        });
      }
    }
  }

  Future<void> saveSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notificationsEnabled': notificationsEnabled,
      }, SetOptions(merge: true));
    }
  }

  Widget buildComingSoonTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2A2A2D),
            ),
            child: Icon(icon, color: Colors.white60, size: 20),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE9455A)),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 🔔 Notifications Toggle Box
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9455A), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enable Notifications",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Get notified for updates,\nchats, and XP gains",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: notificationsEnabled,
                  activeColor: Colors.redAccent,
                  inactiveThumbColor: Colors.grey,
                  onChanged: (val) {
                    setState(() => notificationsEnabled = val);
                    saveSettings();
                  },
                ),
              ],
            ),
          ),

          // 🕒 Coming Soon Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9455A), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFFE9455A),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: Color(0xFFE9455A),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Dark Mode, Language, Data Export",
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 16),
                buildComingSoonTile(Icons.dark_mode, "Dark Mode"),
                buildComingSoonTile(Icons.language_rounded, "Language"),
                buildComingSoonTile(Icons.file_upload_rounded, "Data Export"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
