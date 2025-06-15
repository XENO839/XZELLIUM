import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:xzellium/services/gpt_service.dart' as gpt;
import 'package:xzellium/utils/insight_parser.dart';
import 'package:xzellium/utils/text_extensions.dart';
import 'package:flutter/rendering.dart';

class ResultScreen extends StatefulWidget {
  final double scorePercent;
  final String domain;

  const ResultScreen({
    super.key,
    required this.scorePercent,
    required this.domain,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _donutKey = GlobalKey();
  final GlobalKey _barKey = GlobalKey();

  int score = 0;
  int total = 0;
  Map<String, int> categoryScores = {};
  Map<String, List<String>> skillTagsByCategory = {};
  String rawInsight = "🧠 Generating your personalized skill report...";
  Map<String, String> parsedInsight = {};
  bool saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    score = args?['score'] ?? 0;
    total = args?['total'] ?? 0;
    categoryScores = Map<String, int>.from(args?['categoryScores'] ?? {});
    skillTagsByCategory = Map<String, List<String>>.from(
      args?['skillTagsByCategory'] ?? {},
    );
    _handleResultFlow();
  }

  Future<void> _handleResultFlow() async {
    if (score == 0) {
      setState(() {
        rawInsight = "😬 You didn’t score any points. Please retake the test.";
        parsedInsight = {
          'Skill Summary': 'N/A',
          'Strengths': 'No strengths identified.',
          'Areas to Improve': 'All areas need improvement.',
        };
      });
      return;
    }

    final shortPrompt = gpt.GptService.generateShortPrompt(
      totalScore: score,
      maxScore: total,
      categoryScores: categoryScores,
      skillTagsByCategory: skillTagsByCategory,
      domain: widget.domain,
    );

    final shortInsight = await gpt.GptService.fetchInsightFromGPT(shortPrompt);
    if (!mounted) return;

    setState(() {
      rawInsight = shortInsight;
      parsedInsight = InsightParser.parseShortInsight(shortInsight);
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !saved) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('assessments')
          .add({
            'score': score,
            'total': total,
            'percentage': (score / total) * 100,
            'categoryScores': categoryScores,
            'skillTagsByCategory': skillTagsByCategory,
            'shortInsight': shortInsight,
            'detailedInsight': "dummy_placeholder",
            'domain': widget.domain,
            'timestamp': FieldValue.serverTimestamp(),
          });
      saved = true;
    }
  }

  Future<void> _downloadDummyPdf() async {
    final byteData = await rootBundle.load('assets/detailed_report.pdf');
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/Xzellium_Report.pdf';
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    await OpenFile.open(filePath);
  }

  Widget buildDonutChart() {
    return RepaintBoundary(
      key: _donutKey,
      child: SizedBox(
        height: 220,
        width: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                startDegreeOffset: 270,
                sections: [
                  PieChartSectionData(
                    value: widget.scorePercent,
                    color: const Color(0xFF4C00FF),
                    radius: 30,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 100 - widget.scorePercent,
                    color: Colors.grey.shade800,
                    radius: 30,
                    showTitle: false,
                  ),
                ],
                centerSpaceRadius: 70,
                sectionsSpace: 0,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SCORE",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                Text(
                  "${widget.scorePercent.toInt()}%",
                  style: const TextStyle(
                    fontSize: 34,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBarChart() {
    final bars = categoryScores.entries.map((entry) {
      final correct = entry.value.toDouble();
      final totalQ = skillTagsByCategory[entry.key]?.length.toDouble() ?? 1;
      final percentage = (correct / totalQ) * 100;

      return BarChartGroupData(
        x: categoryScores.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: percentage,
            width: 18,
            color: const Color(0xFFFF3C64),
            borderRadius: BorderRadius.circular(20),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: const Color(0xFF2A2A2D),
            ),
          ),
        ],
      );
    }).toList();

    return RepaintBoundary(
      key: _barKey,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < categoryScores.length) {
                    final label = categoryScores.keys.elementAt(index);
                    return RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInsightCard(
    String emoji,
    String title,
    String content,
    Color glowColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: content.highlight(
              ['Flutter', 'DSA', 'API', 'main()', 'Layout'],
              baseColor: Colors.white70,
              highlightColor: glowColor,
              fontSize: 15.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        title: const Text(
          'Your Skill Snapshot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFE9455A)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildDonutChart(),
            const SizedBox(height: 30),
            if (categoryScores.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Category Scores",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(height: 260, child: buildBarChart()),
              const SizedBox(height: 28),
            ],
            const Text(
              'AI SNAPSHOT',
              style: TextStyle(color: Color(0xFFE9455A), fontSize: 20),
            ),
            const SizedBox(height: 20),
            if (score == 0)
              buildInsightCard(
                '❗',
                'No Insight Available',
                rawInsight,
                const Color(0xFFE9455A),
              )
            else ...[
              buildInsightCard(
                '💡',
                'Skill Summary',
                parsedInsight['Skill Summary'] ?? '',
                const Color(0xFFE9455A),
              ),
              buildInsightCard(
                '✅',
                'Strengths',
                parsedInsight['Strengths'] ?? '',
                const Color(0xFF2ECC71),
              ),
              buildInsightCard(
                '⚠️',
                'Areas to Improve',
                parsedInsight['Areas to Improve'] ?? '',
                const Color(0xFFF39C12),
              ),
            ],
            const SizedBox(height: 24),
            if (user != null && score > 0)
              GestureDetector(
                onTap: _downloadDummyPdf,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C00FF), Color(0xFF00E6D0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4C00FF).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Download Full Report",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
