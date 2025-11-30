import 'package:flutter/material.dart';
import 'package:flutter_app/core/module_registry.dart';
import 'package:flutter_app/logic/addresses_cubit.dart';
import 'package:flutter_app/logic/clients_cubit.dart';
import 'package:flutter_app/logic/invoices_cubit.dart';
import 'package:flutter_app/logic/products_cubit.dart';
import 'package:flutter_app/modules/addresses/addresses_module.dart';
import 'package:flutter_app/modules/addresses/create_address_module.dart';
import 'package:flutter_app/modules/clients/clients_module.dart';
import 'package:flutter_app/modules/clients/create_client_module.dart';
import 'package:flutter_app/modules/dashboard_module.dart';
import 'package:flutter_app/modules/invoices_module.dart';
import 'package:flutter_app/modules/products_module.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'widgets/tab_bar.dart';
import 'widgets/sidebar.dart';
import 'theme.dart';
import "logic/navigation_cubit.dart";

// --- КОНСТАНТЫ РАЗМЕРОВ ---
// Константы перенесены в widgets/tab_bar.dart

void main() {
  // runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()));
  // 1. РЕГИСТРАЦИЯ МОДУЛЕЙ
  // Если завтра добавишь "Склад", просто допиши одну строчку тут.
  ModuleRegistry.register(DashboardModule());
  ModuleRegistry.register(ClientsModule());
  ModuleRegistry.register(AddressesModule());
  ModuleRegistry.register(ProductsModule());
  ModuleRegistry.register(InvoicesModule());
  ModuleRegistry.register(CreateClientModule());
  ModuleRegistry.register(CreateAddressModule());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()..init()),
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