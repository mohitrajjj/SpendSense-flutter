import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' show TableHelper;
import 'package:printing/printing.dart';

class ExportUtility {
  static Future<void> exportToPdf({
    required String fileName,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();
    
    if (data.isEmpty) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Text("No data to display in this report."),
          ),
        ),
      );
    } else {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.portrait,
          build: (context) => [
            pw.Text(
              "SpendSense Report",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            TableHelper.fromTextArray(
              headers: data.first.keys.toList(),
              data: data.map((item) => item.values.toList()).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '$fileName.pdf',
    );
  }
}
