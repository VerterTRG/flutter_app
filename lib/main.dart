import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets/tab_bar.dart';
import 'widgets/sidebar.dart';
import 'theme.dart';

// --- КОНСТАНТЫ РАЗМЕРОВ ---
// Константы перенесены в widgets/tab_bar.dart

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multitab App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: mainThemeColor, 
        useMaterial3: true, 
        // brightness: Brightness.dark
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceBright,
      body: Row(
        children: [
          // 1. SIDEBAR
          SideBar(state: state),

          // 2. MAIN AREA
          Expanded(
            child: Column(
              children: [
                // --- TAB BAR AREA ---
                AppTabBar(colors: colors, state: state),
                // --- CONTENT ---
                Expanded(
                  child: state.tabs.isEmpty
                      ? Center(child: Text("Выберите пункт в меню", style: TextStyle(color: colors.onSurfaceVariant)))
                      : IndexedStack(
                          index: state.activeTabIndex,
                          children: state.tabs.map((t) => t.screen).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}