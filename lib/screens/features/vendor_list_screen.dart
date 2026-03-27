import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:open_filex/open_filex.dart';
import 'package:racpl/theme/app_colors.dart';
import '../../providers/vendor_provider.dart';

import '../../models/vendor_model.dart';
import '../../widgets/vendor_details_dialog.dart';
import '../../widgets/submit_vendor_dialog.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VendorProvider>().fetchVendors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // light background
      appBar: AppBar(
        title: const Text(
          'Vendor Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),

      body: Consumer<VendorProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildFilters(context, provider),
              Expanded(
                child: _buildList(provider),
              ),
            ],
          );
        },
      ),
      // Optional: uncomment if you want a FAB to add vendors like in web
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   icon: const Icon(Icons.add),
      //   label: const Text('Create Vendor'),
      // ),
    );
  }

  Future<void> _exportCSV(BuildContext context, VendorProvider provider) async {
    try {
      final vendors = provider.filteredVendors;
      if (vendors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No vendors to export')),
        );
        return;
      }

      final headers = [
        "Vendor ID", "Company Name", "Email", "Location", "Address", 
        "Contact Person", "Contact Number", "Categories", "Projects", "Created At"
      ];

      final DateFormat dateFormat = DateFormat('dd/MM/yyyy, HH:mm:ss');

      final rows = vendors.map((v) => [
        v.id,
        v.companyName,
        v.email ?? "",
        v.location ?? "",
        v.address ?? "",
        v.contactPerson ?? "",
        v.contactNumber ?? "",
        v.categories.join(" | "),
        v.projects.join(" | "),
        v.createdAt != null ? dateFormat.format(v.createdAt!.toLocal()) : ""
      ]).toList();

      String escapeCsv(String cell) {
        // Enclose in quotes and escape internal quotes by doubling them
        final escapedValue = cell.replaceAll('"', '""');
        return '"$escapedValue"';
      }

      String csv = headers.map(escapeCsv).join(",") + "\n";
      for (var row in rows) {
        csv += row.map((cell) => escapeCsv(cell.toString())).join(",") + "\n";
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'vendors_export_$timestamp.csv';

      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory =
            Platform.isAndroid
                ? await getExternalStorageDirectory() ??
                    await getApplicationDocumentsDirectory()
                : await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csv);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV saved to device'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () {
                  _openExportedFile(path);
                },
              ),
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e')),
        );
      }
    }
  }

  void _showCreateVendorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SubmitVendorDialog(),
    );
  }

  Widget _buildFilters(BuildContext context, VendorProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildDropdown(
                  'All Companies',
                  provider.selectedCompany,
                  provider.uniqueCompanies,
                  (val) => provider.setFilters(
                    company: val,
                    category: provider.selectedCategory,
                    project: provider.selectedProject,
                  ),
                ),
                const SizedBox(width: 8),
                _buildDropdown(
                  'All Categories',
                  provider.selectedCategory,
                  provider.uniqueCategories,
                  (val) => provider.setFilters(
                    company: provider.selectedCompany,
                    category: val,
                    project: provider.selectedProject,
                  ),
                ),
                const SizedBox(width: 8),
                _buildDropdown(
                  'All Projects',
                  provider.selectedProject,
                  provider.uniqueProjects,
                  (val) => provider.setFilters(
                    company: provider.selectedCompany,
                    category: provider.selectedCategory,
                    project: val,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      provider.resetFilters();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10b981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      _exportCSV(context, provider);
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text(
                      'Export CSV',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      _showCreateVendorDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Create Vendor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Future<void> _openExportedFile(String path) async {
    final result = await OpenFilex.open(path);
    final opened = result.type == ResultType.done;

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isNotEmpty ? result.message : 'File saved at: $path',
          ),
        ),
      );
    }
  }

  Widget _buildDropdown(
    String hint,
    String? currentValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final displayValue =
        (currentValue == null || currentValue.isEmpty) ? hint : currentValue;
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => _showSelectionSheet(
                title: hint,
                items: items,
                selectedValue: currentValue,
                onSelected: onChanged,
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayValue,
                        style: TextStyle(
                          color: (currentValue == null || currentValue.isEmpty)
                              ? Colors.grey[600]
                              : const Color(0xFF1E293B),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSelectionSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onSelected,
  }) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final sheetItems = <String?>[null, ...items];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.white24,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sheetItems.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (sheetContext, index) {
                    final item = sheetItems[index];
                    final isSelected = item == selectedValue ||
                        (item == null &&
                            (selectedValue == null || selectedValue.isEmpty));
                    return ListTile(
                      title: Text(
                        item ?? title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    onSelected(selected);
  }

  Widget _buildList(VendorProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return Center(
        child: Text(
          provider.error?.message ?? 'Error loading vendors',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final list = provider.filteredVendors;
    if (list.isEmpty) {
      return const Center(
        child: Text('No vendors found.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final vendor = list[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Company Name & Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vendor.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Action Icons (Eye, Edit - read only for now to match screenshot)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => VendorDetailsDialog(vendor: vendor),
                            );
                          },
                          child: Icon(Icons.remove_red_eye_outlined,
                              color: Colors.blue.shade300, size: 20),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => SubmitVendorDialog(vendor: vendor),
                            );
                          },
                          child: Icon(Icons.edit_outlined,
                              color: Colors.orange.shade300, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                if (vendor.location != null && vendor.location!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vendor.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Categories
                if (vendor.categories.isNotEmpty) ...[
                  const Text(
                    'CATEGORIES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: vendor.categories.map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Projects
                if (vendor.projects.isNotEmpty) ...[
                  const Text(
                    'PROJECTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: vendor.projects.map((proj) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Text(
                          proj,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
