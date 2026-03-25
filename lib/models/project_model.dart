class Project {
  final int id;
  final String name;
  final String address;
  final String location;
  final String clientName;
  final String contactNo;
  final String status;
  final String teamLead;

  // Detailed Info
  final String dateOfApp;
  final String survey;
  final String farPurchase;
  final String buildingPlanApproval;
  final String buildingPlanRemark;
  final String revisedBuildingPlan;
  final String factoryActConsultant;
  final String firefightingApproval;
  final String fireNoc;
  final String labourCess;
  final String solarHaredanOc;

  // Documents URLs
  final String awardLetter;
  final String awardLetterRemark;
  final String landPaperZoning;
  final String landPaperZoningRemark;
  final String soilTesting;
  final String soilTestingRemark;
  final String waterTesting;
  final String waterTestingRemark;
  final String plotDemarcation;
  final String plotDemarcationRemark;
  final String dpcCertificate;
  final String dpcCertificateRemark;

  Project({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.clientName,
    required this.contactNo,
    required this.status,
    required this.teamLead,
    this.dateOfApp = '',
    this.survey = '',
    this.farPurchase = '',
    this.buildingPlanApproval = '',
    this.buildingPlanRemark = '',
    this.revisedBuildingPlan = '',
    this.factoryActConsultant = '',
    this.firefightingApproval = '',
    this.fireNoc = '',
    this.labourCess = '',
    this.solarHaredanOc = '',
    this.awardLetter = '',
    this.awardLetterRemark = '',
    this.landPaperZoning = '',
    this.landPaperZoningRemark = '',
    this.soilTesting = '',
    this.soilTestingRemark = '',
    this.waterTesting = '',
    this.waterTestingRemark = '',
    this.plotDemarcation = '',
    this.plotDemarcationRemark = '',
    this.dpcCertificate = '',
    this.dpcCertificateRemark = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? 'N/A',
      location: json['location']?.toString() ?? 'N/A',
      clientName: json['client_name']?.toString() ?? 'N/A',
      contactNo: json['contact_no']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'Active',
      teamLead: json['team_lead']?.toString() ?? 'N/A',
      
      dateOfApp: json['date_of_app']?.toString() ?? '',
      survey: json['survey']?.toString() ?? '',
      farPurchase: json['far_purchase']?.toString() ?? '',
      buildingPlanApproval: json['building_plan_approval']?.toString() ?? '',
      buildingPlanRemark: json['building_plan_remark']?.toString() ?? '',
      revisedBuildingPlan: json['revised_building_plan']?.toString() ?? '',
      factoryActConsultant: json['factory_act_consultant']?.toString() ?? '',
      firefightingApproval: json['firefighting_approval']?.toString() ?? '',
      fireNoc: json['fire_noc']?.toString() ?? '',
      labourCess: json['labour_cess']?.toString() ?? '',
      solarHaredanOc: json['solar_haredan_oc']?.toString() ?? '',

      awardLetter: json['award_letter']?.toString() ?? '',
      awardLetterRemark: json['award_letter_remark']?.toString() ?? '',
      landPaperZoning: json['land_paper_zonning']?.toString() ?? '',
      landPaperZoningRemark: json['land_paper_zonning_remark']?.toString() ?? '',
      soilTesting: json['soil_testing']?.toString() ?? '',
      soilTestingRemark: json['soil_testing_remark']?.toString() ?? '',
      waterTesting: json['water_testing']?.toString() ?? '',
      waterTestingRemark: json['water_testing_remark']?.toString() ?? '',
      plotDemarcation: json['plot_demarcation_by_govt']?.toString() ?? '',
      plotDemarcationRemark: json['plot_demarcation_by_govt_remark']?.toString() ?? '',
      dpcCertificate: json['dpc_certificate']?.toString() ?? '',
      dpcCertificateRemark: json['dpc_certificate_remark']?.toString() ?? '',
    );
  }
}
