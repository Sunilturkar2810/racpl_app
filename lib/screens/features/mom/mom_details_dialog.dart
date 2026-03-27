import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:racpl/theme/app_colors.dart';
import '../../../models/mom_model.dart';

class MomDetailsDialog extends StatelessWidget {
  final Mom mom;

  const MomDetailsDialog({super.key, required this.mom});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey[400] : Colors.grey[600];

    String formattedCreated = mom.createdAt;
    try {
      if (mom.createdAt.isNotEmpty) {
        final parsed = DateTime.parse(mom.createdAt);
        formattedCreated = DateFormat('dd/MM/yyyy, HH:mm:ss').format(parsed);
      }
    } catch (_) {}

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 12,
                top: 16,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MOM Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mom.momId} - ${mom.project}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'PROJECT NAME',
                            mom.project,
                            labelColor,
                            textColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            'MEETING DATE',
                            mom.date,
                            labelColor,
                            textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'TIME',
                            mom.time,
                            labelColor,
                            textColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            'LOCATION',
                            mom.location,
                            labelColor,
                            textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionContainer(
                      title: 'Attendees',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAttendeeGroup(
                            'RA TEAM',
                            mom.raTeamAttendees,
                            labelColor,
                            textColor,
                          ),
                          _buildAttendeeGroup(
                            'CLIENT TEAM',
                            mom.clientTeamAttendees,
                            labelColor,
                            textColor,
                          ),
                          _buildAttendeeGroup(
                            'VENDOR TEAM',
                            mom.vendorTeamAttendees,
                            labelColor,
                            textColor,
                          ),
                          _buildAttendeeGroup(
                            'OTHERS',
                            mom.otherAttendees,
                            labelColor,
                            textColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionContainer(
                      title: 'Minutes Discussed',
                      child: mom.minutes.isEmpty
                          ? Text(
                              'No minutes added.',
                              style: TextStyle(color: labelColor),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: mom.minutes.length,
                              separatorBuilder: (ctx, i) =>
                                  const Divider(height: 24),
                              itemBuilder: (ctx, i) => _buildMinuteItem(
                                mom.minutes[i],
                                labelColor,
                                textColor,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CREATED AT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedCreated,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    Color? labelColor,
    Color? textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeGroup(
    String title,
    List<String> list,
    Color? labelColor,
    Color? textColor,
  ) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            list.join(', '),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMinuteItem(
    MomMinute minute,
    Color? labelColor,
    Color? textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '-  ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Expanded(
              child: Text(
                minute.minutes,
                style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (minute.actionBy.isNotEmpty)
                Text(
                  'Action By: ${minute.actionBy}',
                  style: TextStyle(fontSize: 12, color: labelColor),
                ),
              if (minute.plannedCompletion.isNotEmpty ||
                  minute.actualCompletion.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Planned: ${minute.plannedCompletion}${minute.actualCompletion.isNotEmpty ? ' -> Actual: ${minute.actualCompletion}' : ''}',
                    style: TextStyle(fontSize: 12, color: labelColor),
                  ),
                ),
              if (minute.remarks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Remarks: ${minute.remarks}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
