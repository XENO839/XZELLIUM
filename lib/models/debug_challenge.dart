class DebugChallenge {
  final String id;
  final String language;
  final String buggyCode;
  final String expectedOutput;
  final String hint;
  final int maxAttempts;

  DebugChallenge({
    required this.id,
    required this.language,
    required this.buggyCode,
    required this.expectedOutput,
    required this.hint,
    required this.maxAttempts,
  });

  factory DebugChallenge.fromMap(Map<String, dynamic> data) {
    return DebugChallenge(
      id: data['id'] ?? 'unknown',
      language: data['language'] ?? 'Python',
      buggyCode: data['buggyCode'] ?? '',
      expectedOutput: data['expectedOutput'] ?? '',
      hint: data['hint'] ?? 'No hint provided',
      maxAttempts: (data['maxAttempts'] is int)
          ? data['maxAttempts']
          : 4, // default fallback
    );
  }
}
