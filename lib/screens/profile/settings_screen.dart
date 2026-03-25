import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/help_ticket_config_model.dart';
import '../../providers/help_ticket_config_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  final TextEditingController _workspaceController =
      TextEditingController(text: 'RACPL Workspace');
  final TextEditingController _holidayDescriptionController =
      TextEditingController();
  String _selectedLanguage = 'English (US)';
  DateTime? _selectedHolidayDate;

  late final List<_SettingsItem> _items = [
    const _SettingsItem(
      title: 'General',
      subtitle: 'Manage your workspace preferences.',
      icon: Icons.tune_rounded,
    ),
    const _SettingsItem(
      title: 'Security',
      subtitle: 'Control login, password and account safety.',
      icon: Icons.lock_outline_rounded,
    ),
    const _SettingsItem(
      title: 'Notifications',
      subtitle: 'Choose which updates you want to receive.',
      icon: Icons.notifications_none_rounded,
    ),
    const _SettingsItem(
      title: 'Team',
      subtitle: 'Review team roles and collaboration access.',
      icon: Icons.groups_2_outlined,
    ),
    const _SettingsItem(
      title: 'Billing',
      subtitle: 'Track plans, invoices and payment methods.',
      icon: Icons.account_balance_wallet_outlined,
    ),
    const _SettingsItem(
      title: 'Integrations',
      subtitle: 'Connect external tools and data sources.',
      icon: Icons.hub_outlined,
    ),
    const _SettingsItem(
      title: 'Add Holiday',
      subtitle: 'Maintain company holiday calendar settings.',
      icon: Icons.event_available_outlined,
    ),
    const _SettingsItem(
      title: 'Add User',
      subtitle: 'Invite and configure new workspace users.',
      icon: Icons.person_add_alt_1_outlined,
    ),
    const _SettingsItem(
      title: 'Help Ticket Setting',
      subtitle: 'Configure support ticket priorities and routing.',
      icon: Icons.support_agent_outlined,
    ),
  ];

  @override
  void dispose() {
    _workspaceController.dispose();
    _holidayDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HelpTicketConfigProvider>().fetchConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  children: [
                    SizedBox(
                      width: 260,
                      child: _buildSideNav(theme),
                    ),
                    Container(width: 1, color: const Color(0xFFE6ECF5)),
                    Expanded(
                      child: _buildContentPanel(theme),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildMobileSelector(theme),
                    Container(height: 1, color: const Color(0xFFE6ECF5)),
                    Expanded(
                      child: _buildContentPanel(theme),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSideNav(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workspace Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF122033),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your workspace aligned with how your team works.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7A90),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = _items[index];
                final isSelected = index == _selectedIndex;

                return InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F1FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isSelected
                              ? theme.primaryColor
                              : const Color(0xFF69809F),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.primaryColor
                                  : const Color(0xFF5B6F8B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<int>(
        value: _selectedIndex,
        decoration: InputDecoration(
          labelText: 'Settings Section',
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: List.generate(
          _items.length,
          (index) => DropdownMenuItem<int>(
            value: index,
            child: Text(_items[index].title),
          ),
        ),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedIndex = value);
          }
        },
      ),
    );
  }

  Widget _buildContentPanel(ThemeData theme) {
    final item = _items[_selectedIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: theme.primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF182433),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF70829C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFE6ECF5)),
          const SizedBox(height: 24),
          _buildSectionBody(item.title, theme),
        ],
      ),
    );
  }

  Widget _buildSectionBody(String title, ThemeData theme) {
    switch (title) {
      case 'General':
        return _buildGeneralSection(theme);
      case 'Security':
        return _buildInfoCards([
          _InfoCardData(
            title: 'Two-Factor Authentication',
            description: 'Add an extra layer of account protection.',
            actionLabel: 'Enable',
          ),
          _InfoCardData(
            title: 'Password Policy',
            description: 'Enforce stronger passwords for all users.',
            actionLabel: 'Update',
          ),
        ]);
      case 'Notifications':
        return _buildInfoCards([
          _InfoCardData(
            title: 'Project Alerts',
            description: 'Receive updates for project status changes.',
            actionLabel: 'Manage',
          ),
          _InfoCardData(
            title: 'Email Digest',
            description: 'Send daily summaries to team members.',
            actionLabel: 'Configure',
          ),
        ]);
      case 'Team':
        return _buildInfoCards([
          _InfoCardData(
            title: 'Role Permissions',
            description: 'Review admin, manager and employee access.',
            actionLabel: 'View',
          ),
          _InfoCardData(
            title: 'Approval Chain',
            description: 'Define reporting and approval hierarchy.',
            actionLabel: 'Edit',
          ),
        ]);
      case 'Billing':
        return _buildInfoCards([
          _InfoCardData(
            title: 'Current Plan',
            description: 'Business workspace with active billing cycle.',
            actionLabel: 'Details',
          ),
          _InfoCardData(
            title: 'Invoices',
            description: 'Download previous payment receipts and bills.',
            actionLabel: 'Open',
          ),
        ]);
      case 'Integrations':
        return _buildInfoCards([
          _InfoCardData(
            title: 'Third-Party Tools',
            description: 'Connect chat, storage and analytics platforms.',
            actionLabel: 'Connect',
          ),
          _InfoCardData(
            title: 'API Access',
            description: 'Generate secure tokens for external systems.',
            actionLabel: 'Generate',
          ),
        ]);
      case 'Add Holiday':
        return _buildHolidaySection(theme);
      case 'Add User':
        return _buildInfoCards([
          _InfoCardData(
            title: 'Invite New Member',
            description: 'Send workspace invite links to employees.',
            actionLabel: 'Invite',
          ),
          _InfoCardData(
            title: 'Default Access',
            description: 'Apply standard permissions for new users.',
            actionLabel: 'Set',
          ),
        ]);
      case 'Help Ticket Setting':
        return _buildInfoCards([
          _InfoCardData(
            title: 'Priority Rules',
            description: 'Map incoming ticket categories to priority levels.',
            actionLabel: 'Manage',
          ),
          _InfoCardData(
            title: 'Assignment Logic',
            description: 'Route tickets to the right support owner.',
            actionLabel: 'Update',
          ),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGeneralSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Workspace Name'),
        const SizedBox(height: 10),
        TextField(
          controller: _workspaceController,
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 22),
        _buildLabel('Language'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: _inputDecoration(),
          items: const [
            DropdownMenuItem(
              value: 'English (US)',
              child: Text('English (US)'),
            ),
            DropdownMenuItem(
              value: 'English (UK)',
              child: Text('English (UK)'),
            ),
            DropdownMenuItem(
              value: 'Hindi',
              child: Text('Hindi'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLanguage = value);
            }
          },
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _StatChip(label: 'Workspace Active'),
            _StatChip(label: '12 Team Members'),
            _StatChip(label: 'Last synced today'),
          ],
        ),
      ],
    );
  }

  Widget _buildHolidaySection(ThemeData theme) {
    return Consumer<HelpTicketConfigProvider>(
      builder: (context, provider, _) {
        final holidays = provider.holidays;
        final isBusy = provider.isLoading && !provider.hasLoaded;

        if (isBusy) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holiday Management',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF182433),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add and manage holidays used for SLA and TAT calculations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF70829C),
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: const Color(0xFFE6ECF5)),
            const SizedBox(height: 28),
            _buildLabel('Holiday Date'),
            const SizedBox(height: 10),
            InkWell(
              onTap: provider.isSaving ? null : _pickHolidayDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: _inputDecoration(
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                ),
                child: Text(
                  _selectedHolidayDate == null
                      ? 'dd-mm-yyyy'
                      : DateFormat('dd-MM-yyyy').format(_selectedHolidayDate!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedHolidayDate == null
                        ? const Color(0xFF8B98AB)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This date will be excluded from SLA calculations.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF70829C),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Holiday Description'),
            const SizedBox(height: 10),
            TextField(
              controller: _holidayDescriptionController,
              enabled: !provider.isSaving,
              decoration: _inputDecoration(
                hintText: 'e.g. Republic Day',
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 150,
                height: 48,
                child: ElevatedButton(
                  onPressed: provider.isSaving ? null : _handleAddHoliday,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add Holiday',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFD5D5)),
                ),
                child: Text(
                  provider.error!.message,
                  style: const TextStyle(
                    color: Color(0xFFB42318),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            if (holidays.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5ECF5)),
                ),
                child: const Text(
                  'No holidays added yet.',
                  style: TextStyle(
                    color: Color(0xFF70829C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ...holidays.map((holiday) => _buildHolidayCard(holiday, provider)),
          ],
        );
      },
    );
  }

  Widget _buildInfoCards(List<_InfoCardData> cards) {
    return Column(
      children: cards
          .map(
            (card) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5ECF5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D2A3B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          card.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF70829C),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(card.actionLabel),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHolidayCard(
    HelpTicketHoliday holiday,
    HelpTicketConfigProvider provider,
  ) {
    final formattedDate = _formatHolidayDate(holiday.holidayDate);
    final isDeleting = provider.deletingHolidayId == holiday.id;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5ECF5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.description.isEmpty ? 'Holiday' : holiday.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D2A3B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF70829C),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isDeleting ? null : () => _handleDeleteHoliday(holiday),
            child: isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Future<void> _pickHolidayDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedHolidayDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate != null) {
      setState(() => _selectedHolidayDate = pickedDate);
    }
  }

  Future<void> _handleAddHoliday() async {
    final provider = context.read<HelpTicketConfigProvider>();
    final description = _holidayDescriptionController.text.trim();

    provider.clearError();

    if (_selectedHolidayDate == null) {
      _showMessage('Please select holiday date.');
      return;
    }

    if (description.isEmpty) {
      _showMessage('Please enter holiday description.');
      return;
    }

    final success = await provider.addHoliday(
      holidayDate: DateFormat('yyyy-MM-dd').format(_selectedHolidayDate!),
      description: description,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedHolidayDate = null;
        _holidayDescriptionController.clear();
      });
      _showMessage('Holiday added successfully.');
    }
  }

  Future<void> _handleDeleteHoliday(HelpTicketHoliday holiday) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Holiday'),
        content: Text(
          'Delete ${holiday.description.isEmpty ? 'this holiday' : holiday.description}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final success = await context.read<HelpTicketConfigProvider>().removeHoliday(
      holiday.id,
    );

    if (!mounted) return;

    if (success) {
      _showMessage('Holiday removed.');
    }
  }

  String _formatHolidayDate(String value) {
    try {
      final date = DateTime.parse(value);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return value;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDCE5F2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDCE5F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF137FEC), width: 1.2),
      ),
    );
  }
}

class _SettingsItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _InfoCardData {
  final String title;
  final String description;
  final String actionLabel;

  _InfoCardData({
    required this.title,
    required this.description,
    required this.actionLabel,
  });
}

class _StatChip extends StatelessWidget {
  final String label;

  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF24558D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
