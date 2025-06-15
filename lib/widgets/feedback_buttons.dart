import 'package:flutter/material.dart';

class FeedbackButtons extends StatelessWidget {
  final void Function(bool) onFeedback;

  const FeedbackButtons({super.key, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.thumb_up, color: Colors.greenAccent),
            tooltip: 'Helpful',
            onPressed: () => onFeedback(true),
          ),
          IconButton(
            icon: const Icon(Icons.thumb_down, color: Colors.redAccent),
            tooltip: 'Not Helpful',
            onPressed: () => onFeedback(false),
          ),
        ],
      ),
    );
  }
}
