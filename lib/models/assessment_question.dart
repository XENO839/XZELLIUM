class AssessmentQuestion {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String domain;
  final List<String> careerTags;
  final List<String> conceptTags;
  final List<String> skillTags;
  final String difficulty;
  final String format;
  final String answerType;
  final int timeLimitSeconds;
  final double scoreWeight;
  final bool isVerified;
  final bool hasCodeBlock;
  final bool showCalculator;
  final bool allowSkip;
  final bool showOnReviewScreen;
  final String? codeSnippet; // ✅ NEW FIELD

  AssessmentQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.domain,
    required this.careerTags,
    required this.conceptTags,
    required this.skillTags,
    required this.difficulty,
    required this.format,
    required this.answerType,
    required this.timeLimitSeconds,
    required this.scoreWeight,
    required this.isVerified,
    required this.hasCodeBlock,
    required this.showCalculator,
    required this.allowSkip,
    required this.showOnReviewScreen,
    this.codeSnippet, // ✅ Make it nullable
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      domain: json['domain'] ?? '',
      careerTags: List<String>.from(json['careerTags'] ?? []),
      conceptTags: List<String>.from(json['conceptTags'] ?? []),
      skillTags: List<String>.from(json['skillTags'] ?? []),
      difficulty: json['difficulty'] ?? '',
      format: json['format'] ?? '',
      answerType: json['answerType'] ?? '',
      timeLimitSeconds: json['timeLimitSeconds'] ?? 60,
      scoreWeight: (json['scoreWeight'] ?? 1.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      hasCodeBlock: json['hasCodeBlock'] ?? false,
      showCalculator: json['showCalculator'] ?? false,
      allowSkip: json['allowSkip'] ?? false,
      showOnReviewScreen: json['showOnReviewScreen'] ?? true,
      codeSnippet: json['codeSnippet'], // ✅ Supports null if absent
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'domain': domain,
      'careerTags': careerTags,
      'conceptTags': conceptTags,
      'skillTags': skillTags,
      'difficulty': difficulty,
      'format': format,
      'answerType': answerType,
      'timeLimitSeconds': timeLimitSeconds,
      'scoreWeight': scoreWeight,
      'isVerified': isVerified,
      'hasCodeBlock': hasCodeBlock,
      'showCalculator': showCalculator,
      'allowSkip': allowSkip,
      'showOnReviewScreen': showOnReviewScreen,
      'codeSnippet': codeSnippet, // ✅ Include in serialization
    };
  }
}
