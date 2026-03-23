import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class PdfHelper {
  static Future<void> generateAndPrintExpenseReport({
    required List<Expense> expenses,
    required String employeeName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final DateFormat docDateFormat = DateFormat('dd/MM/yyyy');
    final double totalAmount = expenses.fold(
      0,
      (sum, item) => sum + item.amount,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Expense Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  docDateFormat.format(DateTime.now()),
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Info Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoText('Employee Name:', employeeName),
                        pw.SizedBox(height: 8),
                        _buildInfoText(
                          'Total Expenses:',
                          'Rs ${totalAmount.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoText(
                          'Start Date:',
                          docDateFormat.format(startDate),
                        ),
                        pw.SizedBox(height: 8),
                        _buildInfoText(
                          'End Date:',
                          docDateFormat.format(endDate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Table Header
            pw.Text(
              'Detailed Expenses',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            // Table
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Category',
                'Description',
                'Amount (Rs)',
                'Bill',
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue600,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.center,
              },
              data: List<List<String>>.generate(expenses.length, (index) {
                final expense = expenses[index];
                bool hasBill =
                    expense.receiptUrl != null &&
                    expense.receiptUrl!.isNotEmpty;
                return [
                  docDateFormat.format(expense.createdAt),
                  expense.category,
                  expense.description.isNotEmpty ? expense.description : '-',
                  expense.amount.toStringAsFixed(0),
                  hasBill ? 'Yes' : 'No',
                ];
              }),
            ),
            pw.SizedBox(height: 40),

            // Signature Line
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 150, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Authorised Signatory',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Expense_Report_${employeeName.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildInfoText(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.TextSpan(text: value),
        ],
      ),
    );
  }
}
