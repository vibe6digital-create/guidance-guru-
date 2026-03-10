import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/report_model.dart';
import '../models/test_model.dart';
import '../models/student_academic_model.dart';
import 'report_service.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;

  GenerativeModel? _model;

  GeminiService._internal() {
    final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
    if (apiKey.isNotEmpty && apiKey != 'your_gemini_api_key_here') {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.7,
        ),
      );
    }
  }

  Future<List<CareerRecommendation>> generateCareerRecommendations({
    required List<CategoryScore> categoryScores,
    required Map<String, String> answers,
    StudentAcademicModel? academicData,
  }) async {
    if (_model == null) {
      return ReportService.getMockReport().recommendations;
    }

    try {
      final prompt = _buildRecommendationPrompt(
        categoryScores: categoryScores,
        answers: answers,
        academicData: academicData,
      );

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response');

      final jsonData = jsonDecode(text) as Map<String, dynamic>;
      final recommendations = (jsonData['recommendations'] as List<dynamic>)
          .map((e) => CareerRecommendation.fromJson(e as Map<String, dynamic>))
          .toList();

      return recommendations;
    } catch (_) {
      return ReportService.getMockReport().recommendations;
    }
  }

  Future<ReportModel> generateFullReport({
    required String studentId,
    required String testId,
    required double overallScore,
    required String performanceBand,
    required List<CategoryScore> categoryScores,
    required Map<String, String> answers,
    StudentAcademicModel? academicData,
  }) async {
    if (_model == null) {
      return ReportService.getMockReport();
    }

    try {
      final prompt = _buildFullReportPrompt(
        overallScore: overallScore,
        performanceBand: performanceBand,
        categoryScores: categoryScores,
        answers: answers,
        academicData: academicData,
      );

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) throw Exception('Empty response');

      final jsonData = jsonDecode(text) as Map<String, dynamic>;

      final recommendations = (jsonData['recommendations'] as List<dynamic>)
          .map((e) => CareerRecommendation.fromJson(e as Map<String, dynamic>))
          .toList();

      final strengths = (jsonData['strengths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

      final areasForImprovement =
          (jsonData['areasForImprovement'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList();

      return ReportModel(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        testId: testId,
        overallScore: overallScore,
        performanceBand: performanceBand,
        categoryScores: categoryScores,
        recommendations: recommendations,
        generatedAt: DateTime.now(),
        aiSummary: jsonData['aiSummary'] as String?,
        strengths: strengths,
        areasForImprovement: areasForImprovement,
      );
    } catch (_) {
      return ReportService.getMockReport();
    }
  }

  String _buildRecommendationPrompt({
    required List<CategoryScore> categoryScores,
    required Map<String, String> answers,
    StudentAcademicModel? academicData,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('You are an expert career counselor. Based on the following student data, generate career recommendations.');
    buffer.writeln();
    buffer.writeln('## Test Scores by Category:');
    for (final cs in categoryScores) {
      buffer.writeln('- ${cs.category}: ${cs.score.toStringAsFixed(1)}% (${cs.correctAnswers}/${cs.totalQuestions} correct)');
    }

    if (academicData != null) {
      buffer.writeln();
      buffer.writeln('## Academic Background:');
      if (academicData.class10Marks.isNotEmpty) {
        buffer.writeln('Class 10 marks:');
        for (final m in academicData.class10Marks) {
          buffer.writeln('  - ${m.subject}: ${m.marks}/${m.maxMarks}');
        }
      }
      if (academicData.class12Marks.isNotEmpty) {
        buffer.writeln('Class 12 (${academicData.class12Stream ?? "General"}):');
        for (final m in academicData.class12Marks) {
          buffer.writeln('  - ${m.subject}: ${m.marks}/${m.maxMarks}');
        }
      }
      if (academicData.graduationField != null) {
        buffer.writeln('Graduation: ${academicData.graduationField} (${academicData.graduationPercentage}%)');
      }
      if (academicData.pgField != null) {
        buffer.writeln('PG: ${academicData.pgField} (${academicData.pgPercentage}%)');
      }
    }

    buffer.writeln();
    buffer.writeln('Respond with JSON in this exact format:');
    buffer.writeln('''{
  "recommendations": [
    {
      "careerName": "Career Title",
      "matchPercentage": 90.0,
      "description": "Why this career suits the student",
      "skillsRequired": ["Skill1", "Skill2", "Skill3"],
      "skillsToDevelop": ["Skill1", "Skill2"],
      "educationPath": "Recommended education pathway"
    }
  ]
}''');
    buffer.writeln();
    buffer.writeln('Generate exactly 4 career recommendations, sorted by matchPercentage descending. Be specific to Indian education system and job market.');

    return buffer.toString();
  }

  String _buildFullReportPrompt({
    required double overallScore,
    required String performanceBand,
    required List<CategoryScore> categoryScores,
    required Map<String, String> answers,
    StudentAcademicModel? academicData,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('You are an expert career counselor. Generate a comprehensive career analysis report.');
    buffer.writeln();
    buffer.writeln('## Overall Score: ${overallScore.toStringAsFixed(1)}% ($performanceBand)');
    buffer.writeln();
    buffer.writeln('## Test Scores by Category:');
    for (final cs in categoryScores) {
      buffer.writeln('- ${cs.category}: ${cs.score.toStringAsFixed(1)}% (${cs.correctAnswers}/${cs.totalQuestions} correct)');
    }

    if (academicData != null) {
      buffer.writeln();
      buffer.writeln('## Academic Background:');
      if (academicData.class10Marks.isNotEmpty) {
        buffer.writeln('Class 10 marks:');
        for (final m in academicData.class10Marks) {
          buffer.writeln('  - ${m.subject}: ${m.marks}/${m.maxMarks}');
        }
      }
      if (academicData.class12Marks.isNotEmpty) {
        buffer.writeln('Class 12 (${academicData.class12Stream ?? "General"}):');
        for (final m in academicData.class12Marks) {
          buffer.writeln('  - ${m.subject}: ${m.marks}/${m.maxMarks}');
        }
      }
      if (academicData.graduationField != null) {
        buffer.writeln('Graduation: ${academicData.graduationField} (${academicData.graduationPercentage}%)');
      }
      if (academicData.pgField != null) {
        buffer.writeln('PG: ${academicData.pgField} (${academicData.pgPercentage}%)');
      }
    }

    buffer.writeln();
    buffer.writeln('Respond with JSON in this exact format:');
    buffer.writeln('''{
  "aiSummary": "A 2-3 sentence personalized summary of the student's profile and potential",
  "strengths": ["Strength 1", "Strength 2", "Strength 3"],
  "areasForImprovement": ["Area 1", "Area 2"],
  "recommendations": [
    {
      "careerName": "Career Title",
      "matchPercentage": 90.0,
      "description": "Why this career suits the student",
      "skillsRequired": ["Skill1", "Skill2", "Skill3"],
      "skillsToDevelop": ["Skill1", "Skill2"],
      "educationPath": "Recommended education pathway"
    }
  ]
}''');
    buffer.writeln();
    buffer.writeln('Generate exactly 4 career recommendations sorted by matchPercentage descending. Be specific to Indian education system and job market. Make the aiSummary personalized and encouraging.');

    return buffer.toString();
  }
}
