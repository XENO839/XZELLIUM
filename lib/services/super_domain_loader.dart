import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/super_domain_question.dart';

class SuperDomainLoader {
  static Future<List<SuperDomainQuestion>> loadQuestions() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'lib/data/super_domain_questions.json',
      );

      // Parse JSON string into a List of dynamic maps
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert each map into a SuperDomainQuestion instance
      return jsonList
          .map<SuperDomainQuestion>(
            (json) => SuperDomainQuestion.fromJson(json),
          )
          .toList();
    } catch (e) {
      print('❌ Failed to load super domain questions: $e');
      return [];
    }
  }
}
