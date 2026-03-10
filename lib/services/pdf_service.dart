import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/report_model.dart';

class PdfService {
  static Future<String?> generateReportPdf(ReportModel report) async {
    final document = PdfDocument();
    final page = document.pages.add();
    final graphics = page.graphics;
    final pageSize = page.getClientSize();

    double y = 0;

    // Title
    graphics.drawString(
      'Guidance Guru - Career Report',
      PdfStandardFont(PdfFontFamily.helvetica, 22, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, pageSize.width, 30),
    );
    y += 35;

    // Overall Score
    graphics.drawString(
      'Overall Score: ${report.overallScore.toInt()}% (${report.performanceBand})',
      PdfStandardFont(PdfFontFamily.helvetica, 16),
      bounds: Rect.fromLTWH(0, y, pageSize.width, 24),
    );
    y += 30;

    // AI Summary
    if (report.aiSummary != null) {
      graphics.drawString(
        'AI Summary',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
      );
      y += 22;
      graphics.drawString(
        report.aiSummary!,
        PdfStandardFont(PdfFontFamily.helvetica, 11),
        bounds: Rect.fromLTWH(0, y, pageSize.width, 60),
      );
      y += 50;
    }

    // Category Scores
    graphics.drawString(
      'Category Scores',
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
    );
    y += 22;

    for (final cs in report.categoryScores) {
      graphics.drawString(
        '${cs.category}: ${cs.score.toStringAsFixed(1)}% (${cs.correctAnswers}/${cs.totalQuestions})',
        PdfStandardFont(PdfFontFamily.helvetica, 11),
        bounds: Rect.fromLTWH(10, y, pageSize.width - 10, 18),
      );
      y += 18;
    }
    y += 10;

    // Strengths
    if (report.strengths != null && report.strengths!.isNotEmpty) {
      graphics.drawString(
        'Strengths',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
      );
      y += 22;
      for (final s in report.strengths!) {
        graphics.drawString(
          '• $s',
          PdfStandardFont(PdfFontFamily.helvetica, 11),
          bounds: Rect.fromLTWH(10, y, pageSize.width - 10, 18),
        );
        y += 18;
      }
      y += 10;
    }

    // Career Recommendations
    graphics.drawString(
      'Career Recommendations',
      PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
    );
    y += 24;

    for (var i = 0; i < report.recommendations.length; i++) {
      final rec = report.recommendations[i];

      if (y > pageSize.height - 100) {
        final newPage = document.pages.add();
        graphics.drawString('', PdfStandardFont(PdfFontFamily.helvetica, 1));
        y = 0;
        _drawRecommendation(newPage.graphics, rec, i + 1, y, pageSize.width);
        y += 80;
        continue;
      }

      _drawRecommendation(graphics, rec, i + 1, y, pageSize.width);
      y += 80;
    }

    // Save
    final bytes = await document.save();
    document.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/guidance_guru_report.pdf');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  static void _drawRecommendation(
    PdfGraphics graphics,
    CareerRecommendation rec,
    int rank,
    double y,
    double width,
  ) {
    graphics.drawString(
      '#$rank ${rec.careerName} (${rec.matchPercentage.toInt()}% match)',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, width, 18),
    );
    y += 18;

    graphics.drawString(
      rec.description,
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(10, y, width - 10, 36),
    );
    y += 30;

    graphics.drawString(
      'Education: ${rec.educationPath}',
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.italic),
      bounds: Rect.fromLTWH(10, y, width - 10, 18),
    );
  }
}
