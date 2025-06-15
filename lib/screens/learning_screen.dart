import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  final List<Map<String, dynamic>> modules = const [
    {"title": "Data Structures", "progress": 0.65, "badge": "Intermediate"},
    {"title": "Flutter & Dart", "progress": 0.42, "badge": "Beginner"},
    {"title": "Machine Learning", "progress": 0.83, "badge": "Advanced"},
    {"title": "Cybersecurity Basics", "progress": 0.30, "badge": "Novice"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              "🚀 Keep Learning!",
              style: GoogleFonts.sora(
                color: const Color(0xFF00E6D0),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your progress today powers your career tomorrow.",
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            ...modules.map((module) => _buildModuleCard(module)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E6D0).withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module['title'],
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: module['progress'],
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF00E6D0)),
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Text(
            "${(module['progress'] * 100).toInt()}% completed · Badge: ${module['badge']}",
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
