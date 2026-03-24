import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/expense_model.dart';

class ExpenseDetailsDialog extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsDialog({Key? key, required this.expense})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy, HH:mm:ss');
    final formattedDate = dateFormat.format(expense.createdAt);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expense Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${expense.id} • ${expense.category.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Info Grid
            Row(
              children: [
                Expanded(child: _buildInfoItem('EMPLOYEE', expense.userName)),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'EMAIL',
                    expense.email.isNotEmpty ? expense.email : 'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'AMOUNT',
                    '₹${expense.amount.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoItem('CREATED AT', formattedDate)),
              ],
            ),
            const SizedBox(height: 24),

            // Description Box
            _buildSection(
              title: 'Description / Notes',
              content: expense.description.isNotEmpty
                  ? expense.description
                  : 'No description provided.',
            ),
            const SizedBox(height: 16),

            // Bill Attachment Box
            _buildSection(
              title: 'Bill Attachment',
              contentWidget: Row(
                children: [
                  if (expense.receiptUrl != null &&
                      expense.receiptUrl!.isNotEmpty) ...[
                    const Icon(
                      Icons.receipt_long,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(expense.receiptUrl!);
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          debugPrint('Could not launch $uri: $e');
                        }
                      },
                      child: const Text(
                        'View Uploaded Bill',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'No Bill Uploaded',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          if (contentWidget != null) contentWidget,
          if (content != null)
            Text(
              content,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
        ],
      ),
    );
  }
}
