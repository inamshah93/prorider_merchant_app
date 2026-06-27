import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velo_core/velo_core.dart';

import 'providers/app_providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/lifecycle_screen.dart';
import 'screens/login_screen.dart';
import 'screens/smart_booking_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MerchantApp()));
}

class MerchantApp extends ConsumerWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final user = ref.read(authStateProvider).value;
        final loggingIn = state.matchedLocation == '/login';
        if (user == null && !loggingIn) return '/login';
        if (user != null && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (_, __, child) => MerchantShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
            GoRoute(path: '/book', builder: (_, __) => const SmartBookingScreen()),
            GoRoute(
              path: '/orders/:id',
              builder: (_, state) => LifecycleScreen(orderId: int.parse(state.pathParameters['id']!)),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'ShipMate Merchant',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}

class MerchantShell extends StatelessWidget {
  const MerchantShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/');
            case 1:
              context.go('/book');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Book'),
        ],
      ),
    );
  }

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/book')) return 1;
    return 0;
  }
}
