import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        centerTitle: true,
        elevation: 0,
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

          if (provider.projects.isEmpty) {
            return const Center(child: Text('No projects yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return _ProjectCard(project: project);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create project screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planning':
        return Colors.blue;
      case 'in-progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'on-hold':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.folder, color: Colors.blue),
        title: Text(project.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team: ${project.teamMembers.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    project.status,
                    style: TextStyle(
                      color: _getStatusColor(project.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to project detail
        },
      ),
    );
  }
}
