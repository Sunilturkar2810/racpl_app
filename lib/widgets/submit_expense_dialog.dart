import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:racpl/theme/app_colors.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';

class SubmitExpenseDialog extends StatefulWidget {
  final Expense? expense;
  final bool asBottomSheet;
  
  const SubmitExpenseDialog({
    Key? key,
    this.expense,
    this.asBottomSheet = false,
  }) : super(key: key);

  @override
  State<SubmitExpenseDialog> createState() => _SubmitExpenseDialogState();
}

class _SubmitExpenseDialogState extends State<SubmitExpenseDialog> {
  final _formKey = GlobalKey<FormState>();

  String _category = '';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Travelling Allowance specific fields
  String _travelType = '';
  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _toLocationController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _tollAmountController = TextEditingController();

  // Hotel/Stay specific fields
  DateTime? _checkInDate;
  TimeOfDay? _checkInTime;
  DateTime? _checkOutDate;
  TimeOfDay? _checkOutTime;

  File? _billFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Food & Beverages',
    'Travelling Allowance',
    'Hotel/Stay',
    'Other',
  ];

  final List<String> _travelTypes = [
    'Self Car (9rs/KM)',
    'Self Bike (5rs/KM)',
    'Taxi/Cab',
    'Public Transport',
  ];

  @override
  void initState() {
    super.initState();
    _kmController.addListener(_calculateTravelAmount);
    _tollAmountController.addListener(_calculateTravelAmount);

    if (widget.expense != null) {
      final exp = widget.expense!;
      _category = _categories.contains(exp.category) ? exp.category : 'Other';
      _amountController.text = exp.amount.toString();
      _locationController.text = exp.location ?? '';
      _descriptionController.text = exp.description;
      
      _travelType = _travelTypes.contains(exp.travelType) ? exp.travelType! : '';
      _fromLocationController.text = exp.fromLocation ?? '';
      _toLocationController.text = exp.toLocation ?? '';
      _kmController.text = exp.km?.toString() ?? '';
      _tollAmountController.text = exp.tollAmount?.toString() ?? '';
      
      if (exp.checkIn != null && exp.checkIn!.isNotEmpty) {
        try {
          final dt = DateTime.parse(exp.checkIn!);
          _checkInDate = dt;
          _checkInTime = TimeOfDay.fromDateTime(dt);
        } catch (_) {}
      }
      if (exp.checkOut != null && exp.checkOut!.isNotEmpty) {
        try {
          final dt = DateTime.parse(exp.checkOut!);
          _checkOutDate = dt;
          _checkOutTime = TimeOfDay.fromDateTime(dt);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _kmController.dispose();
    _tollAmountController.dispose();
    super.dispose();
  }

  void _calculateTravelAmount() {
    if (_category != 'Travelling Allowance') return;

    double rate = 0;
    if (_travelType == 'Self Car (9rs/KM)') rate = 9;
    if (_travelType == 'Self Bike (5rs/KM)') rate = 5;

    if (rate > 0) {
      final double km = double.tryParse(_kmController.text) ?? 0;
      final double toll = double.tryParse(_tollAmountController.text) ?? 0;
      final total = (km * rate) + toll;

      if (total > 0) {
        _amountController.text = total.toStringAsFixed(2);
      } else {
        _amountController.text = '';
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _billFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDateTime(bool isCheckIn) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          if (isCheckIn) {
            _checkInDate = pickedDate;
            _checkInTime = pickedTime;
          } else {
            _checkOutDate = pickedDate;
            _checkOutTime = pickedTime;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return DateFormat("yyyy-MM-dd'T'HH:mm").format(dt);
  }

  String _getDisplayDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return 'Select Date & Time';
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expense category')),
      );
      return;
    }

    // Required field validations based on category mapping with web
    if (_category == 'Travelling Allowance') {
      if (_travelType.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select travel type')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final double km = double.tryParse(_kmController.text) ?? 0.0;
      final double toll = double.tryParse(_tollAmountController.text) ?? 0.0;

      final checkInStr = _formatDateTime(_checkInDate, _checkInTime);
      final checkOutStr = _formatDateTime(_checkOutDate, _checkOutTime);

      if (widget.expense != null) {
        await context.read<ExpenseProvider>().editExpense(
          id: widget.expense!.id,
          category: _category,
          amount: amount,
          location: _locationController.text,
          description: _descriptionController.text,
          travelType: _category == 'Travelling Allowance' ? _travelType : null,
          fromLocation: _category == 'Travelling Allowance'
              ? _fromLocationController.text
              : null,
          toLocation: _category == 'Travelling Allowance'
              ? _toLocationController.text
              : null,
          km: _category == 'Travelling Allowance' ? km : null,
          tollAmount: _category == 'Travelling Allowance' ? toll : null,
          checkIn: _category == 'Hotel/Stay' ? checkInStr : null,
          checkOut: _category == 'Hotel/Stay' ? checkOutStr : null,
          billFile: _billFile,
        );
      } else {
        await context.read<ExpenseProvider>().createExpense(
          category: _category,
          amount: amount,
          location: _locationController.text,
          description: _descriptionController.text,
          travelType: _category == 'Travelling Allowance' ? _travelType : null,
          fromLocation: _category == 'Travelling Allowance'
              ? _fromLocationController.text
              : null,
          toLocation: _category == 'Travelling Allowance'
              ? _toLocationController.text
              : null,
          km: _category == 'Travelling Allowance' ? km : null,
          tollAmount: _category == 'Travelling Allowance' ? toll : null,
          checkIn: _category == 'Hotel/Stay' ? checkInStr : null,
          checkOut: _category == 'Hotel/Stay' ? checkOutStr : null,
          billFile: _billFile,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true on success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.expense != null ? 'Expense updated successfully' : 'Expense submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit expense: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAutoCalcAmount =
        _category == 'Travelling Allowance' &&
        (_travelType == 'Self Car (9rs/KM)' ||
            _travelType == 'Self Bike (5rs/KM)');

    final content = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.expense != null
                                ? 'Edit Expense'
                                : 'Submit Expense',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'EXPENSE REQUEST FORM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Amount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('EXPENSE CATEGORY'),
                                  _buildDropdown(
                                    hint: 'Select Category',
                                    value: _category,
                                    items: _categories,
                                    onChanged: (value) {
                                      setState(() {
                                        _category = value!;
                                        // Reset fields based on web logic
                                        if (_category !=
                                            'Travelling Allowance') {
                                          _travelType = '';
                                          _fromLocationController.clear();
                                          _toLocationController.clear();
                                          _kmController.clear();
                                          _tollAmountController.clear();
                                        }
                                        if (_category != 'Hotel/Stay') {
                                          _checkInDate = null;
                                          _checkInTime = null;
                                          _checkOutDate = null;
                                          _checkOutTime = null;
                                        }
                                        _amountController.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (_category != 'Travelling Allowance') ...[
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('AMOUNT (₹)'),
                                    TextFormField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // General Location
                        _buildLabel('LOCATION'),
                        TextFormField(
                          controller: _locationController,
                          decoration: _inputDecoration(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        // Conditional: Travelling Allowance Fields
                        if (_category == 'Travelling Allowance') ...[
                          _buildLabel('NATURE OF TRAVEL'),
                          _buildDropdown(
                            hint: '-- Select --',
                            value: _travelType,
                            items: _travelTypes,
                            onChanged: (value) {
                              setState(() {
                                _travelType = value!;
                                _calculateTravelAmount();
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('FROM LOCATION'),
                                    TextFormField(
                                      controller: _fromLocationController,
                                      decoration: _inputDecoration(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('TO LOCATION'),
                                    TextFormField(
                                      controller: _toLocationController,
                                      decoration: _inputDecoration(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('KM TRAVELLED'),
                                    TextFormField(
                                      controller: _kmController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('TOLL AMOUNT (₹)'),
                                    TextFormField(
                                      controller: _tollAmountController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildLabel('TOTAL AMOUNT (₹)'),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            readOnly: isAutoCalcAmount,
                            decoration: _inputDecoration().copyWith(
                              fillColor: isAutoCalcAmount
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade50,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isAutoCalcAmount
                                  ? Colors.black54
                                  : Colors.black87,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Amount is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Conditional: Hotel/Stay Fields
                        if (_category == 'Hotel/Stay') ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('CHECK IN'),
                                    InkWell(
                                      onTap: () => _selectDateTime(true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          _getDisplayDateTime(
                                            _checkInDate,
                                            _checkInTime,
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _checkInDate != null
                                                ? Colors.black87
                                                : Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('CHECK OUT'),
                                    InkWell(
                                      onTap: () => _selectDateTime(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          _getDisplayDateTime(
                                            _checkOutDate,
                                            _checkOutTime,
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _checkOutDate != null
                                                ? Colors.black87
                                                : Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Description
                        _buildLabel('DESCRIPTION / NOTES'),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: _inputDecoration(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        // Upload Bill
                        _buildLabel('UPLOAD BILL'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Choose file'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                  ),
                                ),
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.08),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _billFile != null
                                    ? _billFile!.path
                                          .split(Platform.pathSeparator)
                                          .last
                                    : 'No file chosen',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1),
                ),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.expense != null ? 'Update Expense' : 'Submit Expense',
                                style: const TextStyle(
                                  fontSize: 15,
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
      ),
    );

    if (widget.asBottomSheet) {
      return SafeArea(
        top: false,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: content,
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: content,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String displayValue = (value == null || value.isEmpty) ? hint : value;

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
                'No items found',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
            ),
          ];
        }
        return items.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ), // Taller like a text field
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayValue,
                style: TextStyle(
                  color: (value == null || value.isEmpty)
                      ? Colors.grey[600]
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
