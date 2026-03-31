import 'package:flutter/material.dart';
import 'package:racpl/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import '../../widgets/create_project_dialog.dart';
import '../../widgets/edit_project_dialog.dart';
import '../../widgets/project_details_dialog.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProjectProvider>().fetchProjects());
  }

  String _selectedProjectFilter = 'All Projects';
  String _selectedStatusFilter = 'Global Status';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Project Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error?.message ?? 'Error loading projects'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchProjects(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<Project> filteredProjects = provider.projects.where((p) {
            bool matchProject = _selectedProjectFilter == 'All Projects' || p.name == _selectedProjectFilter;
            bool matchStatus = _selectedStatusFilter == 'Global Status' || p.status.toUpperCase() == _selectedStatusFilter.toUpperCase();
            return matchProject && matchStatus;
          }).toList();

          return Column(
            children: [
              _buildTopBar(provider),
              Expanded(
                child: filteredProjects.isEmpty
                    ? const Center(child: Text('No projects match the filters'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          return _buildProjectCard(filteredProjects[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(ProjectProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<String> projectNames = ['All Projects'];
    projectNames.addAll(provider.projects.map((p) => p.name).toSet().toList());

    List<String> statusLevels = [
      'Global Status',
      'Award to Start',
      'Running',
      'Provision',
      'Hold',
      'Completed',
      'Cancelled'
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: SizedBox(
        height: 74,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildCustomDropdown(
              label: 'PROJECT NAME',
              value: _selectedProjectFilter,
              icon: Icons.filter_alt_outlined,
              items: projectNames,
              onChanged: (val) {
                setState(() => _selectedProjectFilter = val);
              },
            ),
            const SizedBox(width: 16),
            _buildCustomDropdown(
              label: 'CURRENT STATUS',
              value: _selectedStatusFilter,
              icon: Icons.circle,
              iconColor: AppColors.primary,
              items: statusLevels,
              onChanged: (val) {
                setState(() => _selectedStatusFilter = val);
              },
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreateProjectDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 180,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _showSelectionSheet(
              title: label,
              items: items,
              selectedValue: value,
              onSelected: onChanged,
            ),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151A23) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : AppColors.primary.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: iconColor ?? AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
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
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
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
                  itemCount: items.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                  itemBuilder: (sheetContext, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;
                    return ListTile(
                      title: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.white : Colors.black87),
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

    if (selected != null) {
      onSelected(selected);
    }
  }

  Widget _buildInfoRow(String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$title:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID + Name & Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${project.id}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,

                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (project.address.isNotEmpty && project.address != 'N/A')
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            project.address,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusBadge(project.status),
              ],
            ),
            const SizedBox(height: 10),
            
            // Details Matrix
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Client', project.clientName.replaceAll('\n', ', ')),
                      _buildInfoRow('Contact', project.contactNo.replaceAll('\n', ', ')),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Location', project.location),
                      _buildInfoRow('Lead', project.teamLead),
                    ],
                  ),
                ),
              ],
            ),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionIcon(Icons.remove_red_eye_outlined, AppColors.primary, () {

                  showDialog(
                    context: context,
                    builder: (_) => ProjectDetailsDialog(project: project),
                  );
                }),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.edit_outlined, AppColors.primary, () {
                  showDialog<bool>(
                    context: context,
                    builder: (_) => EditProjectDialog(project: project),
                  ).then((updated) {
                    if (updated == true && context.mounted) {
                      context.read<ProjectProvider>().fetchProjects();
                    }
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    if (status.isEmpty || status == 'N/A') {
       return Container(
         width: 30,
         height: 14,
         decoration: BoxDecoration(
           color: Theme.of(context).brightness == Brightness.dark
               ? Colors.white12
               : Colors.grey.shade200,
           borderRadius: BorderRadius.circular(10),
         ),
       );
    }
    
    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'RUNNING':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'AWARD TO START':
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;

      case 'HOLD':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'COMPLETED':
        bgColor = Colors.teal.shade50;
        textColor = Colors.teal.shade700;
        break;
      case 'CANCELLED':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case 'PROVISION':
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade700;
        break;
      default:
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
