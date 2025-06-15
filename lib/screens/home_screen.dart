import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';

// Screens
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'xchange_screen.dart';
import 'skill_streaks_screen.dart';
import 'challenge_screen.dart';
import 'learning_screen.dart';
import 'community_screen.dart';
import 'mock_interview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectedIndex = 0;
  DateTime? _lastBackPressTime;

  late AnimationController _fadeController;
  late AnimationController _circleController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeController.forward();
    _circleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  final List<Widget> screens = [
    const HomeScreenContent(),
    const MockInterviewScreen(), // ✅ Linked here
    const CommunityScreen(),
    const ProPairXChallengeScreen(),
    const LearningScreen(),
  ];

  final List<String> labels = [
    'Home',
    'Mock Interviews',
    'Community',
    'Challenges',
    'Learning',
  ];

  final List<IconData> icons = [
    Icons.home,
    Icons.mic,
    Icons.people_alt,
    Icons.flag,
    Icons.school,
  ];

  void onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      Fluttertoast.showToast(
        msg: "Press back again to exit",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.grey[900],
        textColor: Colors.white,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0E12),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            labels[selectedIndex],
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF00E6D0)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF00E6D0)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
        body: screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF1A1A1D),
          selectedItemColor: const Color(0xFF00E6D0),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          items: List.generate(icons.length, (index) {
            return BottomNavigationBarItem(
              icon: Icon(icons[index]),
              label: labels[index],
            );
          }),
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  Future<void> _navigateToFullAssessment(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final careerPath = userDoc.data()?['careerPath'];
      if (careerPath != null && careerPath is String) {
        Navigator.pushNamed(context, '/full-assessment', arguments: careerPath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Career path not set. Please update your profile."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Guest';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 1000),
            child: Text(
              "\u{1F44B} Welcome back, $name!",
              style: GoogleFonts.sora(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeIn(
            delay: const Duration(milliseconds: 600),
            child: Text(
              "Level 5 \u00B7 \u{1F525} Streak: 3",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
            ),
          ),
          const SizedBox(height: 16),
          FadeIn(
            delay: const Duration(milliseconds: 700),
            child: Wrap(
              spacing: 12,
              children: const [
                _SkillChip(label: "Flutter"),
                _SkillChip(label: "Python"),
                _SkillChip(label: "Cybersecurity"),
              ],
            ),
          ),
          const SizedBox(height: 30),
          FadeIn(
            delay: const Duration(milliseconds: 900),
            child: Text(
              "Skill Snapshot",
              style: GoogleFonts.sora(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ZoomIn(
            duration: const Duration(milliseconds: 1400),
            child: Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 10.0,
                animation: true,
                percent: 0.72,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "72%",
                      style: GoogleFonts.sora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Overall Proficiency",
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: const Color(0xFF00E6D0),
                backgroundColor: Colors.white10,
              ),
            ),
          ),
          const SizedBox(height: 30),
          FadeIn(
            delay: const Duration(milliseconds: 1000),
            child: ElevatedButton.icon(
              onPressed: () => _navigateToFullAssessment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E6D0),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 10,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                "Start Full Assessment",
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "Last completed: 5 days ago",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white38),
              const SizedBox(width: 8),
              Text(
                "Consistency beats intensity.",
                style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: const Color(0xFF1A1A1D),
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
