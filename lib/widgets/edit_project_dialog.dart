import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
// If file upload is implemented fully with backend, we can use file_selector here
// import 'package:file_selector/file_selector.dart';

class EditProjectDialog extends StatefulWidget {
  final Project project;
  const EditProjectDialog({super.key, required this.project});

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _locationController;

  late TextEditingController _dateOfAppController;
  late TextEditingController _surveyController;
  late TextEditingController _farPurchaseController;
  late TextEditingController _buildingPlanApprovalController;
  late TextEditingController _buildingPlanRemarkController;
  late TextEditingController _revisedBuildingPlanController;
  late TextEditingController _factoryActConsultantController;
  late TextEditingController _firefightingApprovalController;
  late TextEditingController _fireNocController;
  late TextEditingController _labourCessController;
  late TextEditingController _solarHaredanOcController;

  final List<TextEditingController> _clientNameControllers = [];
  final List<TextEditingController> _contactNoControllers = [];

  String _status = 'Award to Start';
  String _teamLead = 'Select Team Lead';

  // For documents, we will mock the visual state.
  // In a real scenario, this would hold XFile objects.
  Map<String, bool> _hasFile = {};
  Map<String, TextEditingController> _docRemarkControllers = {};

  bool _isLoading = false;

  final List<String> _docKeys = [
    'AWARD LETTER',
    'LAND PAPER / ZONING',
    'SOIL TESTING',
    'WATER TESTING',
    'PLOT DEMARCATION BY GOVT',
    'DPC CERTIFICATE'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameController = TextEditingController(text: p.name);
    _addressController = TextEditingController(text: p.address == 'N/A' ? '' : p.address);
    _locationController = TextEditingController(text: p.location == 'N/A' ? '' : p.location);

    _dateOfAppController = TextEditingController(text: p.dateOfApp);
    _surveyController = TextEditingController(text: p.survey);
    _farPurchaseController = TextEditingController(text: p.farPurchase);
    _buildingPlanApprovalController = TextEditingController(text: p.buildingPlanApproval);
    _buildingPlanRemarkController = TextEditingController(text: p.buildingPlanRemark);
    _revisedBuildingPlanController = TextEditingController(text: p.revisedBuildingPlan);
    _factoryActConsultantController = TextEditingController(text: p.factoryActConsultant);
    _firefightingApprovalController = TextEditingController(text: p.firefightingApproval);
    _fireNocController = TextEditingController(text: p.fireNoc);
    _labourCessController = TextEditingController(text: p.labourCess);
    _solarHaredanOcController = TextEditingController(text: p.solarHaredanOc);

    _status = p.status;
    _teamLead = p.teamLead == 'N/A' || p.teamLead.isEmpty ? 'Select Team Lead' : p.teamLead;

    // Split clients
    if (p.clientName.isNotEmpty && p.clientName != 'N/A') {
      final names = p.clientName.split('\n');
      final contacts = p.contactNo.split('\n');
      for (int i = 0; i < names.length; i++) {
        _clientNameControllers.add(TextEditingController(text: names[i]));
        _contactNoControllers.add(TextEditingController(text: i < contacts.length ? contacts[i] : ''));
      }
    } else {
      _clientNameControllers.add(TextEditingController());
      _contactNoControllers.add(TextEditingController());
    }

    _docRemarkControllers = {
      'AWARD LETTER': TextEditingController(text: p.awardLetterRemark),
      'LAND PAPER / ZONING': TextEditingController(text: p.landPaperZoningRemark),
      'SOIL TESTING': TextEditingController(text: p.soilTestingRemark),
      'WATER TESTING': TextEditingController(text: p.waterTestingRemark),
      'PLOT DEMARCATION BY GOVT': TextEditingController(text: p.plotDemarcationRemark),
      'DPC CERTIFICATE': TextEditingController(text: p.dpcCertificateRemark),
    };

    _hasFile = {
      'AWARD LETTER': p.awardLetter.isNotEmpty,
      'LAND PAPER / ZONING': p.landPaperZoning.isNotEmpty,
      'SOIL TESTING': p.soilTesting.isNotEmpty,
      'WATER TESTING': p.waterTesting.isNotEmpty,
      'PLOT DEMARCATION BY GOVT': p.plotDemarcation.isNotEmpty,
      'DPC CERTIFICATE': p.dpcCertificate.isNotEmpty,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _dateOfAppController.dispose();
    _surveyController.dispose();
    _farPurchaseController.dispose();
    _buildingPlanApprovalController.dispose();
    _buildingPlanRemarkController.dispose();
    _revisedBuildingPlanController.dispose();
    _factoryActConsultantController.dispose();
    _firefightingApprovalController.dispose();
    _fireNocController.dispose();
    _labourCessController.dispose();
    _solarHaredanOcController.dispose();

    for (var c in _clientNameControllers) c.dispose();
    for (var c in _contactNoControllers) c.dispose();
    for (var c in _docRemarkControllers.values) c.dispose();

    super.dispose();
  }

  void _addClient() {
    setState(() {
      _clientNameControllers.add(TextEditingController());
      _contactNoControllers.add(TextEditingController());
    });
  }

  void _removeClient(int index) {
    if (_clientNameControllers.length > 1) {
      setState(() {
        _clientNameControllers.removeAt(index).dispose();
        _contactNoControllers.removeAt(index).dispose();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<ProjectProvider>();

    final clientNames = _clientNameControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join('\n');
    final contactNos = _contactNoControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join('\n');

    final data = {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? 'N/A' : _addressController.text.trim(),
      'location': _locationController.text.trim().isEmpty ? 'N/A' : _locationController.text.trim(),
      'client_name': clientNames.isEmpty ? 'N/A' : clientNames,
      'contact_no': contactNos.isEmpty ? 'N/A' : contactNos,
      'status': _status,
      'team_lead': _teamLead == 'Select Team Lead' ? '' : _teamLead,
      'date_of_app': _dateOfAppController.text.trim(),
      'survey': _surveyController.text.trim(),
      'far_purchase': _farPurchaseController.text.trim(),
      'building_plan_approval': _buildingPlanApprovalController.text.trim(),
      'building_plan_remark': _buildingPlanRemarkController.text.trim(),
      'revised_building_plan': _revisedBuildingPlanController.text.trim(),
      'factory_act_consultant': _factoryActConsultantController.text.trim(),
      'firefighting_approval': _firefightingApprovalController.text.trim(),
      'fire_noc': _fireNocController.text.trim(),
      'labour_cess': _labourCessController.text.trim(),
      'solar_haredan_oc': _solarHaredanOcController.text.trim(),
      'award_letter_remark': _docRemarkControllers['AWARD LETTER']!.text.trim(),
      'land_paper_zonning_remark': _docRemarkControllers['LAND PAPER / ZONING']!.text.trim(),
      'soil_testing_remark': _docRemarkControllers['SOIL TESTING']!.text.trim(),
      'water_testing_remark': _docRemarkControllers['WATER TESTING']!.text.trim(),
      'plot_demarcation_by_govt_remark': _docRemarkControllers['PLOT DEMARCATION BY GOVT']!.text.trim(),
      'dpc_certificate_remark': _docRemarkControllers['DPC CERTIFICATE']!.text.trim(),
    };

    try {
      await provider.updateProject(widget.project.id, data);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error?.message ?? 'Failed to update project'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: sw > 700 ? 700 : double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Project: ${widget.project.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('Update full project details and documents', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black54),
                  splashRadius: 20,
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID and Name
                      Row(
                        children: [
                          Expanded(
                            child: _buildStaticTextField('PROJECT ID', widget.project.id.toString()),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('PROJECT NAME *', 'e.g. Smart City', _nameController, isRequired: true)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Client Info Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text('CLIENT INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                          TextButton.icon(
                            onPressed: _addClient,
                            icon: const Icon(Icons.add_circle_outline, size: 16),
                            label: const Text('ADD CLIENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),

                      ...List.generate(_clientNameControllers.length, (index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(child: _buildTextField('CLIENT NAME ${index + 1}', 'Enter Client Name', _clientNameControllers[index])),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('CONTACT NO ${index + 1}', 'Enter Contact Number', _contactNoControllers[index])),
                              if (_clientNameControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeClient(index),
                                )
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('ADDRESS', 'Project Address', _addressController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('LOCATION', 'Project Location', _locationController)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // DETAILED INFORMATION
                      const Text('DETAILED INFORMATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown('STATUS', ['Award to Start', 'Running', 'Provision', 'Hold', 'Completed', 'Cancelled', 'Active'], _status, (val) {
                              if (val != null) setState(() => _status = val);
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown('TEAM LEAD', ['Select Team Lead', 'ram dev', 'abhishek', 'test lead'], _teamLead, (val) {
                              if (val != null) setState(() => _teamLead = val);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('DATE OF APP', 'dd-mm-yyyy', _dateOfAppController, suffixIcon: Icons.calendar_today_outlined),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('SURVEY', 'survey details', _surveyController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('FAR PURCHASE', 'purchase details', _farPurchaseController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('BUILDING PLAN APPROVAL', 'Approval Detail', _buildingPlanApprovalController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('BUILDING PLAN REMARK', 'Remark', _buildingPlanRemarkController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('REVISED BUILDING PLAN', 'Details', _revisedBuildingPlanController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('FACTORY ACT CONSULTANT', 'Consultant Details', _factoryActConsultantController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('FIREFIGHTING APPROVAL', '2026-03-23...', _firefightingApprovalController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('FIRE NOC', 'NOC Detail', _fireNocController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('LABOUR CESS', 'Cess Detail', _labourCessController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('SOLAR HAREDAN OC', 'OC Detail', _solarHaredanOcController)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // DOCUMENTS UPLOAD
                      const Text('DOCUMENTS (UPLOAD)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 16),

                      ..._docKeys.map((key) => _buildDocUploadBlock(key)).toList(),

                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade300),
                      backgroundColor: Colors.grey.shade50,
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update Project', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isRequired = false, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: Colors.black87) : null,
          ),
          validator: isRequired ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null : null,
        ),
      ],
    );
  }

  Widget _buildStaticTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(value, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    String actualValue = items.contains(value) ? value : items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          offset: const Offset(0, 4),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          padding: EdgeInsets.zero,
          onSelected: onChanged,
          itemBuilder: (context) {
            return items.map((item) {
              final isSelected = item == actualValue;
              return PopupMenuItem<String>(
                value: item,
                padding: EdgeInsets.zero,
                height: 40,
                child: Container(
                  width: double.infinity,
                  color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Colors.blue.shade700 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(actualValue, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocUploadBlock(String title) {
    final bool uploaded = _hasFile[title] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              if (uploaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 12, color: Colors.green.shade600),
                      const SizedBox(width: 4),
                      Text('READY', style: TextStyle(color: Colors.green.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () {
                    // Pick file logic placeholder
                    setState(() {
                      _hasFile[title] = !(_hasFile[title] ?? false); // Toggle visually
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            uploaded ? 'File Uploaded ✓' : 'Choose File',
                            style: TextStyle(color: uploaded ? Colors.black87 : Colors.grey.shade500, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.upload_file, color: Colors.grey.shade400, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              if (uploaded)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      icon: Icon(Icons.remove_red_eye, color: Colors.purple.shade300, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: TextFormField(
                  controller: _docRemarkControllers[title],
                  decoration: InputDecoration(
                    hintText: 'Add remark/description...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
