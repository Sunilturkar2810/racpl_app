import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racpl/providers/auth_provider.dart';
import 'package:racpl/services/auth_service.dart';
import 'package:racpl/services/dio_service.dart';
import 'package:racpl/utils/storage_helper.dart';
import 'package:racpl/services/delegation_service.dart';
import 'package:racpl/services/checklist_service.dart';
import 'package:racpl/services/ticket_service.dart';
import 'package:racpl/services/todo_service.dart';
import 'package:racpl/services/mom_service.dart';
import 'package:racpl/services/expense_service.dart';
import 'package:racpl/services/vendor_service.dart';
import 'package:racpl/services/project_service.dart';
import 'package:racpl/services/score_service.dart';
import 'package:racpl/providers/delegation_provider.dart';
import 'package:racpl/providers/checklist_provider.dart';
import 'package:racpl/providers/ticket_provider.dart';
import 'package:racpl/providers/todo_provider.dart';
import 'package:racpl/providers/mom_provider.dart';
import 'package:racpl/providers/expense_provider.dart';
import 'package:racpl/providers/vendor_provider.dart';
import 'package:racpl/providers/project_provider.dart';
import 'package:racpl/providers/score_provider.dart';
import 'package:racpl/providers/dashboard_provider.dart';
import 'package:racpl/providers/help_ticket_config_provider.dart';
import 'package:racpl/services/dashboard_service.dart';
import 'package:racpl/services/help_ticket_config_service.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = StorageHelper();
  await storage.init();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final StorageHelper storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageHelper>(create: (_) => storage),
        Provider<DioService>(create: (_) => DioService(storage: storage)),
        ProxyProvider<DioService, AuthService>(
          update: (_, dioService, __) =>
              AuthService(dioService: dioService, storage: storage),
        ),
        // Auth Provider
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (_) => AuthProvider(),
          update: (_, authService, __) =>
              AuthProvider(authService: authService),
        ),

        // Feature Providers - access DioService from context
        ChangeNotifierProvider<DelegationProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return DelegationProvider(
              delegationService: DelegationService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<ChecklistProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return ChecklistProvider(
              checklistService: ChecklistService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return TicketProvider(
              ticketService: TicketService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<TodoProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return TodoProvider(
              todoService: TodoService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<MomProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return MomProvider(momService: MomService(dioService: dioService));
          },
        ),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return ExpenseProvider(
              expenseService: ExpenseService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<VendorProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return VendorProvider(
              vendorService: VendorService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return DashboardProvider(
              dashboardService: DashboardService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<ProjectProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return ProjectProvider(
              projectService: ProjectService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<ScoreProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return ScoreProvider(
              scoreService: ScoreService(dioService: dioService),
            );
          },
        ),
        ChangeNotifierProvider<HelpTicketConfigProvider>(
          create: (context) {
            final dioService = context.read<DioService>();
            return HelpTicketConfigProvider(
              service: HelpTicketConfigService(dioService: dioService),
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'RACPL ERP',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(
            0xFFF3F4F6,
          ), // Light grey background
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF137FEC), // Primary Blue
            primary: const Color(0xFF137FEC),
            secondary: const Color(0xFF10B981), // Emerald Green
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF137FEC),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF137FEC),
            primary: const Color(0xFF137FEC),
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
      ),
    );
  }
}
