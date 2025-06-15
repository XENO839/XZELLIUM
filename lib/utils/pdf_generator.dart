/*import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> generatePdfReport({
  required int score,
  required int total,
  required String detailedInsight,
  required String userName,
  required bool isPremiumUser,
  required Uint8List donutChartBytes,
  required Uint8List barChartBytes,
  required String domainName,
}) async {
  final pdf = pw.Document();
  final percent = (score / total * 100).toStringAsFixed(1);

  final List<String> sections = detailedInsight.split(
    RegExp(
      r'(?=Skill Summary:|Strengths:|Areas to Improve:|Job Market Standing:|Recommended Courses:|Projects:|Tech Stacks:|Resume Tips:)',
    ),
  );

  final soraFont = await _loadFont('Sora-Bold.ttf');
  final interFont = await _loadFont('Inter-Regular.ttf');

  final logo = pw.MemoryImage(
    await rootBundle
        .load('assets/icon/xzellium_icon.png')
        .then((d) => d.buffer.asUint8List()),
  );
  final donutChart = pw.MemoryImage(donutChartBytes);
  final barChart = pw.MemoryImage(barChartBytes);

  final pageTheme = pw.PageTheme(
    margin: const pw.EdgeInsets.all(32),
    theme: pw.ThemeData.withFont(base: interFont, bold: soraFont),
    buildBackground: (_) => pw.FullPage(
      ignoreMargins: true,
      child: pw.Container(color: PdfColor.fromHex('#0E0E12')),
    ),
  );

  List<pw.Widget> pageWidgets = [];

  // COVER PAGE
  pdf.addPage(
    pw.Page(
      pageTheme: pageTheme,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(height: 40),
          pw.Image(logo, height: 80),
          pw.SizedBox(height: 24),
          pw.Text(
            "Xzellium Skill Assessment Report",
            style: pw.TextStyle(
              color: PdfColor.fromHex("#00E6D0"),
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            domainName,
            style: pw.TextStyle(
              color: PdfColor.fromHex("#4C00FF"),
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text("Name: $userName", style: _infoStyle()),
          pw.Text("Score: $score / $total ($percent%)", style: _infoStyle()),
          pw.Text(
            "Premium: ${isPremiumUser ? "Yes" : "No"}",
            style: _infoStyle(),
          ),
        ],
      ),
    ),
  );

  // CHARTS PAGE
  pdf.addPage(
    pw.Page(
      pageTheme: pageTheme,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "📊 Performance Visuals",
            style: pw.TextStyle(
              color: PdfColor.fromHex("#4C00FF"),
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Image(donutChart, height: 160),
          pw.SizedBox(height: 24),
          pw.Image(barChart, height: 180),
        ],
      ),
    ),
  );

  // INSIGHTS SECTION
  for (var section in sections) {
    if (section.trim().isEmpty) continue;

    final lines = section.trim().split('\n');
    final titleLine = lines.first.trim();
    final content = lines.skip(1).join('\n').trim();
    final titleColor = _getTitleColor(titleLine);

    pageWidgets.add(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titleLine,
            style: pw.TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            content,
            style: pw.TextStyle(
              color: PdfColor.fromHex("#EDEDED"),
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 18),
        ],
      ),
    );
  }

  final chunks = _chunkWidgets(pageWidgets, 4);
  for (var chunk in chunks) {
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (context) => pw.Column(children: chunk),
      ),
    );
  }

  return pdf.save();
}

pw.TextStyle _infoStyle() {
  return pw.TextStyle(color: PdfColor.fromHex("#B0B0B0"), fontSize: 12);
}

PdfColor _getTitleColor(String title) {
  if (title.contains("Strength")) return PdfColor.fromHex("#2ECC71");
  if (title.contains("Improve")) return PdfColor.fromHex("#F39C12");
  if (title.contains("Tech Stack")) return PdfColor.fromHex("#4C00FF");
  if (title.contains("Courses") || title.contains("Projects"))
    return PdfColor.fromHex("#00E6D0");
  if (title.contains("Resume")) return PdfColor.fromHex("#E9455A");
  return PdfColor.fromHex("#E9455A");
}

Future<pw.Font> _loadFont(String filename) async {
  final fontData = await rootBundle.load("assets/fonts/$filename");
  return pw.Font.ttf(fontData);
}

List<List<pw.Widget>> _chunkWidgets(List<pw.Widget> widgets, int chunkSize) {
  List<List<pw.Widget>> chunks = [];
  for (var i = 0; i < widgets.length; i += chunkSize) {
    chunks.add(
      widgets.sublist(
        i,
        (i + chunkSize > widgets.length) ? widgets.length : i + chunkSize,
      ),
    );
  }
  return chunks;
}
*/
