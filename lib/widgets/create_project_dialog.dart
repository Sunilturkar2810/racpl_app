import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  final List<TextEditingController> _clientNameControllers = [TextEditingController()];
  final List<TextEditingController> _contactNoControllers = [TextEditingController()];

  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    for (var c in _clientNameControllers) {
      c.dispose();
    }
    for (var c in _contactNoControllers) {
      c.dispose();
    }
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

    final clientNames = _clientNameControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .join('\n');
    final contactNos = _contactNoControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .join('\n');

    final idVal = int.tryParse(_idController.text.trim());

    try {
      await provider.createProject(
        id: idVal,
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty ? 'N/A' : _addressController.text.trim(),
        location: _locationController.text.trim().isEmpty ? 'N/A' : _locationController.text.trim(),
        clientName: clientNames.isEmpty ? 'N/A' : clientNames,
        contactNo: contactNos.isEmpty ? 'N/A' : contactNos,
        status: 'Award to Start',
        teamLead: 'N/A',
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created successfully', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error?.message ?? 'Failed to create project'), backgroundColor: Colors.red),
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
        width: sw > 600 ? 600 : double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create New Project', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('Enter basic project details', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID and Name
                      Row(
                        children: [
                          Expanded(child: _buildTextField('PROJECT ID', 'Enter Project ID', _idController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('PROJECT NAME *', 'e.g. Smart City Phase 1', _nameController, isRequired: true)),
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

                      // Dynamic Client Fields
                      ...List.generate(_clientNameControllers.length, (index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _buildTextField('CLIENT NAME ${index + 1}', 'Enter Client Name', _clientNameControllers[index])),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('CONTACT NO ${index + 1}', 'Enter Contact Number', _contactNoControllers[index])),
                              if (_clientNameControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeClient(index),
                                  padding: const EdgeInsets.only(left: 8, top: 20),
                                )
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),
                      
                      // Address & Location
                      Row(
                        children: [
                          Expanded(child: _buildTextField('ADDRESS', 'Project Address', _addressController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('LOCATION', 'Project Location', _locationController)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                        : const Text('Create Project', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
        ),
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
          ),
          validator: isRequired ? (v) => v == null || v.trim().isEmpty ? '$label is required' : null : null,
        ),
      ],
    );
  }
} // End CreateProjectDialog
