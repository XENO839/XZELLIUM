import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InterviewFeedbackScreen extends StatelessWidget {
  final String feedback;

  const InterviewFeedbackScreen({super.key, required this.feedback});

  List<Widget> _parseFeedback(String raw) {
    final lines = raw.trim().split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              trimmed.replaceAll('**', ''),
              style: GoogleFonts.sora(
                fontSize: 16,
                color: const Color(0xFF00E6D0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Text(
                    trimmed.substring(2),
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (trimmed.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              trimmed,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
          ),
        );
      }
    }

    return widgets.isEmpty
        ? [
            Center(
              child: Text(
                "No feedback provided.",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
              ),
            ),
          ]
        : widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Interview Feedback", style: GoogleFonts.sora()),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Copy Feedback",
            icon: const Icon(Icons.copy, color: Color(0xFF00E6D0)),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: feedback));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _parseFeedback(feedback),
        ),
      ),
    );
  }
}
