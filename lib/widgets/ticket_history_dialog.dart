import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketHistoryDialog extends StatelessWidget {
  final int ticketId;
  final String ticketDisplayId;
  final List<dynamic> historyData;

  const TicketHistoryDialog({
    super.key,
    required this.ticketId,
    required this.ticketDisplayId,
    required this.historyData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ticket History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ticket ID: $ticketDisplayId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
            ),
            const Divider(height: 1),
            Expanded(
              child: historyData.isEmpty
                  ? const Center(
                      child: Text('No history found for this ticket.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        final item = historyData[index];
                        final stage = historyData.length - index;
                        return _buildHistoryCard(context, item, stage);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStageTitle(String action) {
    if (action.isEmpty) return 'UPDATE';

    // Custom mapping matching f_b image format
    if (action == 'TICKET_RAISED') return 'TICKET RAISED';
    if (action == 'PC_PLANNING_COMPLETE' || action == 'PC_PLANNING')
      return 'PC PLANNING COMPLETE';
    if (action == 'TICKET_SOLVED') return 'TICKET SOLVED';
    if (action == 'PC_CONFIRMED' || action == 'PC_CONFIRM')
      return 'PC CONFIRMED';
    if (action == 'TICKET_CLOSED') return 'TICKET CLOSED';
    if (action == 'TICKET_REVISED' || action == 'DATE_REVISED')
      return 'TICKET REVISED';
    if (action == 'TICKET_RERAISED') return 'TICKET RERAISED';

    // Fallback: replace underscores with spaces
    return action.replaceAll('_', ' ');
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Map<String, dynamic> item,
    int stage,
  ) {
    final title = _getStageTitle(item['action_type']?.toString() ?? '');
    final dateStr = item['action_date'];
    final formattedDate = _formatDateTime(dateStr);
    final byUser = item['action_by'] ?? 'Unknown';
    final remarks = item['remarks'] ?? '';

    Map<String, dynamic> oldValues = {};
    if (item['old_values'] is Map) {
      oldValues = Map<String, dynamic>.from(item['old_values']);
    }

    Map<String, dynamic> newValues = {};
    if (item['new_values'] is Map) {
      newValues = Map<String, dynamic>.from(item['new_values']);
    }

    final Set<String> allKeys = {...oldValues.keys, ...newValues.keys};
    final List<String> sortedKeys = allKeys.toList()..sort();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF1A73E8),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stage $stage - $formattedDate\nTicket: $ticketDisplayId',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                Text(
                  'By User #$byUser',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Remarks: ${remarks.isEmpty ? 'No remarks' : remarks}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (sortedKeys.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'FIELD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'OLD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...sortedKeys.map((key) {
                final oldVal = oldValues.containsKey(key)
                    ? _formatValue(oldValues[key])
                    : '-';
                final newVal = newValues.containsKey(key)
                    ? _formatValue(newValues[key])
                    : '-';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          _formatKey(key),
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: _buildValueBox(oldVal, isOld: true),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: _buildValueBox(newVal, isOld: false),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValueBox(String text, {required bool isOld}) {
    final bgColor = isOld ? const Color(0xFFFFF0F0) : const Color(0xFFE6F4EA);
    final txtColor = isOld ? const Color(0xFFD32F2F) : const Color(0xFF137333);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: txtColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  String _formatValue(dynamic val) {
    if (val == null) return '-';
    final str = val.toString();
    if (str.isEmpty) return '-';

    if (str.length >= 20 && str.contains('T') && str.endsWith('Z')) {
      try {
        final date = DateTime.parse(str);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (_) {}
    }
    return str;
  }

  String _formatDateTime(dynamic val) {
    if (val == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(val.toString()).toLocal();
      return DateFormat('dd/MM/yyyy, HH:mm:ss').format(date);
    } catch (_) {
      return val.toString();
    }
  }
}
