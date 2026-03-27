import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Project Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF137FEC),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
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
              iconColor: Colors.blue,
              items: statusLevels,
              onChanged: (val) {
                setState(() => _selectedStatusFilter = val);
              },
            ),
            const SizedBox(width: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const CreateProjectDialog(),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          offset: const Offset(0, 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          color: Colors.white,
          elevation: 2,
          padding: EdgeInsets.zero,
          onSelected: onChanged,
          itemBuilder: (context) {
            return items.map((item) {
              final isSelected = item == value;
              return PopupMenuItem<String>(
                value: item,
                padding: EdgeInsets.zero,
                height: 40,
                child: Container(
                  width: double.infinity,
                  color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade400),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: iconColor ?? Colors.blue),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
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
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
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
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
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
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                _buildActionIcon(Icons.remove_red_eye_outlined, Colors.indigo.shade400, () {
                  showDialog(
                    context: context,
                    builder: (_) => ProjectDetailsDialog(project: project),
                  );
                }),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.edit_outlined, Colors.orange.shade400, () {
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
           color: Colors.grey.shade200,
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
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
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
