import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/submit_expense_dialog.dart';
import '../../widgets/expense_details_dialog.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';
import '../../utils/pdf_helper.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String selectedCategory = 'ALL';
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> categories = [
    'ALL',
    'Food & Beverages',
    'Travelling Allowance',
    'Hotel/Stay',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Beverages':
        return Colors.orange;
      case 'Travelling Allowance':
        return Colors.blue;
      case 'Hotel/Stay':
        return Colors.purple;
      case 'Other':
        return Colors.grey.shade600;
      default:
        return Colors.blue;
    }
  }

  void _exportPDF() {
    if (_searchController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select Employee Name + Start & End Date to Export PDF',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate PDF
    final allExpenses = context.read<ExpenseProvider>().expenses;
    final filteredForPdf = allExpenses.where((e) {
      bool matchCategory =
          selectedCategory == 'ALL' || e.category == selectedCategory;
      bool matchSearch =
          _searchController.text.isEmpty ||
          e.userName.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      bool matchDate =
          !e.createdAt.isBefore(_startDate!) &&
          !e.createdAt.isAfter(_endDate!.add(const Duration(days: 1)));
      return matchCategory && matchSearch && matchDate;
    }).toList();

    if (filteredForPdf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No expenses found for the selected criteria.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    PdfHelper.generateAndPrintExpenseReport(
      expenses: filteredForPdf,
      employeeName: _searchController.text,
      startDate: _startDate!,
      endDate: _endDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();

    List<Expense> allExpenses = expenseProvider.expenses;

    List<Expense> filteredExpenses = allExpenses.where((e) {
      bool matchCategory =
          selectedCategory == 'ALL' || e.category == selectedCategory;
      bool matchSearch =
          _searchController.text.isEmpty ||
          e.userName.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      bool matchDate = true;
      if (_startDate != null && _endDate != null) {
        matchDate =
            !e.createdAt.isBefore(_startDate!) &&
            !e.createdAt.isAfter(_endDate!.add(const Duration(days: 1)));
      }
      return matchCategory && matchSearch && matchDate;
    }).toList();

    double totalAmount = filteredExpenses.fold(
      0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton.icon(
              onPressed: _exportPDF,
              icon: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 16,
              ),
              label: const Text(
                'Export PDF',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const SubmitExpenseDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Panel Design
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Search
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SEARCH',
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'By Employee Name',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Start Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'START DATE',
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 130,
                        height: 40,
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _startDate != null ? DateFormat('dd-MM-yyyy').format(_startDate!) : '',
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'dd-mm-yyyy',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                            suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // End Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'END DATE',
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 130,
                        height: 40,
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _endDate != null ? DateFormat('dd-MM-yyyy').format(_endDate!) : '',
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'dd-mm-yyyy',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                            suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Reset Button
                  SizedBox(
                    height: 40,
                    width: 115,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _startDate = null;
                          _endDate = null;
                          selectedCategory = 'ALL';
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade100),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total Amount Banner Design
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    '₹ ${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories View Design
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String cat = categories[index];
                bool isSelected = selectedCategory == cat;
                int count = cat == 'ALL'
                    ? allExpenses.length
                    : allExpenses.where((e) => e.category == cat).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      children: [
                        Text(cat),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white24
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Expenses List Design
          Expanded(
            child: expenseProvider.isLoading && allExpenses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) =>
                        _buildExpenseCard(filteredExpenses[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense item) {
    Color catColor = _getCategoryColor(item.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID + Employee Name + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        item.userName.isNotEmpty
                            ? item.userName.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.userName.isNotEmpty ? item.userName : 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (item.email.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              item.email,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'ID: #${item.id}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.circle,
                              size: 4,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd/MM/yyyy').format(item.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    '₹ ${item.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Middle Row: Category and Bill Status
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: catColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 16,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BILL',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (item.receiptUrl != null &&
                                  item.receiptUrl!.isNotEmpty) {
                                final uri = Uri.parse(item.receiptUrl!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              }
                            },
                            child: Text(
                              (item.receiptUrl != null &&
                                      item.receiptUrl!.isNotEmpty)
                                  ? 'View Bill'
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration:
                                    (item.receiptUrl != null &&
                                        item.receiptUrl!.isNotEmpty)
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                color:
                                    (item.receiptUrl != null &&
                                        item.receiptUrl!.isNotEmpty)
                                    ? Colors.blue.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom Row: Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ExpenseDetailsDialog(expense: item),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => SubmitExpenseDialog(expense: item),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

