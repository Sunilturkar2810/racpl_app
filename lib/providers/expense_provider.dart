import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../models/error_model.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  late ExpenseService _expenseService;

  List<Expense> _expenses = [];
  Expense? _selectedExpense;
  bool _isLoading = false;
  AppError? _error;

  ExpenseProvider({required ExpenseService expenseService})
    : _expenseService = expenseService;

  void setExpenseService(ExpenseService service) {
    _expenseService = service;
  }

  // Getters
  List<Expense> get expenses => _expenses;
  Expense? get selectedExpense => _selectedExpense;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Future<void> fetchExpenses() async {
    _setLoading(true);
    _clearError();
    try {
      _expenses = await _expenseService.getExpenses();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchExpense(int id) async {
    _setLoading(true);
    _clearError();
    try {
      _selectedExpense = await _expenseService.getExpense(id);
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createExpense({
    required double amount,
    required String category,
    required String description,
    required String location,
    String? travelType,
    String? fromLocation,
    String? toLocation,
    double? km,
    double? tollAmount,
    String? checkIn,
    String? checkOut,
    File? billFile,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final newExpense = await _expenseService.createExpense(
        amount: amount,
        category: category,
        description: description,
        location: location,
        travelType: travelType,
        fromLocation: fromLocation,
        toLocation: toLocation,
        km: km,
        tollAmount: tollAmount,
        checkIn: checkIn,
        checkOut: checkOut,
        billFile: billFile,
      );
      _expenses.add(newExpense);
      notifyListeners();
    } catch (e) {
      _setError(e);
      throw e; // Rethrow to allow UI to show error message
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editExpense({
    required int id,
    required double amount,
    required String category,
    required String description,
    required String location,
    String? travelType,
    String? fromLocation,
    String? toLocation,
    double? km,
    double? tollAmount,
    String? checkIn,
    String? checkOut,
    File? billFile,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final updatedExpense = await _expenseService.editExpense(
        id: id,
        amount: amount,
        category: category,
        description: description,
        location: location,
        travelType: travelType,
        fromLocation: fromLocation,
        toLocation: toLocation,
        km: km,
        tollAmount: tollAmount,
        checkIn: checkIn,
        checkOut: checkOut,
        billFile: billFile,
      );
      
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
      if (_selectedExpense?.id == id) {
        _selectedExpense = updatedExpense;
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e);
      throw e; 
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateExpense(int id, {String? status}) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await _expenseService.updateExpense(id, status: status);
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updated;
      }
      if (_selectedExpense?.id == id) {
        _selectedExpense = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(int id) async {
    _setLoading(true);
    _clearError();
    try {
      await _expenseService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      if (_selectedExpense?.id == id) {
        _selectedExpense = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  void selectExpense(Expense expense) {
    _selectedExpense = expense;
    notifyListeners();
  }

  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(dynamic error) {
    _error = error is AppError ? error : AppError.fromDioException(error);
  }

  void _clearError() {
    _error = null;
  }
}
