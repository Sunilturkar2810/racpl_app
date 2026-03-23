import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csv);

        // Trigger native share/download dialog on mobile
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Exported Vendors CSV',
        );
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              child: _buildDropdown(
                'All Companies',
                provider.selectedCompany,
                provider.uniqueCompanies,
                (val) => provider.setFilters(
                  company: val,
                  category: provider.selectedCategory,
                  project: provider.selectedProject,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: _buildDropdown(
                'All Categories',
                provider.selectedCategory,
                provider.uniqueCategories,
                (val) => provider.setFilters(
                  company: provider.selectedCompany,
                  category: val,
                  project: provider.selectedProject,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: _buildDropdown(
                'All Projects',
                provider.selectedProject,
                provider.uniqueProjects,
                (val) => provider.setFilters(
                  company: provider.selectedCompany,
                  category: provider.selectedCategory,
                  project: val,
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                provider.resetFilters();
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Reset'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981), // green similar to the screenshot
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _exportCSV(context, provider);
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export CSV', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6), // blue similar to the screenshot
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _showCreateVendorDialog(context);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Vendor', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String? currentValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    String displayValue = (currentValue == null || currentValue.isEmpty) ? hint : currentValue;
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      onSelected: onChanged,
      constraints: const BoxConstraints(maxHeight: 300),
      itemBuilder: (BuildContext context) {
        final allItems = [null, ...items];
        return allItems.map((String? item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text(
              item ?? hint,
              style: TextStyle(
                color: item == null ? Colors.grey : const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: item == null ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
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
