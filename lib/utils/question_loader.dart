import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/assessment_question.dart';

class QuestionLoader {
  /// Converts a career name like "Software Developer" to "software_developer"
  static String normalizeCareerPath(String careerPath) {
    return careerPath.toLowerCase().replaceAll(' ', '_');
  }

  /// Loads questions based on normalized domain key
  static Future<List<AssessmentQuestion>> loadQuestionsForDomain(
    String careerPath,
  ) async {
    final domainKey = normalizeCareerPath(careerPath);
    final filePath = 'assets/data/question_banks/${domainKey}_questions.json';

    try {
      final jsonString = await rootBundle.loadString(filePath);
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((e) => AssessmentQuestion.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load questions for $careerPath: $e');
    }
  }
}
