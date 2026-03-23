import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vendor_model.dart';

class VendorDetailsDialog extends StatelessWidget {
  final Vendor vendor;

  const VendorDetailsDialog({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
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
                      const Text(
                        'Vendor Details',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VENDOR-${vendor.id}${vendor.companyName.isNotEmpty ? ' • ${vendor.companyName.toUpperCase()}' : ''}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B7280)), // matching grayish/indigo
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200, thickness: 1),
            const SizedBox(height: 8),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(
                      'COMPANY NAME',
                      vendor.companyName.isNotEmpty ? vendor.companyName : '-',
                      'EMAIL',
                      vendor.email?.isNotEmpty == true ? vendor.email! : '-',
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      'LOCATION',
                      vendor.location?.isNotEmpty == true ? vendor.location! : '-',
                      'ADDRESS',
                      vendor.address?.isNotEmpty == true ? vendor.address! : '-',
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard('Contact Person', [
                      _buildKeyValue(
                          'NAME',
                          vendor.contactPerson?.isNotEmpty == true
                              ? vendor.contactPerson!
                              : '-'),
                      _buildKeyValue(
                          'PHONE',
                          vendor.contactNumber?.isNotEmpty == true
                              ? vendor.contactNumber!
                              : '-'),
                    ]),
                    _buildSectionCard('Vendor Profile', [
                      _buildKeyValue(
                          'PROFILE NAME',
                          vendor.profileName?.isNotEmpty == true
                              ? vendor.profileName!
                              : '-'),
                      _buildKeyValue(
                          'SUGGESTED BY',
                          vendor.suggestedBy?.isNotEmpty == true
                              ? vendor.suggestedBy!
                              : '-'),
                      _buildKeyValue('DOCUMENT TYPE',
                          vendor.profileDocType?.isNotEmpty == true
                              ? vendor.profileDocType!
                              : '-'),
                    ]),
                    if (vendor.categories.isNotEmpty)
                      _buildBoxedCard(
                        'Categories',
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: vendor.categories.map((c) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (vendor.subCategories.isNotEmpty)
                      _buildBoxedCard(
                        'Sub Categories',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vendor.subCategories.map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  Expanded(
                                      child: Text(c,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (vendor.projects.isNotEmpty)
                      _buildBoxedCard(
                        'Projects Assigned',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vendor.projects.asMap().entries.map((req) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('${req.key + 1}. ${req.value}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87)),
                            );
                          }).toList(),
                        ),
                      ),
                    _buildSectionCard('Online Links', [
                      _buildKeyValue('WEBSITE',
                          vendor.websiteUrl?.isNotEmpty == true
                              ? vendor.websiteUrl!
                              : '-'),
                      _buildKeyValue('LINKEDIN',
                          vendor.linkedinUrl?.isNotEmpty == true
                              ? vendor.linkedinUrl!
                              : '-'),
                    ]),
                    _buildBoxedCard(
                      'Profile Document',
                      vendor.profileDocValue?.isNotEmpty == true
                          ? InkWell(
                              onTap: () => _launchURL(vendor.profileDocValue!),
                              child: const Row(
                                children: [
                                  Text('View Uploaded Document',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  SizedBox(width: 6),
                                  Icon(Icons.attachment,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                            )
                          : const Text('No Document Uploaded',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                    _buildSectionCard('Created At', [
                      Text(
                        vendor.createdAt != null
                            ? DateFormat('dd/MM/yyyy, HH:mm:ss')
                                .format(vendor.createdAt!)
                            : '-',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ], isDate: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Footer Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label1, String value1, String label2, String value2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildKeyValue(label1, value1)),
        Expanded(child: _buildKeyValue(label2, value2)),
      ],
    );
  }

  Widget _buildKeyValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children, {bool isDate = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDate ? Colors.grey : Colors.blue.shade600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBoxedCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600)),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch \$url');
      }
    }
  }
}
