import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketDetailDialog extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetailDialog({super.key, required this.ticketData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final issueText = (ticketData['issue_description'] ?? 'N/A').toString();
    final statusText = ('${ticketData['status'] ?? 'UNKNOWN'}').toUpperCase();
    final attachment = (ticketData['proof_upload'] ?? '').toString();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                            Text(
                              (ticketData['ticket_id'] ??
                                      ticketData['help_ticket_no'] ??
                                      '#HT-Unknown')
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            _buildStatusChip(statusText),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ticket Details',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: 'Issue Summary',
                      child: Text(
                        issueText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Ticket Information',
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = constraints.maxWidth > 520
                              ? (constraints.maxWidth - 16) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              SizedBox(
                                width: itemWidth,
                                child: _buildInfoTile(
                                  context,
                                  'Desired Date',
                                  _formatDate(
                                    ticketData['desired_date'] ??
                                        ticketData['created_at'],
                                  ),
                                  Icons.event_outlined,
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: _buildInfoTile(
                                  context,
                                  'Location',
                                  (ticketData['location'] ?? 'N/A').toString(),
                                  Icons.location_on_outlined,
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: _buildInfoTile(
                                  context,
                                  'PC Owner',
                                  (ticketData['pc_name'] ??
                                          ticketData['assigned_to_name'] ??
                                          'N/A')
                                      .toString(),
                                  Icons.person_outline,
                                ),
                              ),
                              SizedBox(
                                width: itemWidth,
                                child: _buildInfoTile(
                                  context,
                                  'Current Status',
                                  statusText,
                                  Icons.track_changes_outlined,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Attachment',
                      child: attachment.isNotEmpty
                          ? OutlinedButton.icon(
                              onPressed: () => _openAttachment(
                                context,
                                attachment,
                              ),
                              icon: const Icon(Icons.attach_file),
                              label: const Text('View Attachment'),
                            )
                          : Row(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openAttachment(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open attachment')),
        );
      }
    }
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
}
