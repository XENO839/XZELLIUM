import 'package:flutter/material.dart';
import '../../models/assessment_question.dart';

class ShortAnswerWidget extends StatefulWidget {
  final AssessmentQuestion question;
  final Function(String) onAnswer;

  const ShortAnswerWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<ShortAnswerWidget> createState() => _ShortAnswerWidgetState();
}

class _ShortAnswerWidgetState extends State<ShortAnswerWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          maxLines: 5,
          minLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Type your answer...",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1A1A1D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: widget.onAnswer,
        ),
      ],
    );
  }
}
