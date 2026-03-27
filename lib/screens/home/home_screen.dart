import 'package:flutter/material.dart';
import 'package:racpl/theme/app_colors.dart';

import '../features/checklist_list_screen.dart';
import '../features/delegation_list_screen.dart';
import '../features/expense_list_screen.dart';
import '../features/mom_list_screen.dart';
import '../features/project_list_screen.dart';
import '../features/score_list_screen.dart';
import '../features/ticket_list_screen.dart';
import '../features/vendor_list_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/settings_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> _labels = [
    'Dashboard',
    'Score',
    'Delegation',
    'Checklist',
    'MOMS',
    'Project Management',
    'Vendor',
    'Expense',
    'Help Ticket',
    'Profile',
    'Settings',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.trending_up,
    Icons.assignment,
    Icons.checklist,
    Icons.meeting_room,
    Icons.folder,
    Icons.store,
    Icons.receipt,
    Icons.support_agent,
    Icons.person,
    Icons.settings,
  ];

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'More Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
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
              const SizedBox(height: 32),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: _labels.length - 3,
                    itemBuilder: (context, index) {
                      final actualIndex = index + 3;
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = actualIndex);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _icons[actualIndex],
                                color: Theme.of(context).primaryColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _labels[actualIndex],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _buildFeatureScreen(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex >= 3 ? 3 : _selectedIndex,
          onTap: (index) {
            if (index == 3) {
              _showMoreMenu();
            } else {
              setState(() => _selectedIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 12,
          items: [
            BottomNavigationBarItem(icon: Icon(_icons[0]), label: _labels[0]),
            BottomNavigationBarItem(icon: Icon(_icons[1]), label: _labels[1]),
            BottomNavigationBarItem(icon: Icon(_icons[2]), label: _labels[2]),
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ScoreListScreen();
      case 2:
        return const DelegationListScreen();
      case 3:
        return const ChecklistListScreen();
      case 4:
        return const MomListScreen();
      case 5:
        return const ProjectListScreen();
      case 6:
        return const VendorListScreen();
      case 7:
        return const ExpenseListScreen();
      case 8:
        return const TicketListScreen();
      case 9:
        return const ProfileScreen();
      case 10:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }
}
