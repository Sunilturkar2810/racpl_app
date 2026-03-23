import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketDetailDialog extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetailDialog({super.key, required this.ticketData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticketData['ticket_id'] ??
                          ticketData['help_ticket_no'] ??
                          '#HT-Unknown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ('${ticketData['status'] ?? 'UNKNOWN'}').toUpperCase(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Divider(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(context, 'ISSUE'),
                      _buildValue(
                        context,
                        ticketData['issue_description'] ?? 'N/A',
                      ),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'DESIRED DATE'),
                      _buildValue(
                        context,
                        _formatDate(
                          ticketData['desired_date'] ??
                              ticketData['created_at'],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(context, 'LOCATION'),
                      _buildValue(context, ticketData['location'] ?? 'N/A'),
                      const SizedBox(height: 16),
                      _buildLabel(context, 'PC OWNER'),
                      _buildValue(
                        context,
                        ticketData['pc_name'] ??
                            ticketData['assigned_to_name'] ??
                            'N/A',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (ticketData['proof_upload'] != null &&
                ticketData['proof_upload'].toString().isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  final url = Uri.parse(ticketData['proof_upload'].toString());
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open attachment'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('View Attachment'),
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No Attachment',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return dateStr.toString();
    }
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildValue(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.bodyLarge);
  }
}
