import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/ai_mentor_screen.dart';
import '../screens/xchange_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Community",
          style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(
              context,
              title: "XChat",
              subtitle: "Talk to your AI mentor",
              icon: Icons.chat_bubble_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiMentorScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              title: "XChange",
              subtitle: "Skill barter community",
              icon: Icons.sync_alt,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const XChangeScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              title: "Community Projects",
              subtitle: "Join hands, build together",
              icon: Icons.groups_2_outlined,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1D),
                    title: Text(
                      "Coming Soon",
                      style: GoogleFonts.sora(color: Colors.white),
                    ),
                    content: Text(
                      "This feature is under development. Stay tuned!",
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        child: const Text(
                          "OK",
                          style: TextStyle(color: Color(0xFF00E6D0)),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00E6D0), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
