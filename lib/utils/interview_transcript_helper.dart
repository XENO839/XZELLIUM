class InterviewTranscriptHelper {
  /// Converts the conversation into a clean readable transcript
  static String formatTranscript(List<Map<String, dynamic>> conversation) {
    final buffer = StringBuffer();

    for (var entry in conversation) {
      final role = entry['sender'] == 'user' ? 'You' : 'AI Interviewer';
      final text = entry['text']?.toString().trim();
      if (text != null && text.isNotEmpty) {
        buffer.writeln('$role: $text\n');
      }
    }

    return buffer.toString();
  }

  /// Extracts pairs of AI questions and User answers
  static List<Map<String, String>> extractQA(List<Map<String, dynamic>> convo) {
    final List<Map<String, String>> qaPairs = [];

    for (int i = 0; i < convo.length - 1; i++) {
      final current = convo[i];
      final next = convo[i + 1];

      if (current['sender'] == 'ai' && next['sender'] == 'user') {
        qaPairs.add({
          'question': current['text']?.toString() ?? '',
          'answer': next['text']?.toString() ?? '',
        });
      }
    }

    return qaPairs;
  }

  /// Converts conversation to List<Map<String, String>> for Firestore or PDF saving
  static List<Map<String, String>> convertForStorage(
    List<Map<String, dynamic>> convo,
  ) {
    return convo
        .where(
          (entry) =>
              entry['text'] != null &&
              entry['text'].toString().trim().isNotEmpty,
        )
        .map(
          (entry) => {
            'role': entry['sender']?.toString() ?? '',
            'text': entry['text']?.toString() ?? '',
          },
        )
        .toList();
  }
}
