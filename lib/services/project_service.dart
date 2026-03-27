import 'dart:io';
import 'package:dio/dio.dart';
import '../models/project_model.dart';
import '../models/error_model.dart';
import 'dio_service.dart';

class ProjectService {
  final DioService _dioService;

  ProjectService({required DioService dioService}) : _dioService = dioService;

  Future<List<Project>> getProjects() async {
    try {
      return await _dioService.get<List<Project>>(
        '/projects',
        fromJson: (json) {
          final list = json as List;
          return list
              .map((item) => Project.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Project> getProject(int id) async {
    try {
      return await _dioService.get<Project>(
        '/projects/$id',
        fromJson: (json) => Project.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Project> createProject({
    int? id,
    required String name,
    required String address,
    required String location,
    required String clientName,
    required String contactNo,
    required String status,
    required String teamLead,
  }) async {
    try {
      final data = {
        if (id != null) 'id': id,
        'name': name,
        'address': address,
        'location': location,
        'client_name': clientName,
        'contact_no': contactNo,
        'status': status,
        'team_lead': teamLead,
      };
      return await _dioService.post<Project>(
        '/projects',
        data: data,
        fromJson: (json) {
          final map = json as Map<String, dynamic>;
          final payload = map['project'] as Map<String, dynamic>? ?? map;
          return Project.fromJson(payload);
        },
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<Project> updateProject(
    int id,
    Map<String, dynamic> data, {
    Project? existingProject,
    Map<String, String>? filePaths,
  }) async {
    try {
      final requestData = await _buildProjectPayload(
        data: data,
        filePaths: filePaths,
      );
      final response = await _dioService.put<Map<String, dynamic>>(
        '/projects/$id',
        data: requestData,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final updatedPayload =
          response['updated'] as Map<String, dynamic>? ?? data;

      if (existingProject != null) {
        return _mergeProjectWithUpdate(
          existingProject,
          updatedPayload,
          filePaths: filePaths,
        );
      }

      return Project.fromJson({
        'id': id,
        ...updatedPayload,
      });
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        '/projects/$id',
        fromJson: (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw AppError.fromDioException(e);
    }
  }

  Future<dynamic> _buildProjectPayload({
    required Map<String, dynamic> data,
    Map<String, String>? filePaths,
  }) async {
    if (filePaths == null || filePaths.isEmpty) {
      return data;
    }

    final formData = FormData.fromMap(data);
    for (final entry in filePaths.entries) {
      final path = entry.value.trim();
      if (path.isEmpty) continue;

      formData.files.add(
        MapEntry(
          entry.key,
          await MultipartFile.fromFile(
            path,
            filename: path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }
    return formData;
  }

  Project _mergeProjectWithUpdate(
    Project project,
    Map<String, dynamic> data, {
    Map<String, String>? filePaths,
  }) {
    String? value(String key) => data[key]?.toString();
    String? fileValue(String key) {
      final path = filePaths?[key];
      if (path == null || path.trim().isEmpty) return null;
      return Uri.file(path).toString();
    }

    return project.copyWith(
      name: value('name'),
      address: value('address'),
      location: value('location'),
      clientName: value('client_name'),
      contactNo: value('contact_no'),
      status: value('status'),
      teamLead: value('team_lead'),
      dateOfApp: value('date_of_app'),
      survey: value('survey'),
      farPurchase: value('far_purchase'),
      buildingPlanApproval: value('building_plan_approval'),
      buildingPlanRemark: value('building_plan_remark'),
      revisedBuildingPlan: value('revised_building_plan'),
      factoryActConsultant: value('factory_act_consultant'),
      firefightingApproval: value('firefighting_approval'),
      fireNoc: value('fire_noc'),
      fireNocRemark: value('fire_noc_remark'),
      labourCess: value('labour_cess'),
      labourCessRemark: value('labour_cess_remark'),
      solarHaredanOc: value('solar_haredan_oc'),
      solarHaredanOcRemark: value('solar_haredan_oc_remark'),
      awardLetter: fileValue('award_letter') ?? value('award_letter'),
      awardLetterRemark: value('award_letter_remark'),
      landPaperZoning:
          fileValue('land_paper_zonning') ?? value('land_paper_zonning'),
      landPaperZoningRemark: value('land_paper_zonning_remark'),
      soilTesting: fileValue('soil_testing') ?? value('soil_testing'),
      soilTestingRemark: value('soil_testing_remark'),
      waterTesting: fileValue('water_testing') ?? value('water_testing'),
      waterTestingRemark: value('water_testing_remark'),
      plotDemarcation:
          fileValue('plot_demarcation_by_govt') ??
          value('plot_demarcation_by_govt'),
      plotDemarcationRemark: value('plot_demarcation_by_govt_remark'),
      dpcCertificate:
          fileValue('dpc_certificate') ?? value('dpc_certificate'),
      dpcCertificateRemark: value('dpc_certificate_remark'),
    );
  }
}
