import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/submit_expense_dialog.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF Export feature coming soon')),
    );
  }

  void _showSubmitDialog({Expense? expense}) {
    showDialog(
      context: context,
      builder: (context) => SubmitExpenseDialog(expense: expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final allExpenses = expenseProvider.expenses;

    final filteredExpenses = allExpenses.where((expense) {
      final matchesCategory =
          selectedCategory == 'ALL' || expense.category == selectedCategory;
      final matchesSearch = expense.userName
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      
      bool matchesDate = true;
      if (_startDate != null && _endDate != null) {
        final expenseDate = DateTime(expense.createdAt.year, expense.createdAt.month, expense.createdAt.day);
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
        matchesDate = (expenseDate.isAtSameMomentAs(start) || expenseDate.isAfter(start)) &&
                     (expenseDate.isAtSameMomentAs(end) || expenseDate.isBefore(end));
      }

      return matchesCategory && matchesSearch && matchesDate;
    }).toList();

    double totalAmount = filteredExpenses.fold(0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Expense List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPDF,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters Segment
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SEARCH',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'By Employee Name',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField('START DATE', _startDate, (date) {
                          setState(() => _startDate = date);
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateField('END DATE', _endDate, (date) {
                          setState(() => _endDate = date);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
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
                      label: const Text('Reset Filters'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
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
          // Total Amount Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${filteredExpenses.length} records',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    '₹ ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          // Categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedCategory = category);
                    },
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          // List details
          Expanded(
            child: expenseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredExpenses.isEmpty
                    ? const Center(child: Text('No expenses found'))
                    : RefreshIndicator(
                        onRefresh: () => expenseProvider.fetchExpenses(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            return _buildExpenseCard(filteredExpenses[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubmitDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? value, Function(DateTime) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onSelected(picked);
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? DateFormat('dd-MM-yyyy').format(value) : 'dd-mm-yyyy',
                  style: TextStyle(
                    fontSize: 13,
                    color: value != null ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(Expense item) {
    final catColor = _getCategoryColor(item.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        item.userName.isNotEmpty ? item.userName.substring(0, 1).toUpperCase() : '?',
                        style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(item.createdAt),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '₹${item.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                _buildInfoChip(Icons.category_outlined, item.category, catColor),
                const SizedBox(width: 8),
                if (item.receiptUrl != null && item.receiptUrl!.isNotEmpty)
                  _buildInfoChip(Icons.receipt_long_outlined, 'Bill Available', Colors.green)
                else
                  _buildInfoChip(Icons.receipt_long_outlined, 'No Bill', Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            if (item.description.isNotEmpty)
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showSubmitDialog(expense: item),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
