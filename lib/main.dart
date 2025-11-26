import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'state.dart';   
import 'screens.dart'; 

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()));
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(path: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/clients', builder: (context, state) => const ClientsScreen()),
        GoRoute(path: '/addresses', builder: (context, state) => const AddressesScreen()),
        GoRoute(path: '/products', builder: (context, state) => const ProductsScreen()),
        GoRoute(path: '/invoices', builder: (context, state) => const InvoicesScreen()),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router, theme: ThemeData(useMaterial3: true));
  }
}

class MainShell extends StatelessWidget {
  final Widget child; final String path;
  const MainShell({super.key, required this.child, required this.path});

  @override
  Widget build(BuildContext context) {
    // 1. Вычисляем активный индекс на основе URL
    int idx = 0;
    if (path.startsWith('/clients')) idx = 1;
    if (path.startsWith('/addresses')) idx = 2;
    if (path.startsWith('/products')) idx = 3;
    if (path.startsWith('/invoices')) idx = 4;

    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: idx,
          // 2. ИСПРАВЛЕНИЕ: Используем switch для четкого выбора действия
          onDestinationSelected: (index) {
            switch (index) {
              case 0: context.go('/dashboard'); break;
              case 1: context.go('/clients'); break;
              case 2: context.go('/addresses'); break;
              case 3: context.go('/products'); break;
              case 4: context.go('/invoices'); break;
            }
          },
          labelType: NavigationRailLabelType.all,
          destinations: const [
             NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dash')),
             NavigationRailDestination(icon: Icon(Icons.people), label: Text('Clients')),
             NavigationRailDestination(icon: Icon(Icons.map), label: Text('Address')),
             NavigationRailDestination(icon: Icon(Icons.inventory), label: Text('Products')),
             NavigationRailDestination(icon: Icon(Icons.receipt), label: Text('Invoices')),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: child),
      ]),
    );
  }
}
