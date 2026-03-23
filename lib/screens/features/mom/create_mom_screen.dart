import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/mom_model.dart';
import '../../../providers/mom_provider.dart';

class CreateMomScreen extends StatefulWidget {
  final Mom? momToEdit;

  const CreateMomScreen({super.key, this.momToEdit});

  @override
  State<CreateMomScreen> createState() => _CreateMomScreenState();
}

class _CreateMomScreenState extends State<CreateMomScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProject;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<String> _raTeam = [];
  final List<String> _clientTeam = [];
  final List<String> _vendorTeam = [];
  final List<String> _otherAttendees = [];

  final List<MomMinute> _minutes = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MomProvider>().fetchFormData());

    if (widget.momToEdit != null) {
      final mom = widget.momToEdit!;
      _selectedProject = mom.project;
      _dateController.text = mom.date;
      _timeController.text = mom.time;
      _locationController.text = mom.location;

      _raTeam.addAll(mom.raTeamAttendees);
      _clientTeam.addAll(mom.clientTeamAttendees);
      _vendorTeam.addAll(mom.vendorTeamAttendees);
      _otherAttendees.addAll(mom.otherAttendees);

      _minutes.addAll(mom.minutes);
    }
  }

  // Helper to get all currently added attendees to pass to "Action By" dropdown
  List<String> get _allAddedAttendees {
    final list = [
      ..._raTeam,
      ..._clientTeam,
      ..._vendorTeam,
      ..._otherAttendees,
    ];
    return list.toSet().toList(); // Remove duplicates
  }

  InputDecoration _beautifulDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.withAlpha(20),
      suffixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (!context.mounted) return;
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _addAttendee(String title, List<String> list) {
    String? selectedUser;
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final List<String> availableUsers = context.read<MomProvider>().users;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Add $title'),
              content: title == 'RA Team'
                  ? GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (BuildContext sheetContext) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Select User',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: availableUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = availableUsers[index];
                                        return ListTile(
                                          title: Text(user),
                                          onTap: () {
                                            setState(() => selectedUser = user);
                                            Navigator.pop(sheetContext);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: InputDecorator(
                        decoration: _beautifulDecoration(
                          'Select User',
                          icon: Icons.arrow_drop_down,
                        ),
                        child: Text(
                          selectedUser ?? 'Tap to select an attendee',
                          style: TextStyle(
                            color: selectedUser == null
                                ? Colors.grey
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : TextField(
                      controller: textController,
                      decoration: _beautifulDecoration('Enter $title Member'),
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (title == 'RA Team') {
                      if (selectedUser != null && selectedUser!.isNotEmpty) {
                        this.setState(() {
                          list.add(selectedUser!);
                        });
                      }
                    } else {
                      if (textController.text.trim().isNotEmpty) {
                        this.setState(() {
                          list.add(textController.text.trim());
                        });
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addMinute() {
    showDialog(
      context: context,
      builder: (context) {
        final minController = TextEditingController();
        String? actionBySelected;
        final plannedController = TextEditingController();
        final actualController = TextEditingController();
        final remarksController = TextEditingController();
        final delayedController = TextEditingController();

        Future<void> pickDate(TextEditingController controller) async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.text =
                "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
          }
        }

        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Add Discussion Point'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: minController,
                      decoration: _beautifulDecoration('Minutes'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        final availableOptions = [
                          ...context.read<MomProvider>().users,
                          ..._allAddedAttendees, // Also include any custom added ones
                        ].toSet().toList();

                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (BuildContext sheetContext) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Action By',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: availableOptions.length,
                                      itemBuilder: (context, index) {
                                        final user = availableOptions[index];
                                        return ListTile(
                                          title: Text(user),
                                          onTap: () {
                                            setStateBuilder(
                                              () => actionBySelected = user,
                                            );
                                            Navigator.pop(sheetContext);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: InputDecorator(
                        decoration: _beautifulDecoration(
                          'Action By',
                          icon: Icons.arrow_drop_down,
                        ),
                        child: Text(
                          actionBySelected ?? 'Select responsible person',
                          style: TextStyle(
                            color: actionBySelected == null
                                ? Colors.grey
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: plannedController,
                      decoration: _beautifulDecoration(
                        'Planned Date',
                        icon: Icons.calendar_today,
                      ),
                      readOnly: true,
                      onTap: () => pickDate(plannedController),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: actualController,
                      decoration: _beautifulDecoration(
                        'Actual Date',
                        icon: Icons.calendar_today,
                      ),
                      readOnly: true,
                      onTap: () => pickDate(actualController),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: delayedController,
                      decoration: _beautifulDecoration('Delayed Days'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksController,
                      decoration: _beautifulDecoration('Remarks'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (minController.text.trim().isNotEmpty) {
                      setState(() {
                        _minutes.add(
                          MomMinute(
                            minutes: minController.text.trim(),
                            actionBy: actionBySelected ?? '',
                            plannedCompletion: plannedController.text.trim(),
                            actualCompletion: actualController.text.trim(),
                            delayedDays:
                                int.tryParse(delayedController.text.trim()) ??
                                0,
                            remarks: remarksController.text.trim(),
                          ),
                        );
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveMom() async {
    if (_formKey.currentState!.validate() && _selectedProject != null) {
      final provider = context.read<MomProvider>();

      try {
        if (widget.momToEdit != null) {
          await provider.updateMeeting(
            widget.momToEdit!.id,
            project: _selectedProject!,
            date: _dateController.text,
            time: _timeController.text,
            location: _locationController.text,
            raTeamAttendees: _raTeam,
            clientTeamAttendees: _clientTeam,
            vendorTeamAttendees: _vendorTeam,
            otherAttendees: _otherAttendees,
            minutes: _minutes,
          );
        } else {
          await provider.createMeeting(
            project: _selectedProject!,
            date: _dateController.text,
            time: _timeController.text,
            location: _locationController.text,
            raTeamAttendees: _raTeam,
            clientTeamAttendees: _clientTeam,
            vendorTeamAttendees: _vendorTeam,
            otherAttendees: _otherAttendees,
            minutes: _minutes,
          );
        }

        if (!mounted) return;

        if (provider.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.error?.message ??
                    (widget.momToEdit != null
                        ? 'Error updating MOM'
                        : 'Error creating MOM'),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.momToEdit != null
                    ? 'MOM updated successfully'
                    : 'MOM created successfully',
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select project and fill all fields'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.momToEdit != null ? 'Edit MOM' : 'Create MOM'),
        centerTitle: true,
      ),
      body: Consumer<MomProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMeetingDetailsCard(),
                  const SizedBox(height: 16),
                  _buildAttendeesCard(),
                  const SizedBox(height: 16),
                  _buildMinutesCard(),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _saveMom,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.momToEdit != null
                                      ? 'Update MOM'
                                      : 'Save MOM',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeetingDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meeting Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FormField<String>(
              validator: (val) =>
                  _selectedProject == null ? 'Please select a project' : null,
              builder: (formFieldState) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (BuildContext sheetContext) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Select Project',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: context
                                      .read<MomProvider>()
                                      .projects
                                      .length,
                                  itemBuilder: (context, index) {
                                    final project = context
                                        .read<MomProvider>()
                                        .projects[index];
                                    return ListTile(
                                      title: Text(project),
                                      onTap: () {
                                        setState(() {
                                          _selectedProject = project;
                                        });
                                        formFieldState.didChange(project);
                                        Navigator.pop(sheetContext);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: InputDecorator(
                    decoration: _beautifulDecoration(
                      'Project *',
                      icon: Icons.arrow_drop_down,
                    ).copyWith(errorText: formFieldState.errorText),
                    child: Text(
                      _selectedProject ?? 'Tap to select project',
                      style: TextStyle(
                        color: _selectedProject == null
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: _beautifulDecoration(
                      'Date *',
                      icon: Icons.calendar_today,
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: _beautifulDecoration(
                      'Time *',
                      icon: Icons.access_time,
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: _beautifulDecoration('Location *'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendees',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAttendeeList('RA Team', _raTeam),
            const SizedBox(height: 12),
            _buildAttendeeList('Client Team', _clientTeam),
            const SizedBox(height: 12),
            _buildAttendeeList('Vendor Team', _vendorTeam),
            const SizedBox(height: 12),
            _buildAttendeeList('Other Attendees', _otherAttendees),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeList(String title, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            TextButton.icon(
              onPressed: () => _addAttendee(title, list),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        if (list.isNotEmpty)
          Wrap(
            spacing: 8,
            children: list
                .map(
                  (e) => Chip(
                    label: Text(e),
                    onDeleted: () => setState(() => list.remove(e)),
                  ),
                )
                .toList(),
          )
        else
          Text(
            'No attendees added',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        const Divider(),
      ],
    );
  }

  Widget _buildMinutesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Meeting Minutes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_minutes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'No discussion points added',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _minutes.length,
                itemBuilder: (context, index) {
                  final minute = _minutes[index];
                  return Card(
                    color: Colors.grey.withAlpha(13),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  minute.minutes,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _minutes.removeAt(index)),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (minute.actionBy.isNotEmpty)
                            Text(
                              'Action By: ${minute.actionBy}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (minute.plannedCompletion.isNotEmpty)
                            Text(
                              'Planned: ${minute.plannedCompletion}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (minute.actualCompletion.isNotEmpty)
                            Text(
                              'Actual: ${minute.actualCompletion}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (minute.delayedDays > 0)
                            Text(
                              'Delayed Days: ${minute.delayedDays}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.orange,
                              ),
                            ),
                          if (minute.remarks.isNotEmpty)
                            Text(
                              'Remarks: ${minute.remarks}',
                              style: const TextStyle(fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            OutlinedButton.icon(
              onPressed: _addMinute,
              icon: const Icon(Icons.add),
              label: const Text('Add Discussion Point'),
            ),
          ],
        ),
      ),
    );
  }
}
