import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/super_domain_loader.dart';
import '../models/super_domain_question.dart';

class ShortAssessmentScreen extends StatefulWidget {
  const ShortAssessmentScreen({super.key});

  @override
  State<ShortAssessmentScreen> createState() => _ShortAssessmentScreenState();
}

class _ShortAssessmentScreenState extends State<ShortAssessmentScreen>
    with SingleTickerProviderStateMixin {
  List<SuperDomainQuestion> questions = [];
  int currentQuestion = 0;
  int score = 0;

  List<dynamic> userAnswers = [];
  Map<String, int> categoryScores = {};
  Map<String, List<String>> skillTagsByCategory = {};

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    SuperDomainLoader.loadQuestions().then((loadedQuestions) {
      setState(() {
        questions = loadedQuestions;
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void answerQuestion(dynamic selectedAnswer) {
    final q = questions[currentQuestion];
    final isCorrect =
        selectedAnswer.toString().trim().toLowerCase() ==
        q.correctAnswer.toLowerCase();

    if (isCorrect) {
      score++;
      categoryScores[q.domain] = (categoryScores[q.domain] ?? 0) + 1;
    }

    skillTagsByCategory.putIfAbsent(q.domain, () => []);
    for (var tag in q.skillTags) {
      if (!skillTagsByCategory[q.domain]!.contains(tag)) {
        skillTagsByCategory[q.domain]!.add(tag);
      }
    }

    userAnswers.add(selectedAnswer);

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        _textController.clear();
        _controller.reset();
        _controller.forward();
      });
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/guest-result',
        arguments: {
          'score': score,
          'total': questions.length,
          'categoryScores': categoryScores,
          'skillTagsByCategory': skillTagsByCategory,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0E12),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E6D0)),
        ),
      );
    }

    final question = questions[currentQuestion];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Skill Assessment',
          style: GoogleFonts.sora(
            color: const Color(0xFF00E6D0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E0E12), Color(0xFF1A1A1D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentQuestion + 1} of ${questions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question.question,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (question.options.isNotEmpty)
                    ...List.generate(question.options.length, (index) {
                      return GestureDetector(
                        onTap: () => answerQuestion(question.options[index]),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C00FF), Color(0xFF00E6D0)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            question.options[index],
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    })
                  else
                    Column(
                      children: [
                        TextField(
                          controller: _textController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter your answer...',
                            hintStyle: TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF1A1A1D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => answerQuestion(_textController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E6D0),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
