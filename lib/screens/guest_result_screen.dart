import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/gpt_service.dart';

class GuestResultScreen extends StatefulWidget {
  const GuestResultScreen({super.key});

  @override
  State<GuestResultScreen> createState() => _GuestResultScreenState();
}

class _GuestResultScreenState extends State<GuestResultScreen>
    with SingleTickerProviderStateMixin {
  int? score;
  int? total;
  Map<String, int>? categoryScores;
  Map<String, List<String>>? skillTagsByCategory;

  String strengths = '';
  String weaknesses = '';
  List<Map<String, dynamic>> careerMatches = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCirc),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      score = args['score'];
      total = args['total'];
      categoryScores = Map<String, int>.from(args['categoryScores']);
      skillTagsByCategory = Map<String, List<String>>.from(
        args['skillTagsByCategory'],
      );
      fetchInsights();
      _animationController.forward();
    });
  }

  Future<void> fetchInsights() async {
    if (score == null ||
        total == null ||
        categoryScores == null ||
        skillTagsByCategory == null) {
      return;
    }

    final insights = await GptService.getGuestInsights(
      score: score!,
      total: total!,
      categoryScores: categoryScores!,
      skillTagsByCategory: skillTagsByCategory!,
    );

    final careerLines =
        insights['Career Compatibility']
            ?.split('\n')
            .where((line) => line.contains(':'))
            .toList() ??
        [];

    final parsedCareers = careerLines.map((line) {
      final parts = line.split(':');
      final name = parts[0].trim();
      final percent = parts.length > 1
          ? int.tryParse(parts[1].replaceAll('%', '').trim()) ?? 0
          : 0;
      return {"role": name, "percent": percent};
    }).toList();

    setState(() {
      strengths = insights['Strengths'] ?? '';
      weaknesses = insights['Areas to Improve'] ?? '';
      careerMatches = parsedCareers;
      isLoading = false;
    });
  }

  Widget buildInsightCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2F), Color(0xFF2A2A3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 16,
              color: const Color(0xFF00E6D0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCareerCompatibilityList() {
    return Column(
      children: careerMatches.map((career) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF1A1A2F),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                career['role'],
                style: GoogleFonts.sora(fontSize: 15, color: Colors.white),
              ),
              Text(
                '${career['percent']}%',
                style: GoogleFonts.sora(
                  fontSize: 15,
                  color: const Color(0xFF00E6D0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildChart() {
    final percent = (score ?? 0) / (total ?? 1);
    return SizedBox(
      height: 180,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percent),
        duration: const Duration(seconds: 2),
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF4C00FF),
                    value: value * 100,
                    radius: 60,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: Colors.grey.shade900,
                    value: (1 - value) * 100,
                    radius: 60,
                    showTitle: false,
                  ),
                ],
                centerSpaceRadius: 48,
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.sora(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (score == null || total == null || isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0F1C),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E6D0)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Your Skill Snapshot",
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E6D0),
                  ),
                ),
                const SizedBox(height: 30),
                buildChart(),
                const SizedBox(height: 30),
                buildInsightCard("Strengths", strengths),
                buildInsightCard("Areas to Improve", weaknesses),
                const SizedBox(height: 12),
                Text(
                  "Top Career Matches",
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    color: const Color(0xFF00E6D0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                buildCareerCompatibilityList(),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/auth');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4C00FF), Color(0xFF00E6D0)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'Let’s Dive In',
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
