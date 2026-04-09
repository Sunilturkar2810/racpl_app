import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/delegation_model.dart';
import '../../models/task_reference_model.dart';
import '../../providers/delegation_provider.dart';
import '../../services/delegation_service.dart';
import '../../theme/app_colors.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final Delegation? initialData;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.initialData,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<DelegationDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final provider = Provider.of<DelegationProvider>(context, listen: false);
    _detailFuture = provider.getDelegationRaw(widget.taskId);
  }

  Future<void> _onRefresh() async {
    setState(() => _fetchData());
    await _detailFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: FutureBuilder<DelegationDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  const Text('Failed to load task details.'),
                  TextButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No details available.'));
          }

          final detail = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TaskOverviewCard(
                    task: detail.task,
                    onDeleted: () => Navigator.of(context).pop(),
                    onRefresh: _onRefresh,
                  ),
                  const SizedBox(height: 16),
                  _EvidenceCard(task: detail.task),
                  const SizedBox(height: 16),
                  _ChecklistStatusCard(
                    task: detail.task,
                    onRefresh: _onRefresh,
                  ),
                  const SizedBox(height: 16),
                  _SubtasksCard(subtasks: detail.subtasks),
                  const SizedBox(height: 16),
                  _RemarksCard(
                    taskId: widget.taskId,
                    remarks: detail.remarks,
                    onRefresh: _onRefresh,
                  ),
                  const SizedBox(height: 16),
                  _RevisionHistoryCard(revisions: detail.revisions),
                  const SizedBox(height: 16),
                  _ActivityFeedCard(activity: detail.activity),
                  const SizedBox(height: 16),
                  _RemindersCard(reminders: detail.reminders),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------ BASE CARD ------ //

class _BaseCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  const _BaseCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ------ TASK OVERVIEW ------ //

class _TaskOverviewCard extends StatelessWidget {
  final Delegation task;
  final VoidCallback onDeleted;
  final VoidCallback onRefresh;

  const _TaskOverviewCard({
    required this.task,
    required this.onDeleted,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final delegationProvider = Provider.of<DelegationProvider>(context);
    final assignees = delegationProvider.assignees;

    final assignerName = assignees
        .firstWhere(
          (a) => a.id == task.delegatedById,
          orElse: () => const TaskAssignee(id: '', name: 'Unknown', department: ''),
        )
        .name;

    final assigneeName = assignees
        .firstWhere(
          (a) => a.id == task.delegatedToId,
          orElse: () => const TaskAssignee(id: '', name: 'Unknown', department: ''),
        )
        .name;

    // Watchers: inLoopIds resolved to names
    final watcherNames = task.inLoopIds
        .map((id) =>
            assignees
                .firstWhere(
                  (a) => a.id == id,
                  orElse: () =>
                      const TaskAssignee(id: '', name: 'Unknown', department: ''),
                )
                .name)
        .toList();

    final canEditFull = task.permissions['canEditFull'] ?? false;
    final canDelete = task.permissions['canDelete'] ?? false;

    return _BaseCard(
      title: 'Task Overview',
      subtitle: 'Execution, context, and proof of work.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEditFull) ...[
            _ActionBtn(
              icon: Icons.edit_outlined,
              label: 'Edit',
              color: const Color(0xFF334155),
              onTap: () {
                // TODO: Navigate to edit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit coming soon!')),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          if (canDelete)
            _ActionBtn(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: const Color(0xFFEF4444),
              bgColor: const Color(0xFFFEF2F2),
              onTap: () => _confirmDelete(context),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _InfoBox(label: 'ASSIGNER', value: assignerName)),
              const SizedBox(width: 12),
              Expanded(child: _InfoBox(label: 'ASSIGNEE', value: assigneeName)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: 'CATEGORY',
                  value: task.category.isEmpty ? 'N/A' : task.category,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  label: 'PRIORITY',
                  value: task.priority,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: 'DUE DATE',
                  value: task.dueDate != null
                      ? DateFormat('dd/MM/yyyy, HH:mm').format(task.dueDate!.toLocal())
                      : 'Not set',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  label: 'DEPARTMENTS',
                  value: task.departments.isEmpty ? 'None' : task.departments.join(', '),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoBox(
            label: 'DESCRIPTION',
            value: task.description.isEmpty ? 'No description' : task.description,
          ),
          const SizedBox(height: 12),
          _InfoBox(
            label: 'WATCHERS',
            value: watcherNames.isEmpty ? 'None' : watcherNames.join(', '),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await Provider.of<DelegationProvider>(context, listen: false)
                    .deleteDelegation(task.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted successfully.')),
                  );
                  onDeleted();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete failed: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ------ INFO BOX ------ //

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// ------ ACTION BUTTON ------ //

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.bgColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: bgColor == Colors.white
                ? const Color(0xFFE2E8F0)
                : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------ CHECKLIST + STATUS CARD ------ //

class _ChecklistStatusCard extends StatefulWidget {
  final Delegation task;
  final VoidCallback onRefresh;

  const _ChecklistStatusCard({required this.task, required this.onRefresh});

  @override
  State<_ChecklistStatusCard> createState() => _ChecklistStatusCardState();
}

class _ChecklistStatusCardState extends State<_ChecklistStatusCard> {
  static const _statuses = [
    'Pending',
    'In Progress',
    'Completed',
    'Need Revision',
    'Hold',
  ];

  late String _selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    if (newStatus == _selectedStatus) return;
    setState(() => _isUpdating = true);
    try {
      final service = Provider.of<DelegationProvider>(context, listen: false);
      await service.updateDelegation(widget.task.id, status: newStatus);
      setState(() => _selectedStatus = newStatus);
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to "$newStatus"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEditDoer = widget.task.permissions['canEditDoerFields'] ?? false;
    final canEditFull = widget.task.permissions['canEditFull'] ?? false;
    final canChangeStatus = canEditDoer || canEditFull;

    return _BaseCard(
      title: 'Checklist + Status',
      subtitle: 'Doers can update progress, evidence, and completion state.',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isUpdating)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (canChangeStatus)
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      items: _statuses
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) _updateStatus(val);
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        _selectedStatus,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'PROGRESS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.task.checklistCount == 0
                          ? 0
                          : widget.task.completedChecklistCount /
                              widget.task.checklistCount,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.task.completedChecklistCount}/${widget.task.checklistCount} completed',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // CHECKLIST column
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CHECKLIST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.task.checklistCount == 0)
                    const Text(
                      'No checklist items.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.task.checklistCount,
                    itemBuilder: (context, index) {
                      final isDone = index < widget.task.completedChecklistCount;
                      return ListTile(
                        dense: true,
                        horizontalTitleGap: 0,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isDone
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank,
                          size: 20,
                          color: isDone
                              ? AppColors.primary
                              : const Color(0xFFCBD5E1),
                        ),
                        title: Text(
                          'Item ${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------ SUBTASKS CARD ------ //

class _SubtasksCard extends StatelessWidget {
  final List<Delegation> subtasks;
  const _SubtasksCard({required this.subtasks});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Subtasks',
      subtitle: 'Separate records linked by parentId.',
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 36),
        ),
        onPressed: () {},
        child: const Text(
          'Add Subtask',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      child: subtasks.isEmpty
          ? _EmptyBox('No subtasks yet.')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subtasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sub = subtasks[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sub.taskName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      _StatusChip(status: sub.status),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color _color() {
    switch (status) {
      case 'Completed':
        return const Color(0xFF10B981);
      case 'In Progress':
        return const Color(0xFFF59E0B);
      case 'Need Revision':
        return const Color(0xFFF43F5E);
      case 'Hold':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

// ------ REMARKS CARD ------ //

class _RemarksCard extends StatefulWidget {
  final String taskId;
  final List<TaskRemark> remarks;
  final VoidCallback onRefresh;

  const _RemarksCard({
    required this.taskId,
    required this.remarks,
    required this.onRefresh,
  });

  @override
  State<_RemarksCard> createState() => _RemarksCardState();
}

class _RemarksCardState extends State<_RemarksCard> {
  final _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _postRemark() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final provider = Provider.of<DelegationProvider>(context, listen: false);
      await provider.addRemark(widget.taskId, text);
      _controller.clear();
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remark posted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post remark: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Remarks',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Comments create history and notifications.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Add a remark...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _isPosting ? null : _postRemark,
            child: _isPosting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Post Remark',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
          const SizedBox(height: 20),
          _BaseCard(
            title: 'Remarks Timeline',
            subtitle: '${widget.remarks.length} item(s)',
            child: widget.remarks.isEmpty
                ? _EmptyBox('No remarks yet.')
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.remarks.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final r = widget.remarks[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.remarkText,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(r.createdAt.toLocal()),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ------ REVISION HISTORY CARD ------ //

class _RevisionHistoryCard extends StatelessWidget {
  final List<TaskRevision> revisions;
  const _RevisionHistoryCard({required this.revisions});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Revision History',
      subtitle: '${revisions.length} item(s)',
      child: revisions.isEmpty
          ? _EmptyBox('No revisions.')
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemCount: revisions.length,
              itemBuilder: (context, index) {
                final rev = revisions[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rev.oldStatus.isNotEmpty || rev.newStatus.isNotEmpty)
                      _RevisionRow(
                        label: 'Status',
                        oldVal: rev.oldStatus,
                        newVal: rev.newStatus,
                      ),
                    if (rev.oldDueDate.isNotEmpty || rev.newDueDate.isNotEmpty)
                      _RevisionRow(
                        label: 'Due Date',
                        oldVal: _fmtDate(rev.oldDueDate),
                        newVal: _fmtDate(rev.newDueDate),
                      ),
                    if (rev.reason.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${rev.reason}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(rev.createdAt.toLocal()),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                );
              },
            ),
    );
  }

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '-';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM/yyyy').format(dt.toLocal());
  }
}

class _RevisionRow extends StatelessWidget {
  final String label;
  final String oldVal;
  final String newVal;

  const _RevisionRow({
    required this.label,
    required this.oldVal,
    required this.newVal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          Text(
            oldVal.isEmpty ? '-' : oldVal,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFEF4444),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const Text(' → ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(
            newVal.isEmpty ? '-' : newVal,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ------ ACTIVITY FEED CARD ------ //

class _ActivityFeedCard extends StatelessWidget {
  final List<TaskActivity> activity;
  const _ActivityFeedCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Activity Feed',
      subtitle: '${activity.length} item(s)',
      child: activity.isEmpty
          ? _EmptyBox('No activity.')
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activity.length,
              itemBuilder: (context, index) {
                final a = activity[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.description,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${a.action} • ${DateFormat('dd/MM/yyyy HH:mm').format(a.createdAt.toLocal())}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ------ REMINDERS CARD ------ //

class _RemindersCard extends StatelessWidget {
  final List<TaskReminder> reminders;
  const _RemindersCard({required this.reminders});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Reminders',
      subtitle: '${reminders.length} item(s)',
      child: reminders.isEmpty
          ? _EmptyBox('No reminders configured.')
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final r = reminders[index];
                final timeLabel = r.reminderTime != null
                    ? DateFormat('dd MMM yyyy, HH:mm').format(r.reminderTime!.toLocal())
                    : 'Time not set';
                return ListTile(
                  leading: const Icon(Icons.alarm, color: AppColors.primary),
                  title: Text(
                    r.type.isNotEmpty ? r.type : 'Reminder ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(timeLabel),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
    );
  }
}

// ------ EMPTY BOX ------ //

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------ EVIDENCE CARD ------ //

class _EvidenceCard extends StatelessWidget {
  final Delegation task;
  const _EvidenceCard({required this.task});

  @override
  Widget build(BuildContext context) {
    if (!task.evidenceRequired &&
        task.referenceDocs.isEmpty &&
        task.evidenceUrl.isEmpty &&
        (task.voiceNoteUrl == null || task.voiceNoteUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return _BaseCard(
      title: 'Evidence and Attachments',
      subtitle: task.evidenceRequired ? 'Evidence is REQUIRED to mark this task as complete.' : 'Attachments & reference materials',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (task.evidenceRequired) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Evidence Required for Completion',
                      style: TextStyle(
                        color: Color(0xFF991B1B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (task.voiceNoteUrl != null && task.voiceNoteUrl!.isNotEmpty) ...[
            _InfoBox(label: 'VOICE NOTE', value: task.voiceNoteUrl!),
            const SizedBox(height: 12),
          ],
          if (task.referenceDocs.isNotEmpty) ...[
            _ListInfoBox(label: 'REFERENCE DOCUMENTS', items: task.referenceDocs),
            const SizedBox(height: 12),
          ],
          if (task.evidenceUrl.isNotEmpty) ...[
            _ListInfoBox(label: 'SUBMITTED EVIDENCE', items: task.evidenceUrl),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ListInfoBox extends StatelessWidget {
  final String label;
  final List<String> items;
  const _ListInfoBox({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
