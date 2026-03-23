import 'package:dio/dio.dart';
import '../models/vendor_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class VendorService {
  final DioService _dioService;

  VendorService({required DioService dioService}) : _dioService = dioService;

  Future<List<Vendor>> getVendors() async {
    try {
      return await _dioService.get<List<Vendor>>(
        '/vendors',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Vendor.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Vendor> createVendor(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      if (data.containsKey('profile_doc_path')) {
        formData.files.add(MapEntry(
            'profile_doc',
            await MultipartFile.fromFile(data['profile_doc_path'])));
      }
      return await _dioService.post<Vendor>(
        '/vendors',
        data: formData,
        fromJson: (json) => Vendor.fromJson(json['vendor'] ?? json),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Vendor> updateVendor(String id, Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      if (data.containsKey('profile_doc_path')) {
        formData.files.add(MapEntry(
            'profile_doc',
            await MultipartFile.fromFile(data['profile_doc_path'])));
      }
      return await _dioService.put<Vendor>(
        '/vendors/$id',
        data: formData,
        fromJson: (json) => Vendor.fromJson(json['vendor'] ?? json),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }
}
