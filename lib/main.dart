import 'package:flutter/material.dart';
import 'package:racpl/theme/app_theme.dart';

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
import 'screens/home/home_screen.dart';


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
          update: (_, authService, authProvider) {
            final provider = authProvider ?? AuthProvider();
            provider.setAuthService(authService);
            return provider;
          },
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
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final themeMode = authProvider.currentUser?.theme == 'dark'
              ? ThemeMode.dark
              : ThemeMode.light;

          return MaterialApp(
            title: 'RACPL ERP',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            home: const _AuthWrapper(),
          );
        },
      ),
    );
  }
}

/// Handles auto-login on app start by calling initializeAuth()
class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // initializeAuth reads the stored token and validates it
    await context.read<AuthProvider>().initializeAuth();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Show a branded splash while checking auth
      return const Scaffold(
        backgroundColor: Color(0xFF003366),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business_center, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'RACPL ERP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    return isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
