import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ticket_model.dart';
import 'create_ticket_screen.dart';
import 'package:intl/intl.dart';
import '../../services/dio_service.dart';
import '../../widgets/ticket_detail_dialog.dart';
import '../../widgets/ticket_history_dialog.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      if (mounted) {
        context.read<TicketProvider>().fetchTickets();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Help Tickets'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Assigned to Me'),
            Tab(text: 'Raised by Me'),
          ],
        ),
      ),
      body: Consumer2<TicketProvider, AuthProvider>(
        builder: (context, ticketProvider, authProvider, _) {
          if (ticketProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ticketProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ticketProvider.error?.message ?? 'Error loading tickets',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ticketProvider.fetchTickets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final currentUser = authProvider.currentUser;
          final allTickets = ticketProvider.tickets;

          final assignedToMe = allTickets
              .where((t) => t.assignedToId == currentUser?.id)
              .toList();
          final raisedByMe = allTickets
              .where((t) => t.createdById == currentUser?.id)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTicketView(assignedToMe, 'Assigned to Me'),
              _buildTicketView(raisedByMe, 'Raised by Me'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateTicketDialog(),
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Raise New Ticket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTicketView(List<HelpTicket> tickets, String tabType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 20,
                    color: isDark ? Colors.blue[300] : Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Active Tickets',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  '${tickets.length} TOTAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: tickets.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      return _TicketCard(ticket: tickets[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Tickets Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'You haven\'t raised any tickets yet. Click "Raise New Ticket" to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final HelpTicket ticket;

  const _TicketCard({required this.ticket});

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityBgColor(String priority, bool isDark) {
    switch (priority.toLowerCase()) {
      case 'high':
        return isDark ? Colors.red.withAlpha(50) : Colors.red[50]!;
      case 'medium':
        return isDark ? Colors.orange.withAlpha(50) : Colors.orange[50]!;
      case 'low':
        return isDark ? Colors.green.withAlpha(50) : Colors.green[50]!;
      default:
        return isDark ? Colors.grey.withAlpha(50) : Colors.grey[100]!;
    }
  }

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 0; // RAISED
      case 'in-progress':
        return 2; // SOLVING
      case 'closed':
        return 4; // CLOSED
      default:
        return 0;
    }
  }

  String _getTicketDisplayId() {
    final datePart = DateFormat('yyyyMMdd').format(ticket.createdAt);
    final idPart = ticket.id.toString().padLeft(4, '0');
    return '#HT-$datePart-$idPart';
  }

  Future<void> _viewTicketDetails(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dioService = context.read<DioService>();
      final response = await dioService.get(
        '/help-tickets/${ticket.id}',
        fromJson: (data) => data,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      // The backend usually returns the ticket object directly, or wrapped in a data field.
      // If it's a map, pass it. If it has a data field, use that.
      Map<String, dynamic> ticketData;
      if (response is Map<String, dynamic>) {
        ticketData = response.containsKey('data') ? response['data'] : response;
      } else if (response is List && response.isNotEmpty) {
        ticketData = response[0] as Map<String, dynamic>;
      } else {
        ticketData = {'id': ticket.id, 'title': ticket.title}; // fallback
      }

      showDialog(
        context: context,
        builder: (context) => TicketDetailDialog(ticketData: ticketData),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ticket details: $e')),
      );
    }
  }

  Future<void> _viewTicketHistory(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dioService = context.read<DioService>();
      final response = await dioService.get(
        '/help-tickets/history/${ticket.id}',
        fromJson: (data) => data,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      List<dynamic> historyData = [];
      if (response != null && response is Map && response.containsKey('data')) {
        historyData = response['data'] as List<dynamic>;
      } else if (response is List) {
        historyData = response;
      }

      showDialog(
        context: context,
        builder: (context) => TicketHistoryDialog(
          ticketId: ticket.id,
          ticketDisplayId: _getTicketDisplayId(),
          historyData: historyData,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ticket history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int currentStep = _getStatusStepIndex(ticket.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      elevation: 0,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: ID, Priority, Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _getTicketDisplayId(),
                        style: TextStyle(
                          color: isDark
                              ? Colors.blue[400]
                              : const Color(0xFF0066FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityBgColor(ticket.priority, isDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ticket.priority.toUpperCase(),
                          style: TextStyle(
                            color: _getPriorityColor(ticket.priority),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(ticket.createdAt),
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title and Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.category.isEmpty ? 'General' : ticket.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Timeline Stepper
            _buildStepperRow(currentStep, isDark),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Personnel Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RAISED BY',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.createdByName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOLVER',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.assignedToName ?? 'Unassigned',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  'View Details',
                  () => _viewTicketDetails(context),
                  isDark,
                ),
                _buildActionButton(
                  'View History',
                  () => _viewTicketHistory(context),
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStepperRow(int currentStep, bool isDark) {
    final steps = ['RAISED', 'PLANNING', 'SOLVING', 'CONFIRMATION', 'CLOSED'];
    final icons = [
      Icons.campaign_outlined,
      Icons.event_outlined,
      Icons.build_outlined,
      Icons.verified_outlined,
      Icons.check_circle_outline,
    ];

    List<Widget> children = [];

    for (int i = 0; i < steps.length; i++) {
      final isCompleted = i <= currentStep;
      final isActive = i == currentStep;

      children.add(
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF0066FF)
                      : (isDark ? Colors.grey[800] : Colors.white),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF0066FF)
                        : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isActive ? Icons.check : icons[i],
                  size: 20,
                  color: isCompleted
                      ? Colors.white
                      : (isDark ? Colors.grey[400] : Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF0066FF)
                        : (isDark ? Colors.grey[400] : Colors.grey[500]),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (i < steps.length - 1) {
        final isLineCompleted = i < currentStep;
        children.add(
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20), // align with circles
              height: 2,
              color: isLineCompleted
                  ? const Color(0xFF0066FF)
                  : (isDark ? Colors.grey[700] : Colors.grey[200]),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
