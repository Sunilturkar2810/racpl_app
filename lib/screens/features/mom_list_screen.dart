import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racpl/theme/app_colors.dart';
import '../../providers/mom_provider.dart';
import '../../models/mom_model.dart';
import 'mom/create_mom_screen.dart';
import 'mom/mom_details_dialog.dart';
import 'dart:developer' as developer;

class MomListScreen extends StatefulWidget {
  const MomListScreen({super.key});

  @override
  State<MomListScreen> createState() => _MomListScreenState();
}

class _MomListScreenState extends State<MomListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MomProvider>().fetchMeetings());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('MOM Management'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMomScreen()),
          );
          if (context.mounted) {
            context.read<MomProvider>().fetchMeetings();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Create MOM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<MomProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error?.message ?? 'Error loading meetings'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchMeetings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final moms = provider.meetings;

          if (moms.isEmpty) {
            return const Center(child: Text('No meetings yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: moms.length,
            itemBuilder: (context, index) {
              return _buildMomCard(context, moms[index], isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildMomCard(BuildContext context, Mom mom, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: momId (Left) | date (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mom.momId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  mom.date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Second Row: Project Name
            Row(
              children: [
                const Text(
                  'Project:',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mom.project,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Third Row: Info point badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${mom.minutes.length} Points',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Bottom Row: Actions (Right-aligned)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => MomDetailsDialog(mom: mom),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateMomScreen(momToEdit: mom),
                      ),
                    ).then((_) {
                      // Fetch meetings again when we return in case of edits
                      context.read<MomProvider>().fetchMeetings();
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
