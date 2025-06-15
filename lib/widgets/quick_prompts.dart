import 'package:flutter/material.dart';

class QuickPrompts extends StatelessWidget {
  final void Function(String) onPromptSelected;

  const QuickPrompts({super.key, required this.onPromptSelected});

  @override
  Widget build(BuildContext context) {
    final List<String> prompts = [
      "How can I improve my DSA skills?",
      "Suggest a mini project in Flutter.",
      "What are top careers in tech?",
      "Give me interview tips.",
      "What should I learn next in web dev?",
      "How to build a strong GitHub profile?",
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(
              prompts[index],
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            onPressed: () => onPromptSelected(prompts[index]),
            backgroundColor: Colors.grey.shade800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
            ),
          );
        },
      ),
    );
  }
}
