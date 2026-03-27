import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/project_model.dart';

class ProjectDetailsDialog extends StatelessWidget {
  final Project project;

  const ProjectDetailsDialog({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenSize.width > 820 ? 760 : screenSize.width,
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.92),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildChip(project.status),
                            Text(
                              '#${project.id}',
                              style: TextStyle(
                                color: Colors.blueGrey.shade400,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C2333),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'PROJECT DETAILS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 28),
                    color: const Color(0xFF6B7A90),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Column(
                  children: [
                    _buildSection(
                      title: 'Basic Information',
                      children: [
                        _buildInfoGrid([
                          _InfoItem('CLIENT NAME', _normalize(project.clientName)),
                          _InfoItem('CONTACT NO', _normalize(project.contactNo)),
                          _InfoItem('LOCATION', _normalize(project.location)),
                          _InfoItem('ADDRESS', _normalize(project.address)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _buildSection(
                      title: 'Project Details',
                      children: [
                        _buildInfoGrid([
                          _InfoItem('TEAM LEAD', _normalize(project.teamLead)),
                          _InfoItem('DATE OF APPLICATION', _normalize(project.dateOfApp)),
                          _InfoItem('SURVEY', _normalize(project.survey)),
                          _InfoItem('FAR PURCHASE', _normalize(project.farPurchase)),
                          _InfoItem('REVISED BUILDING PLAN', _normalize(project.revisedBuildingPlan)),
                          _InfoItem('FACTORY ACT CONSULTANT', _normalize(project.factoryActConsultant)),
                          _InfoItem('FIREFIGHTING APPROVAL', _normalize(project.firefightingApproval)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _buildSection(
                      title: 'Building Plan',
                      children: [
                        _buildInfoGrid([
                          _InfoItem('BUILDING PLAN APPROVAL', _normalize(project.buildingPlanApproval)),
                          _InfoItem('BUILDING PLAN REMARK', _normalize(project.buildingPlanRemark)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _buildSection(
                      title: 'Documents',
                      children: [
                        _buildDocumentRow(
                          context,
                          title: 'Award Letter',
                          url: project.awardLetter,
                          remark: project.awardLetterRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'Land Paper / Zoning',
                          url: project.landPaperZoning,
                          remark: project.landPaperZoningRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'Soil Testing',
                          url: project.soilTesting,
                          remark: project.soilTestingRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'Water Testing',
                          url: project.waterTesting,
                          remark: project.waterTestingRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'Plot Demarcation by Govt',
                          url: project.plotDemarcation,
                          remark: project.plotDemarcationRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'DPC Certificate',
                          url: project.dpcCertificate,
                          remark: project.dpcCertificateRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'Fire NOC',
                          url: project.fireNoc,
                          remark: project.fireNocRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'Labour Cess',
                          url: project.labourCess,
                          remark: project.labourCessRemark,
                        ),
                        _buildDocumentRow(
                          context,
                          title: 'Solar Haredan OC',
                          url: project.solarHaredanOc,
                          remark: project.solarHaredanOcRemark,
                          isLast: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2382E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String status) {
    final text = _normalize(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8B4FE)),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF8B5CF6),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E2F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1677FF),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 560 ? 2 : 1;
        final spacing = 18.0;
        final itemWidth =
            columns == 2 ? (constraints.maxWidth - spacing) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          color: Colors.blueGrey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        style: const TextStyle(
                          color: Color(0xFF1C2333),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildDocumentRow(
    BuildContext context, {
    required String title,
    required String url,
    required String remark,
    bool isLast = false,
  }) {
    final hasFile = _hasFile(url);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C2333),
                  ),
                ),
                if (_hasFile(remark))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      remark,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!hasFile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFB6C3)),
              ),
              child: const Text(
                'No File',
                style: TextStyle(
                  color: Color(0xFFFF5D73),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            _buildDocIconButton(
              icon: Icons.open_in_new,
              onTap: () => _openUrl(context, url),
            ),
        ],
      ),
    );
  }

  Widget _buildDocIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF3F0FF),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC7C9FF)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Color(0xFF6C7BFF),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document save hone ke baad view hoga.')),
        );
      }
      return;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open document')),
        );
      }
    }
  }

  bool _hasFile(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;
    const invalidValues = {'n/a', '-', 'null'};
    return !invalidValues.contains(normalized.toLowerCase());
  }

  String _normalize(String value) {
    return _hasFile(value) ? value : '-';
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}
