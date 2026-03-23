import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/vendor_provider.dart';
import '../models/vendor_model.dart';

class SubmitVendorDialog extends StatefulWidget {
  final Vendor? vendor;

  const SubmitVendorDialog({super.key, this.vendor});

  @override
  State<SubmitVendorDialog> createState() => _SubmitVendorDialogState();
}

class _SubmitVendorDialogState extends State<SubmitVendorDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();

  final TextEditingController _suggestedByController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _externalLinkController = TextEditingController();

  List<String> _selectedCategories = [];
  List<String> _selectedSubCategories = [];
  List<String> _selectedProjects = [];

  String _docType = 'Upload to Drive'; // 'Upload to Drive' or 'External Link'
  File? _profileFile;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.vendor != null) {
      final v = widget.vendor!;
      _companyController.text = v.companyName;
      _emailController.text = v.email ?? '';
      _locationController.text = v.location ?? '';
      _addressController.text = v.address ?? '';
      _contactPersonController.text = v.contactPerson ?? '';
      _contactNumberController.text = v.contactNumber ?? '';
      _profileNameController.text = v.profileName ?? '';
      _suggestedByController.text = v.suggestedBy ?? '';
      _websiteController.text = v.websiteUrl ?? '';
      _linkedinController.text = v.linkedinUrl ?? '';
      
      _selectedCategories = List.from(v.categories);
      _selectedSubCategories = List.from(v.subCategories);
      _selectedProjects = List.from(v.projects);

      if (v.profileDocType == 'External_Link') {
        _docType = 'External Link';
        _externalLinkController.text = v.profileDocValue ?? '';
      } else if (v.profileDocValue?.isNotEmpty == true) {
        _docType = 'Upload to Drive';
        // Can't easily pre-select file, so we leave `_profileFile` null 
        // but backend will keep old file if we don't send a new one.
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final data = {
        'company_name': _companyController.text.trim(),
        'email': _emailController.text.trim(),
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
        
        'contact_person': _contactPersonController.text.trim(),
        'contact_number': _contactNumberController.text.trim(),
        'profile_name': _profileNameController.text.trim(),
        
        'categories': jsonEncode(_selectedCategories),
        'sub_categories': jsonEncode(_selectedSubCategories),
        'projects': jsonEncode(_selectedProjects),
        
        'suggested_by': _suggestedByController.text.trim(),
        'website_url': _websiteController.text.trim(),
        'linkedin_url': _linkedinController.text.trim(),
        
        'profile_doc_type': _docType == 'Upload to Drive' ? 'Upload_File' : 'External_Link',
        'profile_doc_value': _docType == 'External Link' ? _externalLinkController.text.trim() : '',
      };

      // Handle the file upload via multipart/form-data by passing file path in the map
      // (The actual VendorService createVendor method would need to read `profile_doc` 
      // if using `FormData.fromMap` using `MultipartFile.fromFileSync`)
      if (_docType == 'Upload to Drive' && _profileFile != null) {
        // Need to add file to data if vendor service supports it.
        // For now, we will just simulate what nodejs takes
        data['profile_doc_path'] = _profileFile!.path; // Signal for service
      }

      if (widget.vendor != null) {
        await context.read<VendorProvider>().updateVendor(widget.vendor!.id, data);
      } else {
        await context.read<VendorProvider>().createVendor(data);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.vendor != null ? 'Vendor updated successfully' : 'Vendor created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save vendor: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProvider>();
    final allCategories = provider.uniqueCategories.isEmpty 
        ? ['STP CONTRACTOR', 'LIFT CONTRACTOR', 'FIRE CONTRACTOR', 'PEB CONTRACTOR'] 
        : provider.uniqueCategories;
        
    final allProjects = provider.uniqueProjects.isEmpty 
        ? ['290-KL EXPORT PVT. LTD., FARIDABAD', '530-POLYLACE EXPANSION, BAWAL'] 
        : provider.uniqueProjects;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          margin: const EdgeInsets.only(top: kToolbarHeight, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.vendor != null ? 'Edit Vendor' : 'Add New Vendor',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.black12),
              
              // Scrollable Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTextField('COMPANY NAME *', _companyController, required: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('EMAIL ID *', _emailController, required: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('LOCATION', _locationController)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Address
                        _buildTextField('ADDRESS', _addressController, maxLines: 3),
                        const SizedBox(height: 20),
                        
                        // Row 3
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTextField('CONTACT PERSON', _contactPersonController)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('CONTACT NUMBER', _contactNumberController)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('PROFILE NAME', _profileNameController)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Row 4
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildMultiSelectDropdown(
                                'VENDOR CATEGORY',
                                'Select Category',
                                allCategories,
                                _selectedCategories,
                                (val) => setState(() {
                                  if (val != null && !_selectedCategories.contains(val)) {
                                    _selectedCategories.add(val);
                                  }
                                }),
                                (val) => setState(() => _selectedCategories.remove(val)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMultiSelectDropdown(
                                'VENDOR SUB CATEGORY',
                                'Select Sub Category',
                                allCategories, // Dummy reuse
                                _selectedSubCategories,
                                (val) => setState(() {
                                  if (val != null && !_selectedSubCategories.contains(val)) {
                                    _selectedSubCategories.add(val);
                                  }
                                }),
                                (val) => setState(() => _selectedSubCategories.remove(val)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('SUGGESTED BY', _suggestedByController)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Row 5
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTextField('WEBSITE URL', _websiteController)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('LINKEDIN URL', _linkedinController)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Projects
                        _buildMultiSelectDropdown(
                          'PROJECT NAMES (MULTIPLE SELECTION)',
                          'Select Project',
                          allProjects,
                          _selectedProjects,
                          (val) => setState(() {
                            if (val != null && !_selectedProjects.contains(val)) {
                              _selectedProjects.add(val);
                            }
                          }),
                          (val) => setState(() => _selectedProjects.remove(val)),
                        ),
                        const SizedBox(height: 24),

                        // Profile Document
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Profile Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildToggleButton('Upload to Drive')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildToggleButton('External Link')),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_docType == 'Upload to Drive')
                                InkWell(
                                  onTap: _pickFile,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _profileFile != null ? _profileFile!.path.split('/').last : 'Tap to select file',
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                _buildTextField('EXTERNAL DOCUMENT LINK', _externalLinkController),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting 
                            ? const SizedBox(height:20, width:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Vendor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          validator: required ? (v) => v!.trim().isEmpty ? 'Required' : null : null,
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdown(
    String label, 
    String hint, 
    List<String> items, 
    List<String> selectedItems,
    Function(String?) onSelected,
    Function(String) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
        const SizedBox(height: 6),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          onSelected: onSelected,
          constraints: const BoxConstraints(maxHeight: 300),
          itemBuilder: (BuildContext context) {
            return items.map((String item) {
              return PopupMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
        if (selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedItems.map((item) {
                return InputChip(
                  label: Text(
                    item,
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.blue.shade50,
                  deleteIcon: Icon(Icons.close, color: Colors.red.shade400, size: 14),
                  onDeleted: () => onRemove(item),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.transparent),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: -2),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleButton(String type) {
    final isSelected = _docType == type;
    return InkWell(
      onTap: () => setState(() => _docType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}