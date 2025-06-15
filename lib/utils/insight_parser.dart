class InsightParser {
  /// Parses short GPT insights for the result screen
  static Map<String, String> parseShortInsight(String raw) {
    final result = <String, String>{
      'Skill Summary': '',
      'Strengths': '',
      'Areas to Improve': '',
    };

    final cleaned = raw
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'[*]{2,}'), '**')
        .replaceAll('•', '-')
        .trim();

    final lines = cleaned.split('\n');
    String? currentSection;
    final buffer = <String>[];

    void saveSection() {
      if (currentSection == null || buffer.isEmpty) return;

      final content = buffer.join('\n').trim();
      if (currentSection == 'Skill Summary') {
        result['Skill Summary'] = content;
      } else if (currentSection == 'Strengths') {
        result['Strengths'] = _formatBullets(content);
      } else if (currentSection == 'Areas to Improve') {
        result['Areas to Improve'] = _formatBullets(content);
      }

      buffer.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();
      final match = RegExp(r'^\*\*(.+?)\*\*$').firstMatch(trimmed);
      if (match != null) {
        saveSection();
        currentSection = match.group(1)?.trim();
      } else {
        buffer.add(trimmed);
      }
    }

    saveSection();
    return result;
  }

  /// Parses detailed GPT insights for the PDF generator
  static Map<String, String> parseDetailedInsight(String raw) {
    final rawSections = {
      'Strengths': '',
      'Weaknesses': '',
      'Languages to Learn': '',
      'Ways to Learn': '',
      'Certifications': '',
      'Career Paths': '',
      'First Steps': '',
      'Mentor Advice': '',
    };

    final lines = raw.replaceAll('\r', '').replaceAll('•', '-').split('\n');
    String? currentSection;
    final buffer = <String>[];

    void saveSection() {
      if (currentSection != null && rawSections.containsKey(currentSection)) {
        rawSections[currentSection!] = _formatBullets(buffer.join('\n').trim());
      }
      buffer.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();
      final sectionMatch = RegExp(
        r'^(Strengths|Weaknesses|Languages to Learn|Ways to Learn|Certifications|Career Paths|First Steps|Mentor Advice)[:：]?$',
      ).firstMatch(trimmed);

      if (sectionMatch != null) {
        saveSection();
        currentSection = sectionMatch.group(1);
      } else {
        buffer.add(trimmed);
      }
    }

    saveSection();

    return {
      'Skill Strengths': rawSections['Strengths'] ?? '',
      'Areas to Improve': rawSections['Weaknesses'] ?? '',
      'Learning Plan':
          '${rawSections['Languages to Learn']}\n${rawSections['Ways to Learn']}\n${rawSections['Certifications']}',
      'Career Suggestions': rawSections['Career Paths'] ?? '',
      'Growth Forecast': rawSections['First Steps'] ?? '',
      'Mentor Advice': rawSections['Mentor Advice'] ?? '',
    };
  }

  /// Formats bullet-style blocks into clean strings
  static String _formatBullets(String block) {
    final lines = block.split('\n');
    final bullets = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      final match =
          RegExp(r'^[-•*]\s*(.+)$').firstMatch(trimmed) ??
          RegExp(r'^\d+\.\s*(.+)$').firstMatch(trimmed);

      if (match != null) {
        bullets.add("• ${match.group(1)!.trim()}");
      } else if (trimmed.isNotEmpty) {
        bullets.add("• $trimmed");
      }
    }

    return bullets.join('\n');
  }
}
