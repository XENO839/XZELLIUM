class SuperDomainQuestion {
  final String id;
  final String type; // e.g., "mcq", "output", "debug", "scenario"
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String domain;
  final List<String> careerTags;
  final List<String> conceptTags;
  final List<String> skillTags;
  final String difficulty; // e.g., "Easy", "Medium", "Hard"
  final String format; // e.g., "code", "text"
  final String answerType; // e.g., "single-choice", "short-text"
  final int timeLimitSeconds;
  final double scoreWeight;
  final bool isVerified;
  final bool hasCodeBlock;
  final bool showCalculator;
  final bool allowSkip;
  final bool showOnReviewScreen;

  SuperDomainQuestion({
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
  });

  factory SuperDomainQuestion.fromJson(Map<String, dynamic> json) {
    return SuperDomainQuestion(
      id: json['id'] ?? '',
      type: json['type'] ?? 'mcq',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      domain: json['domain'] ?? '',
      careerTags: List<String>.from(json['careerTags'] ?? []),
      conceptTags: List<String>.from(json['conceptTags'] ?? []),
      skillTags: List<String>.from(json['skillTags'] ?? []),
      difficulty: json['difficulty'] ?? 'Medium',
      format: json['format'] ?? 'text',
      answerType: json['answerType'] ?? 'single-choice',
      timeLimitSeconds: json['timeLimitSeconds'] ?? 45,
      scoreWeight: (json['scoreWeight'] ?? 1.0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      hasCodeBlock: json['hasCodeBlock'] ?? false,
      showCalculator: json['showCalculator'] ?? false,
      allowSkip: json['allowSkip'] ?? false,
      showOnReviewScreen: json['showOnReviewScreen'] ?? true,
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
    };
  }
}
