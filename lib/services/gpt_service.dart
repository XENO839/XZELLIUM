import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GptService {
  static const _apiKey =
      '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';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o';

  static final List<String> careerList = [
    "Software Engineer",
    "Software Developer",
    "Data Analyst",
    "DevOps Engineer",
    "Machine Learning Engineer",
    "Cybersecurity Analyst",
    "Database Administrator",
    "Cloud Engineer",
  ];

  // --- Insight for Guest or Super Domain Result ---
  static String generateShortPrompt({
    required int totalScore,
    required int maxScore,
    required Map<String, int> categoryScores,
    required Map<String, List<String>> skillTagsByCategory,
    required String domain,
  }) {
    final prompt = StringBuffer();
    prompt.writeln("You're an expert tech career coach.");
    prompt.writeln("Generate a 4-part insight including:");
    prompt.writeln("1. Skill Summary (1 line)");
    prompt.writeln("2. Strengths (2 bullet points)");
    prompt.writeln("3. Areas to Improve (2 bullet points)");
    prompt.writeln("4. Career Compatibility (Top 4 of 8 roles with % match)");

    prompt.writeln("\nDomain: $domain");
    prompt.writeln("\nScore: $totalScore / $maxScore");
    prompt.writeln("\nCategory Scores:");
    categoryScores.forEach((category, score) {
      final total = skillTagsByCategory[category]?.length ?? 0;
      prompt.writeln("- $category: $score / $total");
    });

    prompt.writeln("\nAllowed Career Roles:");
    for (var role in careerList) {
      prompt.writeln("- $role");
    }

    prompt.writeln("""
Format your response using exactly these markdown headers:

**Skill Summary**
<summary>

**Strengths**
- Bullet 1
- Bullet 2

**Areas to Improve**
- Bullet 1
- Bullet 2

**Career Compatibility**
- Software Engineer: 85%
- Data Analyst: 78%
- Cloud Engineer: 66%
- Cybersecurity Analyst: 60%
""");

    return prompt.toString();
  }

  static String generateDetailedPrompt({
    required int totalScore,
    required int maxScore,
    required Map<String, int> categoryScores,
    required Map<String, List<String>> skillTagsByCategory,
    required String domain,
    String? userName,
    String? githubUrl,
    String? resumeUrl,
  }) {
    final prompt = StringBuffer();
    prompt.writeln("You are a senior AI mentor writing a 3-page report.");
    prompt.writeln("Domain: $domain");
    if (userName != null) prompt.writeln("User: $userName");
    if (githubUrl != null) prompt.writeln("GitHub: $githubUrl");
    if (resumeUrl != null) prompt.writeln("Resume: $resumeUrl");

    prompt.writeln("\nScore: $totalScore / $maxScore");
    prompt.writeln("Category Scores:");
    categoryScores.forEach((cat, score) {
      final total = skillTagsByCategory[cat]?.length ?? 0;
      prompt.writeln("- $cat: $score / $total");
    });

    prompt.writeln("\nSkill Tags:");
    skillTagsByCategory.forEach((cat, tags) {
      prompt.writeln("- $cat: ${tags.join(', ')}");
    });

    prompt.writeln("""
Format the report in 3–4 pages as follows:

Page 1:
- Include App Logo + Domain Name prominently at the top
- 5 Strengths (bullet points)
- 5 Weaknesses (bullet points)
- Real-world Standing in the Job Market (Beginner, Intermediate, Job-ready, Expert) + reasons

Page 2:
- 5 Skills to Learn Next (with Why it's important)
- For each skill, recommend a platform (free or paid) to learn (e.g., Coursera, Udemy, Docs)
- Include learning methods (e.g., videos, hands-on, projects)

Page 3:
- 5 Unique Project Ideas for the user to build for portfolio
  (Include description and purpose of each project)

Page 4:
- 10 Ways to Improve Resume (bullet points)
  (Focus on achievements, keywords, GitHub, action verbs, impact, certifications, etc.)

Avoid markdown. Use plain text formatting. No extra sections.
""");

    return prompt.toString();
  }

  static Future<Map<String, String>> getGuestInsights({
    required int score,
    required int total,
    required Map<String, int> categoryScores,
    required Map<String, List<String>> skillTagsByCategory,
  }) async {
    final prompt = generateShortPrompt(
      totalScore: score,
      maxScore: total,
      categoryScores: categoryScores,
      skillTagsByCategory: skillTagsByCategory,
      domain: 'General',
    );

    final response = await fetchInsightFromGPT(prompt, shouldSave: false);
    final parts = response.split(RegExp(r"\*\*|\n(?=\*\*)"));

    String summary = '';
    String strengths = '';
    String weaknesses = '';
    String careerFit = '';

    for (int i = 0; i < parts.length - 1; i++) {
      final header = parts[i].toLowerCase();
      final content = parts[i + 1].trim();

      if (header.contains("skill summary")) {
        summary = content;
      } else if (header.contains("strengths")) {
        strengths = content;
      } else if (header.contains("areas to improve")) {
        weaknesses = content;
      } else if (header.contains("career compatibility")) {
        careerFit = content;
      }
    }

    return {
      'Skill Summary': summary,
      'Strengths': strengths,
      'Areas to Improve': weaknesses,
      'Career Compatibility': careerFit,
    };
  }

  static Future<String> fetchInsightFromGPT(
    String prompt, {
    bool shouldSave = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful and motivational AI career advisor. Respond in the format specified without adding any sections.",
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.7,
          "max_tokens": 1800,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data['choices'][0]['message']['content']?.trim() ??
            '⚠️ No content returned.';

        final user = FirebaseAuth.instance.currentUser;
        if (user != null && shouldSave) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('assessments')
              .add({
                'gptPrompt': prompt,
                'gptInsight': reply,
                'timestamp': FieldValue.serverTimestamp(),
              });
        }

        return reply;
      } else {
        return '⚠️ GPT Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return '⚠️ GPT Exception: $e';
    }
  }

  /// ====== NEW METHOD: Used in AI Mentor Chat ======
  static Future<String> fetchInsightFromGPTforChat(
    List<Map<String, String>> messages,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": _model,
          "messages": messages,
          "temperature": 0.8,
          "max_tokens": 1200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim() ??
            '⚠️ No reply.';
      } else {
        return '⚠️ GPT Error: ${response.statusCode}';
      }
    } catch (e) {
      return '⚠️ Chat Exception: $e';
    }
  }

  /// ====== Mock Interview: Question Generator ======
  static Future<String> fetchNextInterviewQuestion({
    required String domain,
    required List<Map<String, String>> conversation,
  }) async {
    final messages = [
      {
        "role": "system",
        "content":
            "You are a hiring manager conducting a realistic mock interview for the domain: $domain. Ask one relevant technical or HR question at a time based on the user's last response. Begin with 'Please introduce yourself'. Don't add commentary, only return the next question in plain text.",
      },
      ...conversation
          .where((entry) {
            final role = entry['role']?.trim().toLowerCase();
            final content = entry['content']?.trim();
            return role != null &&
                content != null &&
                role.isNotEmpty &&
                content.isNotEmpty &&
                (role == 'user' ||
                    role == 'assistant' ||
                    role == 'ai'); // Support 'ai' too
          })
          .map(
            (entry) => {
              'role': (entry['role'] == 'ai') ? 'assistant' : entry['role']!,
              'content': entry['content']!,
            },
          ),
    ];

    // 🧪 Optional debug log
    print("🧪 Final GPT Mock Interview Payload:\n${jsonEncode(messages)}");

    return fetchInsightFromGPTforChat(messages);
  }

  /// ====== Mock Interview: Feedback Generator ======
  static Future<String> fetchInterviewFeedback({
    required String domain,
    required List<Map<String, String>> conversation,
  }) async {
    final transcript = conversation
        .map((e) => '${e['role']}: ${e['content']}')
        .join('\n');

    final prompt =
        '''
You are an experienced technical interviewer. Based on this transcript, give constructive feedback covering:
1. Communication clarity
2. Technical depth and correctness
3. Confidence and fluency
4. Suggestions to improve

Respond formally but encouragingly.
Domain: $domain

Transcript:
$transcript
''';

    return fetchInsightFromGPT(prompt);
  }
}
