import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/dio_service.dart';

class _DropdownItem {
  final String id;
  final String name;

  _DropdownItem({required this.id, required this.name});

  factory _DropdownItem.fromJson(Map<String, dynamic> json) {
    return _DropdownItem(
      id: json['id'].toString(),
      name: json['name'].toString(),
    );
  }
}

class CreateTicketDialog extends StatefulWidget {
  const CreateTicketDialog({super.key});

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoadingMasters = true;
  bool _isSubmitting = false;

  String? _selectedLocation;
  String? _selectedPCEA;
  String? _selectedPriority = 'Medium';
  String? _selectedSolver;
  DateTime? _desiredDate;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _raisedByController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<_DropdownItem> _locations = [];
  List<_DropdownItem> _pceas = [];
  List<_DropdownItem> _solvers = [];
  final List<_DropdownItem> _priorities = [
    _DropdownItem(id: 'Low', name: 'Low'),
    _DropdownItem(id: 'Medium', name: 'Medium'),
    _DropdownItem(id: 'High', name: 'High'),
  ];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _fetchMasters();
  }

  void _initializeUser() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _raisedByController.text = '${user.firstName} ${user.lastName}'.trim();
    }
  }

  Future<void> _fetchMasters() async {
    try {
      final dioService = context.read<DioService>();

      // Fetch concurrently
      final responses = await Future.wait([
        dioService.get<List>(
          '/master/locations',
          fromJson: (data) => data as List,
        ),
        dioService.get<List>(
          '/master/pc-accountables',
          fromJson: (data) => data as List,
        ),
        dioService.get<List>(
          '/master/problem-solvers',
          fromJson: (data) => data as List,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _locations = responses[0].map((e) {
          final item = _DropdownItem.fromJson(e as Map<String, dynamic>);
          // Backend uses name for location value
          return _DropdownItem(id: item.name, name: item.name);
        }).toList();

        _pceas = responses[1]
            .map((e) => _DropdownItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _solvers = responses[2]
            .map((e) => _DropdownItem.fromJson(e as Map<String, dynamic>))
            .toList();

        _isLoadingMasters = false;
      });
    } catch (e) {
      developer.log('Error fetching masters: $e');
      if (mounted) {
        setState(() {
          _isLoadingMasters = false;
        });
      }
    }
  }

  // This will be called to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _desiredDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _desiredDate) {
      setState(() {
        _desiredDate = picked;
      });
    }
  }

  Future<void> _submitTicket() async {
    if (_isSubmitting) return;

    final location = _selectedLocation;
    final pcea = _selectedPCEA;
    final priority = _selectedPriority;
    final description = _descriptionController.text.trim();

    if (location == null || location.isEmpty) {
      _showSnackBar('Please select location');
      return;
    }
    if (pcea == null || pcea.isEmpty) {
      _showSnackBar('Please select PC/EA accountable');
      return;
    }
    if (_desiredDate == null) {
      _showSnackBar('Please select desired date');
      return;
    }
    if (description.isEmpty) {
      _showSnackBar('Please enter issue description');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dioService = context.read<DioService>();
      final formData = FormData.fromMap({
        'location': location,
        'pc_accountable': pcea,
        'issue_description': description,
        'desired_date': _desiredDate!.toIso8601String(),
        'priority': (priority ?? 'Medium').toUpperCase(),
        if (_selectedSolver != null && _selectedSolver!.isNotEmpty)
          'problem_solver': _selectedSolver,
      });

      if (_selectedImage != null) {
        formData.files.add(
          MapEntry(
            'image_upload',
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: _selectedImage!.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      await dioService.post<Map<String, dynamic>>(
        '/help-tickets/raise',
        data: formData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!mounted) return;
      await context.read<TicketProvider>().fetchTickets();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket raised successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      developer.log('Error raising ticket: $e');
      if (!mounted) return;
      _showSnackBar('Failed to raise ticket');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _raisedByController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 8,
                top: 16,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_task,
                          color: Color(0xFF0066FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Raise Help Ticket',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[500]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable Form Area
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Dropdown
                      _buildLabel('Location'),
                      _buildDropdown(
                        hint: 'Select Location',
                        value: _selectedLocation,
                        items: _locations,
                        onChanged: (val) =>
                            setState(() => _selectedLocation = val),
                        isDark: isDark,
                      ),

                      // Raised By TextField
                      _buildLabel('Raised By'),
                      _buildTextField(
                        controller: _raisedByController,
                        hint: 'Enter your name',
                        isDark: isDark,
                      ),

                      // PC/EA Accountable
                      _buildLabel('PC/EA Accountable'),
                      _buildDropdown(
                        hint: 'Select PC/EA',
                        value: _selectedPCEA,
                        items: _pceas,
                        onChanged: (val) => setState(() => _selectedPCEA = val),
                        isDark: isDark,
                      ),

                      // Priority
                      _buildLabel('Priority'),
                      _buildDropdown(
                        hint: 'Select Priority',
                        value: _selectedPriority,
                        items: _priorities,
                        onChanged: (val) =>
                            setState(() => _selectedPriority = val),
                        isDark: isDark,
                      ),

                      // Problem Solver
                      _buildLabel('Problem Solver'),
                      _buildDropdown(
                        hint: 'Select Solver',
                        value: _selectedSolver,
                        items: _solvers,
                        onChanged: (val) =>
                            setState(() => _selectedSolver = val),
                        isDark: isDark,
                      ),

                      // Desired Date
                      _buildLabel('Desired Date'),
                      _buildDatePickerField(isDark),

                      // Issue Description
                      _buildLabel('Issue Description'),
                      _buildTextField(
                        controller: _descriptionController,
                        hint: 'Describe the problem in detail...',
                        isDark: isDark,
                        maxLines: 4,
                      ),

                      // Upload Proof/Image
                      _buildLabel('Upload Proof/Image (Optional)'),
                      _buildImageUploader(isDark),

                      const SizedBox(height: 32),

                      // Raise Ticket Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitTicket,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Raise Ticket',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<_DropdownItem> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    String displayValue = hint;
    if (value != null && items.isNotEmpty) {
      final selectedItem = items.where((item) => item.id == value).firstOrNull;
      if (selectedItem != null) displayValue = selectedItem.name;
    }

    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      onSelected: onChanged,
      constraints: const BoxConstraints(
        maxHeight: 300,
      ), // To prevent very long lists
      itemBuilder: (BuildContext context) {
        if (items.isEmpty) {
          return [
            PopupMenuItem<String>(
              value: null,
              enabled: false,
              child: Text(
                _isLoadingMasters ? 'Loading...' : 'No items found',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
            ),
          ];
        }
        return items.map((_DropdownItem item) {
          return PopupMenuItem<String>(
            value: item.id,
            child: Text(
              item.name,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ), // Taller like a text field
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayValue,
                style: TextStyle(
                  color: value == null
                      ? (isDark ? Colors.grey[400] : Colors.grey[500])
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  fontSize: value == null ? 14 : 15,
                  fontWeight: value == null
                      ? FontWeight.normal
                      : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _desiredDate != null
                  ? DateFormat('dd-MM-yyyy').format(_desiredDate!)
                  : 'dd-mm-yyyy',
              style: TextStyle(
                color: _desiredDate != null
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey[500],
                fontSize: 15,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      developer.log('Error picking image: $e');
    }
  }

  Widget _buildImageUploader(bool isDark) {
    return GestureDetector(
      onTap: _pickImage,
      child: CustomPaint(
        painter: _DottedBorderPainter(
          color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
        ),
        child: Container(
          width: double.infinity,
          padding: _selectedImage != null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withOpacity(0.5)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage != null
              ? Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: Colors.grey[500],
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click to select an image',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double dashWidth = 6.0;
    final double dashSpace = 4.0;
    final double radius = 8.0;

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    Path dashPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + dashWidth),
            Offset.zero,
          );
          distance += dashWidth;
        } else {
          distance += dashSpace;
        }
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
