import 'package:flutter/foundation.dart';
import '../models/vendor_model.dart';
import '../models/error_model.dart';
import '../services/vendor_service.dart';

class VendorProvider extends ChangeNotifier {
  late VendorService _vendorService;

  List<Vendor> _vendors = [];
  bool _isLoading = false;
  AppError? _error;

  String? _selectedCompany;
  String? _selectedCategory;
  String? _selectedProject;

  VendorProvider({required VendorService vendorService})
    : _vendorService = vendorService;

  void setVendorService(VendorService service) {
    _vendorService = service;
  }

  // Getters
  List<Vendor> get vendors => _vendors;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  bool get hasError => _error != null;

  String? get selectedCompany => _selectedCompany;
  String? get selectedCategory => _selectedCategory;
  String? get selectedProject => _selectedProject;

  List<Vendor> get filteredVendors {
    return _vendors.where((v) {
      if (_selectedCompany != null && _selectedCompany!.isNotEmpty) {
        if (v.companyName != _selectedCompany) return false;
      }
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (!v.categories.contains(_selectedCategory)) return false;
      }
      if (_selectedProject != null && _selectedProject!.isNotEmpty) {
        if (!v.projects.contains(_selectedProject)) return false;
      }
      return true;
    }).toList();
  }

  List<String> get uniqueCompanies {
    final companies = _vendors.map((v) => v.companyName).where((c) => c.isNotEmpty).toSet().toList();
    companies.sort();
    return companies;
  }

  List<String> get uniqueCategories {
    final categories = _vendors.expand((v) => v.categories).where((c) => c.isNotEmpty).toSet().toList();
    categories.sort();
    return categories;
  }

  List<String> get uniqueProjects {
    final projects = _vendors.expand((v) => v.projects).where((p) => p.isNotEmpty).toSet().toList();
    projects.sort();
    return projects;
  }

  void setFilters({String? company, String? category, String? project}) {
    _selectedCompany = company;
    _selectedCategory = category;
    _selectedProject = project;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCompany = null;
    _selectedCategory = null;
    _selectedProject = null;
    notifyListeners();
  }

  Future<void> fetchVendors() async {
    _setLoading(true);
    _clearError();
    try {
      _vendors = await _vendorService.getVendors();
      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createVendor(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      await _vendorService.createVendor(data);
      await fetchVendors(); // Refresh the list
    } catch (e) {
      _setError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVendor(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      await _vendorService.updateVendor(id, data);
      await fetchVendors(); // Refresh the list
    } catch (e) {
      _setError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(dynamic error) {
    _error = error is AppError ? error : AppError.fromDioException(error);
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
