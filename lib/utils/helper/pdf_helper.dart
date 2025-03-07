import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../model/materialModel.dart';

class PDFHelper {
  static Future<File> generatePDF(List<MaterialModel> materials) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Site Material Tracker Report",
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              for (var material in materials)
                pw.Container(
                  margin: pw.EdgeInsets.symmetric(vertical: 8),
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Material: ${material.name}",
                            style: pw.TextStyle(fontSize: 16)),
                        pw.Text("Quantity: ${material.quantity}"),
                        pw.Text("Supplier: ${material.supplier}"),
                        pw.Text(
                            "Delivery Date: ${material.deliveryDate.toString()}"),
                      ]),
                )
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/SiteMaterialReport.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> downloadPDF(BuildContext context) async {
    try {
      final pdfFile = await generatePDF([]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF downloaded at: ${pdfFile.path}"),
          action: SnackBarAction(
            label: "Open",
            onPressed: () {
              Share.shareFiles([pdfFile.path], text: "Site Material Report");
            },
          ),
        ),
      );
    } catch (e) {
      print("Error saving PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download PDF")),
      );
    }
  }

  // Function to share PDF
  static Future<void> sharePDF(File pdfFile) async {
    try {
      await Share.shareFiles([pdfFile.path], text: "Site Material Report");
    } catch (e) {
      print("Error sharing PDF: $e");
    }
  }
}
