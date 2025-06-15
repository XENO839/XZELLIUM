import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/assessment_question.dart';
import '../../utils/question_loader.dart';

class FullAssessmentScreen extends StatefulWidget {
  final String domain;
  const FullAssessmentScreen({super.key, required this.domain});

  @override
  State<FullAssessmentScreen> createState() => _FullAssessmentScreenState();
}

class _FullAssessmentScreenState extends State<FullAssessmentScreen> {
  List<AssessmentQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {};
  bool _isLoading = true;
  int _timeLeft = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadDomainQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDomainQuestions() async {
    try {
      final questions = await QuestionLoader.loadQuestionsForDomain(
        widget.domain,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
        _startTimerForQuestion();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading questions: $e")));
    }
  }

  void _startTimerForQuestion() {
    _timer?.cancel();
    _timeLeft = _questions[_currentQuestionIndex].timeLimitSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        _nextQuestion();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _startTimerForQuestion();
    } else {
      _finishAssessment();
    }
  }

  void _finishAssessment() {
    _timer?.cancel();
    int correct = 0;
    Map<String, int> categoryScores = {};
    Map<String, List<String>> skillTagsByCategory = {};

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _answers[i]?.trim().toLowerCase();
      final correctAnswer = question.correctAnswer.trim().toLowerCase();

      if (userAnswer == correctAnswer) {
        correct++;
        categoryScores[question.domain] =
            (categoryScores[question.domain] ?? 0) + 1;
        for (String tag in question.skillTags) {
          skillTagsByCategory[tag] = skillTagsByCategory[tag] ?? [];
          skillTagsByCategory[tag]!.add(question.question);
        }
      }
    }

    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: {
        'score': correct,
        'total': _questions.length,
        'domain': widget.domain,
        'categoryScores': categoryScores,
        'skillTagsByCategory': skillTagsByCategory,
        'scorePercent': (correct / _questions.length) * 100,
      },
    );
  }

  Widget _buildQuestionWidget(AssessmentQuestion question) {
    switch (question.type) {
      case 'mcq':
        return Column(
          children: List.generate(question.options.length, (index) {
            final option = question.options[index];
            return RadioListTile<String>(
              value: option,
              groupValue: _answers[_currentQuestionIndex],
              onChanged: (value) {
                setState(() => _answers[_currentQuestionIndex] = value!);
              },
              title: Text(
                option,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              activeColor: const Color(0xFF00E6D0),
            );
          }),
        );

      case 'output':
      case 'debug':
      case 'scenario':
      case 'short':
      case 'short-answer':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.codeSnippet != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: const Color(0xFF1A1A1D),
                child: Text(
                  question.codeSnippet!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white70,
                  ),
                ),
              ),
            TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => _answers[_currentQuestionIndex] = value,
              decoration: InputDecoration(
                hintText: "Type your answer...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A1D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: question.type == 'scenario' ? 5 : 2,
            ),
          ],
        );

      default:
        return const Text(
          "Unsupported question type.",
          style: TextStyle(color: Colors.redAccent),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0E12),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E6D0)),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00E6D0)),
        title: Text(
          'Full Assessment',
          style: GoogleFonts.sora(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Row(
            children: [
              const Icon(Icons.timer, color: Color(0xFF00E6D0)),
              const SizedBox(width: 4),
              Text(
                '$_timeLeft s',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _buildQuestionWidget(question),
            const Spacer(),
            ElevatedButton(
              onPressed: _answers.containsKey(_currentQuestionIndex)
                  ? _nextQuestion
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E6D0),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _currentQuestionIndex == _questions.length - 1
                    ? 'Finish'
                    : 'Next',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
