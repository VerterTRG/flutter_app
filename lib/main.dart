import 'package:flutter/material.dart';
import 'package:flutter_app/models.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'screens.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multitab App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: Row(
        children: [
          // 1. SIDEBAR (Боковое меню)
          NavigationRail(
            selectedIndex:
                null, // Мы не подсвечиваем меню, так как активны ТАБЫ
            onDestinationSelected: (index) {
              final state = context.read<AppState>();
              switch (index) {
                case 0:
                  state.openTab(TabType.dashboard);
                  break;
                case 1:
                  state.openTab(TabType.clients);
                  break;
                case 2:
                  state.openTab(TabType.addresses);
                  break;
                case 3:
                  state.openTab(TabType.products);
                  break;
                case 4:
                  state.openTab(TabType.invoices);
                  break;
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              // Используем данные из Config, а не хардкод
              NavigationRailDestination(
                icon: Icon(TabConfig.icon(TabType.dashboard)),
                label: Text(TabConfig.title(TabType.dashboard)),
              ),
              NavigationRailDestination(
                icon: Icon(TabConfig.icon(TabType.clients)),
                label: Text(TabConfig.title(TabType.clients)),
              ),
              NavigationRailDestination(
                icon: Icon(TabConfig.icon(TabType.addresses)),
                label: Text(TabConfig.title(TabType.addresses)),
              ),
              NavigationRailDestination(
                icon: Icon(TabConfig.icon(TabType.products)),
                label: Text(TabConfig.title(TabType.products)),
              ),
              NavigationRailDestination(
                icon: Icon(TabConfig.icon(TabType.invoices)),
                label: Text(TabConfig.title(TabType.invoices)),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // 2. MAIN AREA (Табы + Контент)
          Expanded(
            child: Column(
              children: [
                // --- TAB BAR (Полоса вкладок) ---
                Container(
                  height: 40,
                  color: Colors.grey[200],
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.tabs.length,
                    itemBuilder: (ctx, index) {
                      final tab = state.tabs[index];
                      final isActive = index == state.activeTabIndex;

                      return InkWell(
                        onTap: () => state.setActiveTab(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.transparent,
                            border: const Border(
                              right: BorderSide(color: Colors.grey, width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                tab.icon,
                                size: 16,
                                color: isActive ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tab.title,
                                style: TextStyle(
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Кнопка закрытия (X)
                              IconButton(
                                icon: const Icon(Icons.close, size: 14),
                                onPressed: () => state.closeTab(index),
                                padding: EdgeInsets.zero,
                                constraints:
                                    const BoxConstraints(), // убираем отступы
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),

                // --- CONTENT (Сам экран) ---
                Expanded(
                  // IndexedStack хранит состояние всех открытых экранов "живым"
                  child: state.tabs.isEmpty
                      ? const Center(child: Text("Выберите пункт в меню"))
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
