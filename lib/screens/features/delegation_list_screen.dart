import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/delegation_model.dart';
import '../../models/task_reference_model.dart';
import '../../providers/delegation_provider.dart';
import '../../theme/app_colors.dart';
import 'create_task_sheet.dart';
import 'task_detail_screen.dart';

enum TaskSection {
  myTasks,
  delegatedTasks,
  subscribedTasks,
  allTasks,
  deletedTasks,
}

class DelegationListScreen extends StatefulWidget {
  final TaskSection section;

  const DelegationListScreen({super.key, required this.section});

  @override
  State<DelegationListScreen> createState() => _DelegationListScreenState();
}

class _DelegationListScreenState extends State<DelegationListScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All Statuses';
  String _selectedAssigneeId = 'all';
  String _selectedCategory = 'All Categories';
  String _selectedDepartment = 'All Departments';
  String _selectedDateRange = 'All Time';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<DelegationProvider>();
      provider.fetchTaskReferenceData();
      _loadSection(widget.section);
    });
  }

  Future<void> _loadSection(TaskSection section) async {
    final provider = context.read<DelegationProvider>();
    switch (section) {
      case TaskSection.myTasks:
        return provider.fetchDelegations(scope: 'assignedToMe');
      case TaskSection.delegatedTasks:
        return provider.fetchDelegations(scope: 'assignedByMe');
      case TaskSection.subscribedTasks:
        return provider.fetchDelegations(scope: 'watching');
      case TaskSection.allTasks:
        return provider.fetchDelegations();
      case TaskSection.deletedTasks:
        return provider.fetchDelegations(
          includeDeleted: true,
          deletedOnly: true,
        );
    }
  }

  Future<void> _openCreateTaskDialog() async {
    final provider = context.read<DelegationProvider>();
    final created = await showCreateTaskSheet(
      context,
      assignees: provider.assignees,
      categories: provider.categories,
      departments: provider.departments,
    );

    if (created == true && mounted) {
      await context.read<DelegationProvider>().refreshDelegations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task successfully bana diya! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DelegationProvider>(
      builder: (context, provider, _) {
        final assigneeNameById = {
          for (final assignee in provider.assignees) assignee.id: assignee.name,
        };
        final filteredTasks = _applyFilters(provider.delegations);

        if (provider.isLoading && provider.delegations.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.hasError && provider.delegations.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_titleFor(widget.section)),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.error?.message ?? 'Unable to load tasks'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadSection(widget.section),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          appBar: AppBar(
            title: Text(_titleFor(widget.section)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: _TaskWorkspace(
              title: _titleFor(widget.section),
              section: widget.section,
              tasks: provider.delegations,
              filteredTasks: filteredTasks,
              provider: provider,
              assignees: provider.assignees,
              categories: provider.categories,
              departments: provider.departments,
              assigneeNameById: assigneeNameById,
              searchQuery: _searchQuery,
              selectedStatus: _selectedStatus,
              selectedAssigneeId: _selectedAssigneeId,
              selectedCategory: _selectedCategory,
              selectedDepartment: _selectedDepartment,
              selectedDateRange: _selectedDateRange,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onStatusChanged: (value) =>
                  setState(() => _selectedStatus = value),
              onAssigneeChanged: (value) =>
                  setState(() => _selectedAssigneeId = value),
              onCategoryChanged: (value) =>
                  setState(() => _selectedCategory = value),
              onDepartmentChanged: (value) =>
                  setState(() => _selectedDepartment = value),
              onDateRangeChanged: (value) async {
                if (value == 'Custom') {
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange:
                        _customStartDate != null && _customEndDate != null
                        ? DateTimeRange(
                            start: _customStartDate!,
                            end: _customEndDate!,
                          )
                        : null,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Color(0xFF0F172A),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _customStartDate = picked.start;
                      _customEndDate = picked.end;
                      _selectedDateRange =
                          'Custom: ${DateFormat('dd MMM').format(picked.start)} - ${DateFormat('dd MMM').format(picked.end)}';
                    });
                  }
                } else {
                  setState(() => _selectedDateRange = value);
                }
              },
              onCreateTask: _openCreateTaskDialog,
            ),
          ),
        );
      },
    );
  }

  List<Delegation> _applyFilters(List<Delegation> tasks) {
    return tasks.where((task) {
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matches =
            task.taskName.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
        if (!matches) return false;
      }

      if (_selectedStatus != 'All Statuses' && task.status != _selectedStatus) {
        return false;
      }
      if (_selectedAssigneeId != 'all' &&
          task.delegatedToId != _selectedAssigneeId) {
        return false;
      }
      if (_selectedCategory != 'All Categories' &&
          task.category != _selectedCategory) {
        return false;
      }
      if (_selectedDepartment != 'All Departments' &&
          !task.departments.contains(_selectedDepartment)) {
        return false;
      }
      return _matchesDateRange(task.dueDate);
    }).toList();
  }

  bool _matchesDateRange(DateTime? dueDate) {
    if (_selectedDateRange == 'All Time') return true;
    if (dueDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dueDate.year, dueDate.month, dueDate.day);

    switch (_selectedDateRange) {
      case 'Today':
        return date == today;
      case 'This Week':
        return date.isAfter(today.subtract(const Duration(days: 1))) &&
            date.isBefore(today.add(const Duration(days: 7)));
      case 'This Month':
        return date.year == today.year && date.month == today.month;
      case 'Overdue':
        return date.isBefore(today);
      default:
        if (_selectedDateRange.startsWith('Custom') &&
            _customStartDate != null &&
            _customEndDate != null) {
          final start = DateTime(
            _customStartDate!.year,
            _customStartDate!.month,
            _customStartDate!.day,
          );
          final end = DateTime(
            _customEndDate!.year,
            _customEndDate!.month,
            _customEndDate!.day,
          );
          return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
              (date.isAtSameMomentAs(end) || date.isBefore(end));
        }
        return true;
    }
  }

  String _titleFor(TaskSection section) {
    switch (section) {
      case TaskSection.myTasks:
        return 'My Tasks';
      case TaskSection.delegatedTasks:
        return 'Delegated Tasks';
      case TaskSection.subscribedTasks:
        return 'Subscribed Tasks';
      case TaskSection.allTasks:
        return 'All Tasks';
      case TaskSection.deletedTasks:
        return 'Deleted Tasks';
    }
  }
}

class _TaskWorkspace extends StatelessWidget {
  final String title;
  final TaskSection section;
  final List<Delegation> tasks;
  final List<Delegation> filteredTasks;
  final List<TaskAssignee> assignees;
  final List<TaskCategory> categories;
  final List<TaskDepartment> departments;
  final Map<String, String> assigneeNameById;
  final String searchQuery;
  final String selectedStatus;
  final String selectedAssigneeId;
  final String selectedCategory;
  final String selectedDepartment;
  final String selectedDateRange;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onAssigneeChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onDateRangeChanged;
  final VoidCallback onCreateTask;
  final dynamic provider;

  const _TaskWorkspace({
    required this.title,
    required this.section,
    required this.tasks,
    required this.filteredTasks,
    required this.provider,
    required this.assignees,
    required this.categories,
    required this.departments,
    required this.assigneeNameById,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedAssigneeId,
    required this.selectedCategory,
    required this.selectedDepartment,
    required this.selectedDateRange,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onAssigneeChanged,
    required this.onCategoryChanged,
    required this.onDepartmentChanged,
    required this.onDateRangeChanged,
    required this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _TaskStats.fromTasks(tasks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _AutoScrollRow(
          children: [
            const SizedBox(width: 4),
            _SummaryCard(
              title: 'Total Tasks',
              value: stats.total,
              icon: Icons.checklist_rtl_rounded,
              color: const Color(0xFF2180F3),
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: 'Completed',
              value: stats.completed,
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: 'In Progress',
              value: stats.inProgress,
              icon: Icons.autorenew_rounded,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: 'Pending',
              value: stats.pending,
              icon: Icons.schedule_rounded,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: 'Revision',
              value: stats.revision,
              icon: Icons.adjust_rounded,
              color: const Color(0xFFF43F5E),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ControlPanel(
          searchQuery: searchQuery,
          selectedStatus: selectedStatus,
          selectedAssigneeId: selectedAssigneeId,
          selectedCategory: selectedCategory,
          selectedDepartment: selectedDepartment,
          selectedDateRange: selectedDateRange,
          statuses: const [
            'All Statuses',
            'Pending',
            'In Progress',
            'Completed',
            'Need Revision',
            'Hold',
          ],
          assignees: assignees,
          categories: categories,
          departments: departments,
          onSearchChanged: onSearchChanged,
          onStatusChanged: onStatusChanged,
          onAssigneeChanged: onAssigneeChanged,
          onCategoryChanged: onCategoryChanged,
          onDepartmentChanged: onDepartmentChanged,
          onDateRangeChanged: onDateRangeChanged,
          onCreateTask: onCreateTask,
        ),
        const SizedBox(height: 18),
        if (filteredTasks.isEmpty)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDCE5F0)),
              ),
              child: Center(
                child: Text(
                  'Is filter ke liye koi task nahi mila.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.refreshDelegations(),
              child: _TaskCardList(
                tasks: filteredTasks,
                assigneeNameById: assigneeNameById,
                showDeletedDate: section == TaskSection.deletedTasks,
              ),
            ),
          ),
      ],
    );
  }
}

class _TaskStats {
  final int total;
  final int completed;
  final int inProgress;
  final int pending;
  final int revision;

  const _TaskStats({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.revision,
  });

  factory _TaskStats.fromTasks(List<Delegation> tasks) {
    return _TaskStats(
      total: tasks.length,
      completed: tasks.where((task) => task.status == 'Completed').length,
      inProgress: tasks.where((task) => task.status == 'In Progress').length,
      pending: tasks.where((task) => task.status == 'Pending').length,
      revision: tasks.where((task) => task.status == 'Need Revision').length,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  final String searchQuery;
  final String selectedStatus;
  final String selectedAssigneeId;
  final String selectedCategory;
  final String selectedDepartment;
  final String selectedDateRange;
  final List<String> statuses;
  final List<TaskAssignee> assignees;
  final List<TaskCategory> categories;
  final List<TaskDepartment> departments;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onAssigneeChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onDateRangeChanged;
  final VoidCallback onCreateTask;

  const _ControlPanel({
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedAssigneeId,
    required this.selectedCategory,
    required this.selectedDepartment,
    required this.selectedDateRange,
    required this.statuses,
    required this.assignees,
    required this.categories,
    required this.departments,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onAssigneeChanged,
    required this.onCategoryChanged,
    required this.onDepartmentChanged,
    required this.onDateRangeChanged,
    required this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE5F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: searchQuery)
                    ..selection = TextSelection.collapsed(
                      offset: searchQuery.length,
                    ),
                  onChanged: onSearchChanged,
                  style: const TextStyle(fontSize: 14),
                  decoration:
                      _input(
                        'Search tasks...',
                        icon: Icons.search_rounded,
                      ).copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onCreateTask,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'New Task',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterDropdown(
                  'Status',
                  selectedStatus,
                  statuses
                      .map<(String, String)>((item) => (item, item))
                      .toList(),
                  onStatusChanged,
                ),
                const SizedBox(width: 12),
                _filterDropdown('Assignee', selectedAssigneeId, [
                  ('all', 'All Assignees'),
                  ...assignees.map<(String, String)>(
                    (item) => (item.id, item.name),
                  ),
                ], onAssigneeChanged),
                const SizedBox(width: 12),
                _filterDropdown('Category', selectedCategory, [
                  ('All Categories', 'All Categories'),
                  ...categories.map<(String, String)>(
                    (item) => (item.name, item.name),
                  ),
                ], onCategoryChanged),
                const SizedBox(width: 12),
                _filterDropdown('Department', selectedDepartment, [
                  ('All Departments', 'All Departments'),
                  ...departments.map<(String, String)>(
                    (item) => (item.name, item.name),
                  ),
                ], onDepartmentChanged),
                const SizedBox(width: 12),
                _filterDropdown('Date Range', selectedDateRange, [
                  ('All Time', 'All Time'),
                  ('Today', 'Today'),
                  ('This Week', 'This Week'),
                  ('This Month', 'This Month'),
                  ('Overdue', 'Overdue'),
                  ('Custom', 'Custom Range'),
                ], onDateRangeChanged),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: const Color(0xFFF8FAFD),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFDCE5F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFDCE5F0)),
    ),
  );

  Widget _filterDropdown(
    String label,
    String value,
    List<(String, String)> items,
    ValueChanged<String> onChanged,
  ) {
    String valueLabel;

    // Check if it's a dynamic custom value that doesn't exist in the static items
    final hasItem = items.any((item) => item.$1 == value);
    if (!hasItem && value.startsWith('Custom:')) {
      valueLabel = value; // Use the value itself (e.g. Custom: Jan 12 - Jan 15)
    } else {
      valueLabel = items
          .firstWhere((item) => item.$1 == value, orElse: () => items.first)
          .$2;
    }

    return CustomFilterDropdown(
      label: label,
      valueLabel: valueLabel,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}

class _TaskCardList extends StatelessWidget {
  final List<Delegation> tasks;
  final Map<String, String> assigneeNameById;
  final bool showDeletedDate;

  const _TaskCardList({
    required this.tasks,
    required this.assigneeNameById,
    required this.showDeletedDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final assignee = assigneeNameById[task.delegatedToId] ?? 'Unknown';
        final department = task.departments.isEmpty
            ? '-'
            : task.departments.join(', ');
        final dateText = showDeletedDate
            ? _formatDate(task.deletedAt)
            : _formatDate(task.dueDate);

        return _TaskCard(
          task: task,
          assignee: assignee,
          department: department,
          dateText: dateText,
        );
      },
    );
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd/MM/yyyy').format(value.toLocal());
  }
}

class _TaskCard extends StatelessWidget {
  final Delegation task;
  final String assignee;
  final String department;
  final String dateText;

  const _TaskCard({
    required this.task,
    required this.assignee,
    required this.department,
    required this.dateText,
  });

  Color _statusColor(String status) {
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
    final statusColor = _statusColor(task.status);
    final initial = assignee.isNotEmpty ? assignee[0].toUpperCase() : '?';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(
              taskId: task.id,
              initialData: task,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Category, Assignee, Date (Compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Category & Assignee
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        task.category.isEmpty ? 'General' : task.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        assignee.split(' ').first,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right: Date
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class CustomFilterDropdown extends StatefulWidget {
  final String label;
  final String valueLabel;
  final String value;
  final List<(String, String)> items;
  final Function(String) onChanged;

  const CustomFilterDropdown({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<CustomFilterDropdown> createState() => _CustomFilterDropdownState();
}

class _CustomFilterDropdownState extends State<CustomFilterDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final dropWidth = size.width < 180 ? 180.0 : size.width;

    // Flip up if not enough space below
    final screenH = MediaQuery.of(context).size.height;
    final spaceBelow = screenH - offset.dy - size.height;
    final showAbove = spaceBelow < 260;
    final topPos = showAbove
        ? offset.dy - 8
        : offset.dy + size.height + 6;

    return OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          // Dismiss tap area
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: dropWidth,
            left: offset.dx,
            top: showAbove ? null : topPos,
            bottom: showAbove
                ? MediaQuery.of(ctx).size.height - offset.dy + 6
                : null,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 14,
                      endIndent: 14,
                      color: const Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (ctx2, index) {
                      final item = widget.items[index];
                      final isSelected = widget.value == item.$1;
                      return InkWell(
                        onTap: () {
                          widget.onChanged(item.$1);
                          _closeDropdown();
                        },
                        splashColor: AppColors.primary.withValues(alpha: 0.08),
                        highlightColor:
                            AppColors.primary.withValues(alpha: 0.04),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.07)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              // Colored dot for selected
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.$2,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFF334155),
                                    letterSpacing: 0.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primary,
                                    size: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Checks whether the active value is not the default (first item)
  bool get _isFiltered => widget.value != widget.items.firstOrNull?.$1;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isOpen
                ? AppColors.primary.withValues(alpha: 0.1)
                : _isFiltered
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (_isOpen || _isFiltered)
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : const Color(0xFFDCE5F0),
              width: (_isOpen || _isFiltered) ? 1.5 : 1,
            ),
            boxShadow: (_isOpen || _isFiltered)
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter icon — shows colored when active
              Icon(
                _isFiltered
                    ? Icons.filter_alt_rounded
                    : Icons.tune_rounded,
                size: 14,
                color: (_isOpen || _isFiltered)
                    ? AppColors.primary
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: (_isOpen || _isFiltered)
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : const Color(0xFF94A3B8),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.valueLabel,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: (_isOpen || _isFiltered)
                          ? AppColors.primary
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: (_isOpen || _isFiltered)
                      ? AppColors.primary
                      : const Color(0xFF94A3B8),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Auto-scrolling horizontal row — smoothly scrolls left, then right, loops.
/// Pauses when user touches it, resumes after 2 seconds.
class _AutoScrollRow extends StatefulWidget {
  final List<Widget> children;

  const _AutoScrollRow({required this.children});

  @override
  State<_AutoScrollRow> createState() => _AutoScrollRowState();
}

class _AutoScrollRowState extends State<_AutoScrollRow> {
  late final ScrollController _controller;
  Timer? _scrollTimer;
  Timer? _resumeTimer;
  bool _forward = true;
  bool _paused = false;

  static const double _speed = 0.5; // pixels per tick
  static const Duration _tickInterval = Duration(milliseconds: 16); // ~60fps
  static const Duration _resumeDelay = Duration(seconds: 2);
  static const Duration _startDelay = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    // Start auto-scroll after a short delay so layout is ready
    Future.delayed(_startDelay, _startScrolling);
  }

  void _startScrolling() {
    if (!mounted) return;
    _scrollTimer = Timer.periodic(_tickInterval, (_) {
      if (_paused || !_controller.hasClients) return;

      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return; // content fits — no need to scroll

      final current = _controller.offset;

      if (_forward) {
        if (current >= max) {
          _forward = false;
        } else {
          _controller.jumpTo((current + _speed).clamp(0, max));
        }
      } else {
        if (current <= 0) {
          _forward = true;
        } else {
          _controller.jumpTo((current - _speed).clamp(0, max));
        }
      }
    });
  }

  void _onPointerDown(PointerDownEvent _) {
    _paused = true;
    _resumeTimer?.cancel();
  }

  void _onPointerUp(PointerEvent _) {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(_resumeDelay, () {
      if (mounted) _paused = false;
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(children: widget.children),
      ),
    );
  }
}
