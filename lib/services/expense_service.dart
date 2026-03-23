import 'dart:io';
import 'package:dio/dio.dart';
import '../models/expense_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class ExpenseService {
  final DioService _dioService;

  ExpenseService({required DioService dioService}) : _dioService = dioService;

  Future<List<Expense>> getExpenses() async {
    try {
      return await _dioService.get<List<Expense>>(
        '/expenses',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Expense.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Expense> getExpense(int id) async {
    try {
      return await _dioService.get<Expense>(
        '/expenses/$id',
        fromJson: (json) => Expense.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Expense> createExpense({
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
    try {
      final mapData = <String, dynamic>{
        'amount': amount,
        'category': category,
        'other_description': description,
        'location': location,
      };

      if (travelType != null && travelType.isNotEmpty)
        mapData['travel_type'] = travelType;
      if (fromLocation != null && fromLocation.isNotEmpty)
        mapData['from_location'] = fromLocation;
      if (toLocation != null && toLocation.isNotEmpty)
        mapData['to_location'] = toLocation;
      if (km != null) mapData['km'] = km;
      if (tollAmount != null) mapData['toll_amount'] = tollAmount;
      if (checkIn != null && checkIn.isNotEmpty) mapData['check_in'] = checkIn;
      if (checkOut != null && checkOut.isNotEmpty)
        mapData['check_out'] = checkOut;

      final formData = FormData.fromMap(mapData);

      if (billFile != null) {
        formData.files.add(
          MapEntry(
            'bill', // API expects this key
            await MultipartFile.fromFile(
              billFile.path,
              filename: billFile.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      return await _dioService.post<Expense>(
        '/expenses',
        data: formData,
        fromJson: (json) {
          // Backend returns { message: "...", expense: {...} }
          final dataMap = json as Map<String, dynamic>;
          final expenseData = dataMap['expense'] ?? dataMap;
          return Expense.fromJson(expenseData as Map<String, dynamic>);
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Expense> editExpense({
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
    try {
      final mapData = <String, dynamic>{
        'amount': amount,
        'category': category,
        'other_description': description,
        'location': location,
      };

      if (travelType != null && travelType.isNotEmpty) {
        mapData['travel_type'] = travelType;
      } else {
        mapData['travel_type'] = '';
      }
      
      if (fromLocation != null && fromLocation.isNotEmpty) {
        mapData['from_location'] = fromLocation;
      } else {
        mapData['from_location'] = '';
      }
      
      if (toLocation != null && toLocation.isNotEmpty) {
        mapData['to_location'] = toLocation;
      } else {
        mapData['to_location'] = '';
      }
      
      if (km != null) {
        mapData['km'] = km;
      } else {
        mapData['km'] = '';
      }
      
      if (tollAmount != null) {
        mapData['toll_amount'] = tollAmount;
      } else {
         mapData['toll_amount'] = '';
      }
      
      if (checkIn != null && checkIn.isNotEmpty) {
        mapData['check_in'] = checkIn;
      } else {
        mapData['check_in'] = '';
      }
      
      if (checkOut != null && checkOut.isNotEmpty) {
        mapData['check_out'] = checkOut;
      } else {
        mapData['check_out'] = '';
      }

      final formData = FormData.fromMap(mapData);

      if (billFile != null) {
        formData.files.add(
          MapEntry(
            'bill',
            await MultipartFile.fromFile(
              billFile.path,
              filename: billFile.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      return await _dioService.put<Expense>(
        '/expenses/edit/$id',
        data: formData,
        fromJson: (json) {
          final dataMap = json as Map<String, dynamic>;
          final expenseData = dataMap['updatedExpense'] ?? dataMap['expense'] ?? dataMap;
          return Expense.fromJson(expenseData as Map<String, dynamic>);
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Expense> updateExpense(int id, {String? status}) async {
    try {
      final data = {if (status != null) 'status': status};
      return await _dioService.put<Expense>(
        '/expenses/$id',
        data: data,
        fromJson: (json) => Expense.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/expenses/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
