import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../features/delegation_list_screen.dart';
import '../features/checklist_list_screen.dart';
import '../features/ticket_list_screen.dart';
import '../features/mom_list_screen.dart';
import '../features/expense_list_screen.dart';
import '../features/vendor_list_screen.dart';
import '../features/project_list_screen.dart';
import '../features/score_list_screen.dart';
import '../profile/profile_screen.dart';

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
    'Projects',
    'Vendor',
    'Expense',
    'Help Ticket',
    'Profile',
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
  ];

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'More Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _labels.length - 3, // Remaining items after first 3
                  itemBuilder: (context, index) {
                    final actualIndex = index + 3;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedIndex = actualIndex);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_icons[actualIndex], color: Theme.of(context).primaryColor),
                          const SizedBox(height: 4),
                          Text(
                            _labels[actualIndex],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
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
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(_icons[0]), label: _labels[0]),
            BottomNavigationBarItem(icon: Icon(_icons[1]), label: _labels[1]),
            BottomNavigationBarItem(icon: Icon(_icons[2]), label: _labels[2]),
            const BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
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
      default:
        return const DashboardScreen();
    }
  }
}
