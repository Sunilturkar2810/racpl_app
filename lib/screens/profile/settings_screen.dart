import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/help_ticket_config_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/help_ticket_config_provider.dart';

const _items = [
  _Item('General', 'Theme and account preferences', Icons.tune_rounded),
  _Item('Security', 'Security APIs are not available yet', Icons.lock_outline_rounded),
  _Item('Notifications', 'Notification APIs are not available yet', Icons.notifications_none_rounded),
  _Item('Team', 'Team settings APIs are not available yet', Icons.groups_2_outlined),
  _Item('Billing', 'Billing APIs are not available yet', Icons.account_balance_wallet_outlined),
  _Item('Integrations', 'Integration APIs are not available yet', Icons.hub_outlined),
  _Item('Add Holiday', 'Manage help ticket holidays', Icons.event_available_outlined),
  _Item('Add User', 'Create employee accounts', Icons.person_add_alt_1_outlined),
  _Item('Help Ticket Setting', 'Edit SLA configuration', Icons.support_agent_outlined),
];

const _dayLabels = <int, String>{
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE8F1FF),
                child: Icon(item.icon, color: Theme.of(context).primaryColor),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(item.subtitle),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsSectionScreen(item: item)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SettingsSectionScreen extends StatefulWidget {
  final _Item item;

  const SettingsSectionScreen({super.key, required this.item});

  @override
  State<SettingsSectionScreen> createState() => _SettingsSectionScreenState();
}

class _SettingsSectionScreenState extends State<SettingsSectionScreen> {
  final _holidayDate = TextEditingController();
  final _holidayDescription = TextEditingController();
  final _stage2 = TextEditingController();
  final _stage4 = TextEditingController();
  final _stage5 = TextEditingController();
  final _officeStart = TextEditingController();
  final _officeEnd = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _designation = TextEditingController();
  final _department = TextEditingController();
  final _joiningDate = TextEditingController();
  final _userFormKey = GlobalKey<FormState>();

  DateTime? _selectedHolidayDate;
  String _theme = 'light';
  String _role = 'Employee';
  Set<int> _workingDays = {1, 2, 3, 4, 5, 6};
  String _configStamp = '';
  bool _themeSaving = false;

  @override
  void initState() {
    super.initState();
    _theme = context.read<AuthProvider>().currentUser?.theme == 'dark' ? 'dark' : 'light';
    if (widget.item.title == 'Add Holiday' || widget.item.title == 'Help Ticket Setting') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HelpTicketConfigProvider>().fetchConfig(forceRefresh: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _holidayDate.dispose();
    _holidayDescription.dispose();
    _stage2.dispose();
    _stage4.dispose();
    _stage5.dispose();
    _officeStart.dispose();
    _officeEnd.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _designation.dispose();
    _department.dispose();
    _joiningDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(title: Text(widget.item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (widget.item.title) {
      case 'General':
        return _buildGeneral(context);
      case 'Add Holiday':
        return _buildHoliday(context);
      case 'Add User':
        return _buildAddUser(context);
      case 'Help Ticket Setting':
        return _buildHelpTicketSettings(context);
      default:
        return Text('`f_b/Backend` me ${widget.item.title} ke liye dedicated API route nahi mili.');
    }
  }

  Widget _buildGeneral(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('General', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('This section uses `/api/auth/theme`. Current user session remains intact.'),
        const SizedBox(height: 20),
        _chipWrap([auth.userName, auth.userRole, auth.userEmail]),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _theme,
          decoration: _decoration('App Theme'),
          items: const [
            DropdownMenuItem(value: 'light', child: Text('Light')),
            DropdownMenuItem(value: 'dark', child: Text('Dark')),
          ],
          onChanged: (v) => setState(() => _theme = v ?? 'light'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _themeSaving ? null : () async {
            final authProvider = context.read<AuthProvider>();
            authProvider.clearError();
            setState(() => _themeSaving = true);
            await authProvider.updateTheme(_theme);
            if (!mounted) return;
            setState(() => _themeSaving = false);
            _show(authProvider.error?.message ?? 'Theme updated successfully.');
          },
          child: _themeSaving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Theme'),
        ),
      ],
    );
  }

  Widget _buildHelpTicketSettings(BuildContext context) {
    return Consumer<HelpTicketConfigProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasLoaded) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
        }
        _syncConfig(provider.settings);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help Ticket Setting', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Mapped from `/api/help-ticket-config` in the backend.'),
            const SizedBox(height: 20),
            _field('Stage 2 TAT Hours', _stage2, number: true),
            const SizedBox(height: 12),
            _field('Stage 4 TAT Hours', _stage4, number: true),
            const SizedBox(height: 12),
            _field('Stage 5 TAT Hours', _stage5, number: true),
            const SizedBox(height: 12),
            _field('Office Start Time', _officeStart, readOnly: true, onTap: () => _pickTime(_officeStart)),
            const SizedBox(height: 12),
            _field('Office End Time', _officeEnd, readOnly: true, onTap: () => _pickTime(_officeEnd)),
            const SizedBox(height: 16),
            Text('Working Days', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dayLabels.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.value),
                  selected: _workingDays.contains(entry.key),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _workingDays.add(entry.key) : _workingDays.remove(entry.key);
                    });
                  },
                );
              }).toList(),
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 16),
              Text(provider.error!.message, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: provider.isSaving ? null : () async {
                final ok = await provider.updateSettings(
                  stage2TatHours: int.tryParse(_stage2.text) ?? 0,
                  stage4TatHours: int.tryParse(_stage4.text) ?? 0,
                  stage5TatHours: int.tryParse(_stage5.text) ?? 0,
                  officeStartTime: _apiTime(_officeStart.text),
                  officeEndTime: _apiTime(_officeEnd.text),
                  workingDays: _workingDays.toList()..sort(),
                );
                if (!mounted) return;
                _show(ok ? 'Help ticket settings updated.' : provider.error?.message ?? 'Failed to update settings.');
              },
              child: provider.isSaving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Settings'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHoliday(BuildContext context) {
    return Consumer<HelpTicketConfigProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasLoaded) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Holiday', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('This section uses `/api/help-ticket-config/holidays`.'),
            const SizedBox(height: 16),
            _field(
              'Holiday Date',
              _holidayDate,
              readOnly: true,
              onTap: _pickHolidayDate,
            ),
            const SizedBox(height: 12),
            _field('Description', _holidayDescription),
            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Text(provider.error!.message, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: provider.isSaving ? null : () async {
                if (_selectedHolidayDate == null || _holidayDescription.text.trim().isEmpty) {
                  _show('Please select date and description.');
                  return;
                }
                final ok = await provider.addHoliday(
                  holidayDate: DateFormat('yyyy-MM-dd').format(_selectedHolidayDate!),
                  description: _holidayDescription.text.trim(),
                );
                if (!mounted) return;
                if (ok) {
                  setState(() {
                    _selectedHolidayDate = null;
                    _holidayDate.clear();
                    _holidayDescription.clear();
                  });
                }
                _show(ok ? 'Holiday added.' : provider.error?.message ?? 'Failed to add holiday.');
              },
              child: provider.isSaving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add Holiday'),
            ),
            const SizedBox(height: 20),
            ...provider.holidays.map(
              (h) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(h.description.isEmpty ? 'Holiday' : h.description),
                  subtitle: Text(_prettyDate(h.holidayDate)),
                  trailing: provider.deletingHolidayId == h.id
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : TextButton(
                          onPressed: () async {
                            final ok = await provider.removeHoliday(h.id);
                            if (!mounted) return;
                            _show(ok ? 'Holiday removed.' : provider.error?.message ?? 'Failed to remove holiday.');
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddUser(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _userFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add User', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('This form posts to `/api/auth/register` from the backend.'),
              const SizedBox(height: 16),
              _field('First Name', _firstName, requiredValue: true),
              const SizedBox(height: 12),
              _field('Last Name', _lastName, requiredValue: true),
              const SizedBox(height: 12),
              _field('Work Email', _email, requiredValue: true, email: true),
              const SizedBox(height: 12),
              _field('Password', _password, requiredValue: true, obscure: true),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: _decoration('Role'),
                items: const ['Employee', 'Admin', 'SuperAdmin', 'PC']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? 'Employee'),
              ),
              const SizedBox(height: 12),
              _field('Designation', _designation),
              const SizedBox(height: 12),
              _field('Department', _department),
              const SizedBox(height: 12),
              _field('Joining Date', _joiningDate, readOnly: true, onTap: _pickJoiningDate),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!.message, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: auth.isLoading ? null : () async {
                  if (!_userFormKey.currentState!.validate()) return;
                  if (_joiningDate.text.trim().isEmpty) {
                    _show('Please select joining date.');
                    return;
                  }
                  auth.clearError();
                  auth.clearSuccessMessage();
                  final ok = await auth.signup(
                    firstName: _firstName.text.trim(),
                    lastName: _lastName.text.trim(),
                    email: _email.text.trim(),
                    password: _password.text,
                    role: _role,
                    designation: _designation.text.trim(),
                    department: _department.text.trim(),
                    joiningDate: _joiningDate.text.trim(),
                  );
                  if (!mounted) return;
                  if (ok) {
                    _firstName.clear();
                    _lastName.clear();
                    _email.clear();
                    _password.clear();
                    _designation.clear();
                    _department.clear();
                    _joiningDate.clear();
                    setState(() => _role = 'Employee');
                  }
                  _show(ok ? auth.lastSuccessMessage ?? 'User added.' : auth.error?.message ?? 'Failed to add user.');
                },
                child: auth.isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add User'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool requiredValue = false,
    bool readOnly = false,
    bool obscure = false,
    bool number = false,
    bool email = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscure,
      keyboardType: number ? TextInputType.number : (email ? TextInputType.emailAddress : TextInputType.text),
      onTap: onTap,
      validator: (value) {
        if (requiredValue && (value == null || value.trim().isEmpty)) return '$label is required';
        return null;
      },
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _chipWrap(List<String> values) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.where((e) => e.isNotEmpty).map((e) => Chip(label: Text(e))).toList(),
    );
  }

  Future<void> _pickHolidayDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedHolidayDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedHolidayDate = picked);
      _holidayDate.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _joiningDate.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(controller.text) ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  void _syncConfig(HelpTicketSettings settings) {
    final stamp = '${settings.stage2TatHours}|${settings.stage4TatHours}|${settings.stage5TatHours}|${settings.officeStartTime}|${settings.officeEndTime}|${settings.workingDays.join(',')}';
    if (stamp == _configStamp) return;
    _configStamp = stamp;
    _stage2.text = settings.stage2TatHours.toString();
    _stage4.text = settings.stage4TatHours.toString();
    _stage5.text = settings.stage5TatHours.toString();
    _officeStart.text = _displayTime(settings.officeStartTime);
    _officeEnd.text = _displayTime(settings.officeEndTime);
    _workingDays = settings.workingDays.toSet();
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _displayTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String _apiTime(String value) {
    final parts = value.split(':');
    if (parts.length == 2) return '${parts[0]}:${parts[1]}:00';
    return value;
  }

  String _prettyDate(String value) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Item {
  final String title;
  final String subtitle;
  final IconData icon;

  const _Item(this.title, this.subtitle, this.icon);
}
