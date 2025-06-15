// text_extensions.dart

import 'package:flutter/material.dart';

extension HighlightedText on String {
  /// Highlights keywords within the string using rich formatting.
  /// Use for emphasizing phrases like skill names, tools, or technologies.
  TextSpan highlight(
    List<String> highlights, {
    Color highlightColor = Colors.redAccent,
    FontWeight weight = FontWeight.bold,
    Color? baseColor,
    double? fontSize,
  }) {
    final List<TextSpan> spans = [];
    String remaining = this;

    while (remaining.isNotEmpty) {
      final match = highlights.firstWhere(
        (word) => remaining.toLowerCase().contains(word.toLowerCase()),
        orElse: () => '',
      );

      if (match.isEmpty) {
        spans.add(
          TextSpan(
            text: remaining,
            style: TextStyle(
              color: baseColor ?? Colors.white,
              fontSize: fontSize,
            ),
          ),
        );
        break;
      }

      final index = remaining.toLowerCase().indexOf(match.toLowerCase());
      if (index > 0) {
        spans.add(
          TextSpan(
            text: remaining.substring(0, index),
            style: TextStyle(
              color: baseColor ?? Colors.white,
              fontSize: fontSize,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: remaining.substring(index, index + match.length),
          style: TextStyle(
            color: highlightColor,
            fontWeight: weight,
            fontSize: fontSize,
          ),
        ),
      );

      remaining = remaining.substring(index + match.length);
    }

    return TextSpan(children: spans);
  }
}
