import 'dart:async';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task_reference_model.dart';
import '../../providers/delegation_provider.dart';
import '../../theme/app_colors.dart';

Future<bool?> showCreateTaskSheet(
  BuildContext context, {
  required List<TaskAssignee> assignees,
  required List<TaskCategory> categories,
  required List<TaskDepartment> departments,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _CreateTaskSheet(
      assignees: assignees,
      categories: categories,
      departments: departments,
    ),
  );
}

class _CreateTaskSheet extends StatefulWidget {
  final List<TaskAssignee> assignees;
  final List<TaskCategory> categories;
  final List<TaskDepartment> departments;

  const _CreateTaskSheet({
    required this.assignees,
    required this.categories,
    required this.departments,
  });

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceUrlsController = TextEditingController();

  // Explicit focus nodes so we can permanently dismiss keyboard
  final _titleFocusNode = FocusNode();
  final _descFocusNode = FocusNode();

  // Core fields
  String _selectedPriority = 'Normal';
  String _selectedStatus = 'Pending';
  DateTime? _dueDate;
  String? _selectedCategory;

  // People & Department
  final Set<String> _selectedAssigneeIds = {};
  final Set<String> _selectedWatcherIds = {};
  final Set<String> _selectedDepartmentIds = {};

  // Checklist
  final List<_ChecklistItem> _checklist = [];
  final TextEditingController _checklistController = TextEditingController();

  // Repeat
  bool _isRepeat = false;
  String _repeatType = 'DAILY';
  DateTime? _repeatStartDate;
  DateTime? _repeatEndDate;

  // Evidence & Attachments
  bool _evidenceRequired = false;
  final List<XFile> _selectedFiles = [];

  // Reminders
  final List<_ReminderItem> _reminders = [];

  // Submitting
  bool _submitting = false;

  /// Moves focus to a temporary anonymous node so Flutter has
  /// nothing to restore when a modal sheet closes → keyboard stays hidden.
  void _dismissKeyboard() {
    final tempNode = FocusNode();
    FocusScope.of(context).requestFocus(tempNode);
    // Remove temp node after a tick so it doesn't linger
    Future.microtask(() => tempNode.dispose());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _checklistController.dispose();
    _referenceUrlsController.dispose();
    _titleFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime? initial, void Function(DateTime) onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null && mounted) setState(() => onPicked(picked));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedAssigneeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kam se kam ek assignee select karo')),
      );
      return;
    }

    setState(() => _submitting = true);

    final checklistPayload = _checklist
        .map((item) => {'text': item.text, 'completed': item.completed})
        .toList();

    final reminderPayload = _reminders
        .map((r) => {
              'type': r.type,
              'timeValue': r.timeValue,
              'timeUnit': r.timeUnit,
              'triggerType': r.triggerType,
            })
        .toList();

    await context.read<DelegationProvider>().createDelegation(
          doerIds: _selectedAssigneeIds.toList(),
          taskName: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate?.toIso8601String(),
          category: _selectedCategory,
          priority: _selectedPriority,
          status: _selectedStatus,
          inLoopIds: _selectedWatcherIds.toList(),
          department: _selectedDepartmentIds.toList(),
          checklistItems: checklistPayload,
          evidenceRequired: _evidenceRequired,
          referenceDocUrls: _referenceUrlsController.text.trim(),
          reminders: reminderPayload,
          isRepeat: _isRepeat,
          repeatType: _isRepeat ? _repeatType : null,
          repeatStartDate: _isRepeat ? _repeatStartDate?.toIso8601String() : null,
          repeatEndDate: _isRepeat ? _repeatEndDate?.toIso8601String() : null,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    final provider = context.read<DelegationProvider>();
    if (provider.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error?.message ?? 'Task create karne mein error aaya')),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  void _addChecklistItem() {
    final text = _checklistController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checklist.add(_ChecklistItem(text: text));
      _checklistController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Task Title *'),
                    TextFormField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      decoration: _inputDeco('Kya karna hai?', icon: Icons.title_rounded),
                      validator: (v) => v?.trim().isEmpty == true ? 'Title zaroor bharo' : null,
                    ),

                    _sectionLabel('Description'),
                    TextFormField(
                      controller: _descriptionController,
                      focusNode: _descFocusNode,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 14),
                      decoration: _inputDeco(
                        'Kya karna hai, dependencies...',
                        icon: Icons.notes_rounded,
                      ),
                    ),

                    _sectionLabel('Assignees & Watchers *'),
                    _buildMultiDropdownField(
                      icon: Icons.person_outline_rounded,
                      hint: 'Assignees',
                      selectedCount: _selectedAssigneeIds.length,
                      options: widget.assignees.map((e) => e.name).toList(),
                      selectedOptions: _selectedAssigneeIds.map((id) => widget.assignees.firstWhere((a) => a.id.toString() == id).name).toSet(),
                      onChanged: (selectedNames) {
                        setState(() {
                          _selectedAssigneeIds.clear();
                          for (var name in selectedNames) {
                            final match = widget.assignees.where((a) => a.name == name).firstOrNull;
                            if (match != null) _selectedAssigneeIds.add(match.id.toString());
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMultiDropdownField(
                      icon: Icons.remove_red_eye_outlined,
                      hint: 'Watchers / In Loop',
                      selectedCount: _selectedWatcherIds.length,
                      options: widget.assignees.map((e) => e.name).toList(),
                      selectedOptions: _selectedWatcherIds.map((id) => widget.assignees.firstWhere((a) => a.id.toString() == id).name).toSet(),
                      onChanged: (selectedNames) {
                        setState(() {
                          _selectedWatcherIds.clear();
                          for (var name in selectedNames) {
                            final match = widget.assignees.where((a) => a.name == name).firstOrNull;
                            if (match != null) _selectedWatcherIds.add(match.id.toString());
                          }
                        });
                      },
                    ),

                    _sectionLabel('Priority & Status'),
                    Row(
                      children: [
                        Expanded(child: _buildSegmentSelector(
                          label: 'Priority',
                          selected: _selectedPriority,
                          options: const ['Low', 'Normal', 'High', 'Urgent'],
                          colors: const [Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFF59E0B), Color(0xFFEF4444)],
                          onTap: (v) => setState(() => _selectedPriority = v),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSegmentSelector(
                          label: 'Status',
                          selected: _selectedStatus,
                          options: const ['Pending', 'In Progress', 'Completed'],
                          colors: const [Color(0xFF64748B), Color(0xFFF59E0B), Color(0xFF10B981)],
                          onTap: (v) => setState(() => _selectedStatus = v),
                        )),
                      ],
                    ),

                    _sectionLabel('Due Date & Category'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTapField(
                            icon: Icons.calendar_today_rounded,
                            label: _dueDate != null
                                ? DateFormat('dd MMM yyyy').format(_dueDate!)
                                : 'Due Date',
                            color: _dueDate != null ? AppColors.primary : const Color(0xFF94A3B8),
                            onTap: () => _pickDate(_dueDate, (d) => _dueDate = d),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSingleDropdownField(
                            icon: Icons.folder_outlined,
                            hint: 'Category',
                            value: _selectedCategory,
                            items: widget.categories.map((c) => c.name).toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v),
                          ),
                        ),
                      ],
                    ),

                    _sectionLabel('Departments'),
                    _buildMultiDropdownField(
                      icon: Icons.business_rounded,
                      hint: 'Departments (Optional)',
                      selectedCount: _selectedDepartmentIds.length,
                      options: widget.departments.map((e) => e.name).toList(),
                      selectedOptions: _selectedDepartmentIds,
                      onChanged: (selected) {
                        setState(() {
                          _selectedDepartmentIds.clear();
                          _selectedDepartmentIds.addAll(selected);
                        });
                      },
                    ),

                    _sectionLabel('Repeat Task'),
                    _buildRepeatSection(),

                    _sectionLabel('Checklist'),
                    _buildChecklistSection(),

                    _sectionLabel('Evidence and attachments'),
                    _buildEvidenceSection(),

                    _sectionLabel('Reminders'),
                    _buildRemindersSection(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(bottomInset),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Quick task creation',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentSelector({
    required String label,
    required String selected,
    required List<String> options,
    required List<Color> colors,
    required void Function(String) onTap,
  }) {
    final idx = options.indexOf(selected);
    final color = idx >= 0 ? colors[idx] : AppColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            _dismissKeyboard();
            final picked = await showModalBottomSheet<String>(
              context: context,
              builder: (ctx) => _SinglePickerSheet(title: label, options: options, colors: colors, selected: selected),
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            );
            if (picked != null) onTap(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selected,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTapField({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _dismissKeyboard();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleDropdownField({
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        _dismissKeyboard();
        final picked = await showModalBottomSheet<String>(
          context: context,
          builder: (ctx) => _SinglePickerSheet(
            title: hint,
            options: items,
            colors: List.filled(items.length, AppColors.primary),
            selected: value,
          ),
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: value != null ? AppColors.primary : const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 13,
                  color: value != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiDropdownField({
    required IconData icon,
    required String hint,
    required int selectedCount,
    required List<String> options,
    required Set<String> selectedOptions,
    required void Function(Set<String>) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        _dismissKeyboard();
        final picked = await showModalBottomSheet<Set<String>>(
          context: context,
          builder: (ctx) => _MultiPickerSheet(
            title: hint,
            options: options,
            initialSelected: selectedOptions,
          ),
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selectedCount > 0 ? AppColors.primary : const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedCount > 0 ? '$selectedCount items selected' : hint,
                style: TextStyle(
                  fontSize: 13,
                  color: selectedCount > 0 ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isRepeat ? AppColors.primary.withValues(alpha: 0.04) : const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isRepeat ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.repeat_rounded,
                size: 18,
                color: _isRepeat ? AppColors.primary : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Repeat Task',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _isRepeat ? AppColors.primary : const Color(0xFF334155),
                  ),
                ),
              ),
              Switch.adaptive(
                value: _isRepeat,
                onChanged: (v) => setState(() => _isRepeat = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (_isRepeat) ...[
            const Divider(height: 20, color: Color(0xFFE2E8F0)),
            Row(
              children: [
                Expanded(
                  child: _buildChipSelector(
                    options: const ['DAILY', 'WEEKLY', 'MONTHLY'],
                    selected: _repeatType,
                    onTap: (v) => setState(() => _repeatType = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTapField(
                    icon: Icons.play_circle_outline_rounded,
                    label: _repeatStartDate != null
                        ? DateFormat('dd MMM').format(_repeatStartDate!)
                        : 'Start Date',
                    color: _repeatStartDate != null ? AppColors.primary : const Color(0xFF94A3B8),
                    onTap: () => _pickDate(_repeatStartDate, (d) => _repeatStartDate = d),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTapField(
                    icon: Icons.stop_circle_outlined,
                    label: _repeatEndDate != null
                        ? DateFormat('dd MMM').format(_repeatEndDate!)
                        : 'End Date',
                    color: _repeatEndDate != null ? AppColors.primary : const Color(0xFF94A3B8),
                    onTap: () => _pickDate(_repeatEndDate, (d) => _repeatEndDate = d),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChipSelector({
    required List<String> options,
    required String selected,
    required void Function(String) onTap,
  }) {
    return Row(
      children: options.map((o) {
        final isSelected = o == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onTap(o),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                o,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _checklistController,
                style: const TextStyle(fontSize: 14),
                decoration: _inputDeco('Checklist item add karo', icon: Icons.check_box_outline_blank_rounded),
                onSubmitted: (_) => _addChecklistItem(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addChecklistItem,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        if (_checklist.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _checklist.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (_, i) {
                final item = _checklist[i];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: GestureDetector(
                    onTap: () => setState(() => item.completed = !item.completed),
                    child: Icon(
                      item.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: item.completed ? AppColors.primary : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: item.completed ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      decoration: item.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                    onPressed: () => setState(() => _checklist.removeAt(i)),
                  ),
                );
              },
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Abhi koi checklist item nahi hai',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ],
    );
  }

  // ─────────────────── BOTTOM BAR ───────────────────
  Widget _buildBottomBar(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Assign Task', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── HELPERS ───────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: const Color(0xFF94A3B8))
          : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }

  // ─────────────────── EVIDENCE SECTION ───────────────────
  Widget _buildEvidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with "Evidence required" checkbox
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evidence and attachments',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Voice note and reference docs can be uploaded with the task.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _evidenceRequired,
                    onChanged: (v) => setState(() => _evidenceRequired = v ?? false),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text(
                    'Evidence required',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),

          // Voice Note Recorder
          const Text(
            'VOICE NOTE RECORDER',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const _VoiceRecorderSheet(),
                    );
                  },
                  icon: const Icon(Icons.mic_rounded, size: 18),
                  label: const Text('Record voice', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Record directly from the microphone. The recording uploads when the task is saved.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reference Document Files
          const Text(
            'REFERENCE DOCUMENT FILES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              const typeGroup = XTypeGroup(label: 'Documents');
              final files = await openFiles(acceptedTypeGroups: [typeGroup]);
              if (files.isNotEmpty) {
                setState(() => _selectedFiles.addAll(files));
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFiles.isEmpty
                          ? 'Choose files  No file chosen'
                          : '${_selectedFiles.length} file(s) selected',
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedFiles.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedFiles.asMap().entries.map((e) {
                return Chip(
                  label: Text(e.value.name, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _selectedFiles.removeAt(e.key)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  deleteIconColor: const Color(0xFF64748B),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),

          // Reference Document URLs
          const Text(
            'REFERENCE DOCUMENT URLS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _referenceUrlsController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: _inputDeco('One URL per line'),
          ),
        ],
      ),
    );
  }

  // ─────────────────── REMINDERS SECTION ───────────────────
  Widget _buildRemindersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminders',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_reminders.length} reminder(s) configured',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => _RemindersSheet(
                  reminders: List.from(_reminders),
                  onSave: (updated) => setState(() {
                    _reminders..clear()..addAll(updated);
                  }),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: Size.zero,
            ),
            child: const Text('Manage reminders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── SINGLE PICKER SHEET ───────────────────
class _SinglePickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<Color> colors;
  final String? selected;

  const _SinglePickerSheet({
    required this.title,
    required this.options,
    required this.colors,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (ctx, i) {
              final isSelected = options[i] == selected;
              final color = i < colors.length ? colors[i] : AppColors.primary;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () => Navigator.pop(context, options[i]),
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                title: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? color : const Color(0xFF334155),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: color, size: 20)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────── MULTI PICKER SHEET ───────────────────
class _MultiPickerSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final Set<String> initialSelected;

  const _MultiPickerSheet({
    required this.title,
    required this.options,
    required this.initialSelected,
  });

  @override
  State<_MultiPickerSheet> createState() => _MultiPickerSheetState();
}

class _MultiPickerSheetState extends State<_MultiPickerSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: widget.options.length,
            itemBuilder: (ctx, i) {
              final option = widget.options[i];
              final isSelected = _selected.contains(option);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selected.remove(option);
                    } else {
                      _selected.add(option);
                    }
                  });
                },
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : const Color(0xFF334155),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_box_rounded, color: AppColors.primary)
                    : const Icon(Icons.check_box_outline_blank_rounded, color: Color(0xFFCBD5E1)),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────── CHECKLIST ITEM MODEL ───────────────────
class _ChecklistItem {
  String text;
  bool completed;
  _ChecklistItem({required this.text, this.completed = false});
}

// ─────────────────── REMINDER ITEM MODEL ───────────────────
class _ReminderItem {
  String type;
  int timeValue;
  String timeUnit;
  String triggerType;

  _ReminderItem({
    required this.type,
    required this.timeValue,
    required this.timeUnit,
    required this.triggerType,
  });
}

// ─────────────────── REMINDERS SHEET ───────────────────
class _RemindersSheet extends StatefulWidget {
  final List<_ReminderItem> reminders;
  final void Function(List<_ReminderItem>) onSave;

  const _RemindersSheet({required this.reminders, required this.onSave});

  @override
  State<_RemindersSheet> createState() => _RemindersSheetState();
}

class _RemindersSheetState extends State<_RemindersSheet> {
  late List<_ReminderItem> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = List.from(widget.reminders);
  }

  void _addReminder() {
    setState(() {
      _reminders.add(_ReminderItem(
        type: 'before_due',
        timeValue: 30,
        timeUnit: 'minutes',
        triggerType: 'before_due',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scroll) => Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manage Reminders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    widget.onSave(_reminders);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(16),
              children: [
                ..._reminders.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.alarm, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text('Reminder', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                              onPressed: () => setState(() => _reminders.removeAt(i)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: r.timeValue.toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Value',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                                onChanged: (v) => r.timeValue = int.tryParse(v) ?? r.timeValue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: r.timeUnit,
                                decoration: InputDecoration(
                                  labelText: 'Unit',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                                items: ['minutes', 'hours', 'days']
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) => setState(() => r.timeUnit = v ?? r.timeUnit),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: r.triggerType,
                          decoration: InputDecoration(
                            labelText: 'Trigger',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          items: ['before_due', 'after_created']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(() => r.triggerType = v ?? r.triggerType),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addReminder,
                  icon: const Icon(Icons.add_alarm_rounded, size: 18),
                  label: const Text('Add Reminder'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── VOICE RECORDER SHEET ───────────────────
class _VoiceRecorderSheet extends StatefulWidget {
  const _VoiceRecorderSheet();

  @override
  State<_VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<_VoiceRecorderSheet> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  late final AnimationController _animController;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _toggleRecord() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordDuration = 0;
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() => _recordDuration++);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatDuration(int seconds) {
    final mins = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              const Text('Record Voice Note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 24),
              
              Text(
                _formatDuration(_recordDuration),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: _isRecording ? AppColors.primary : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRecording ? 'Listening...' : 'Tap mic to start',
                style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRecording)
                    IconButton(
                      onPressed: _toggleRecord,
                      icon: const Icon(Icons.stop_circle_rounded, color: Color(0xFFEF4444), size: 64),
                      padding: EdgeInsets.zero,
                    )
                  else
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (ctx, child) {
                        return Transform.scale(
                          scale: 1.0 + (_animController.value * 0.1),
                          child: GestureDetector(
                            onTap: _toggleRecord,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 48),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audio permissions ki zarurat hogi. Basics lag chuka hai.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Save Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
