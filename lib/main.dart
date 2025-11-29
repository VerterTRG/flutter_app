import 'package:flutter/material.dart';
import 'package:flutter_app/lib/logic/addresses_cubit.dart';
import 'package:flutter_app/lib/logic/clients_cubit.dart';
import 'package:flutter_app/lib/logic/invoices_cubit.dart';
import 'package:flutter_app/lib/logic/products_cubit.dart';
import 'package:flutter_app/models/client.dart';
import "package:flutter_bloc/flutter_bloc.dart";
// import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets/tab_bar.dart';
import 'widgets/sidebar.dart';
import 'theme.dart';
import "lib/logic/navigation_cubit.dart";

// --- КОНСТАНТЫ РАЗМЕРОВ ---
// Константы перенесены в widgets/tab_bar.dart

void main() {
  // runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => ClientsCubit()),
        BlocProvider(create: (_) => AddressesCubit()),
        BlocProvider(create: (_) => ProductsCubit()),
        BlocProvider(create: (_) => InvoicesCubit()),
      ],
      child: MaterialApp(
        title: 'Multitab App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: mainThemeColor, 
          useMaterial3: true, 
          // brightness: Brightness.dark
        ),
        home: const MainLayout(),
      ),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceBright,
      body: Row(
        children: [
          // 1. SIDEBAR
          SideBar(),

          // 2. MAIN AREA
          Expanded(
            child: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, navState) {
                return Column(
                  children: [
                    // --- TAB BAR AREA ---
                    AppTabBar(state: navState),
                    // --- CONTENT ---
                    Expanded(
                      child: navState.tabs.isEmpty
                          ? Center(child: Text("Выберите пункт в меню", style: TextStyle(color: colors.onSurfaceVariant)))
                          : IndexedStack(
                              index: navState.activeTabIndex,
                              children: navState.tabs.map((t) => t.screen).toList(),
                            ),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}