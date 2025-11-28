import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'screens.dart';
import 'models.dart';

// --- КОНСТАНТЫ РАЗМЕРОВ ---
const double kMinTabWidth = 120.0; // Минимальная ширина (включается скролл)
const double kMaxTabWidth = 250.0; // Максимальная ширина (если места много)
const double kTabBarHeight = 40.0; // Высота шапки

const Color mainThemeColor = Colors.blueAccent;

extension ExtendedThemeData on ColorScheme {
  Color get primaryBase => mainThemeColor;
}

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

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Контроллер для управления скроллом программно
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceBright,
      body: Row(
        children: [
          // 1. SIDEBAR
          NavigationRail(
            selectedIndex: null,
            onDestinationSelected: (index) {
              switch (index) {
                case 0: state.openTab(TabType.dashboard); break;
                case 1: state.openTab(TabType.clients); break;
                case 2: state.openTab(TabType.addresses); break;
                case 3: state.openTab(TabType.products); break;
                case 4: state.openTab(TabType.invoices); break;
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(icon: Icon(TabConfig.icon(TabType.dashboard)), label: Text(TabConfig.title(TabType.dashboard))),
              NavigationRailDestination(icon: Icon(TabConfig.icon(TabType.clients)), label: Text(TabConfig.title(TabType.clients))),
              NavigationRailDestination(icon: Icon(TabConfig.icon(TabType.addresses)), label: Text(TabConfig.title(TabType.addresses))),
              NavigationRailDestination(icon: Icon(TabConfig.icon(TabType.products)), label: Text(TabConfig.title(TabType.products))),
              NavigationRailDestination(icon: Icon(TabConfig.icon(TabType.invoices)), label: Text(TabConfig.title(TabType.invoices))),
            ],
          ),
          VerticalDivider(thickness: 0, width: 1, color: colors.secondary,),

          // 2. MAIN AREA
          Expanded(
            child: Column(
              children: [
                // --- TAB BAR AREA ---
                Container(
                  height: kTabBarHeight,
                  color: colors.surfaceContainer,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final tabsCount = state.tabs.length;
                          if (tabsCount == 0) return const SizedBox();
                      
                          // Расчет ширины
                          double tabWidth = constraints.maxWidth / tabsCount;
                          tabWidth = tabWidth.clamp(kMinTabWidth, kMaxTabWidth);
                      
                          // ! ИСПРАВЛЕНИЕ: Listener для перехвата колесика мыши
                          return Listener(
                            onPointerSignal: (event) {
                              if (event is PointerScrollEvent) {
                                // Перенаправляем вертикальный скролл (dy) в горизонтальный
                                final newOffset = _scrollController.offset + event.scrollDelta.dy;
                                if (_scrollController.hasClients) {
                                  _scrollController.jumpTo(
                                    newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
                                  );
                                }
                              }
                            },
                            child: Scrollbar(
                              controller: _scrollController,
                              thumbVisibility: false, // Всегда показывать ползунок при скролле
                              trackVisibility: false,
                              thickness: 0, // Толщина скроллбара
                              child: SingleChildScrollView(
                                controller: _scrollController, // Подключаем контроллер
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(), 
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(state.tabs.length, (index) {
                                    final tab = state.tabs[index];
                                    final isActive = index == state.activeTabIndex;
                                    // Проверка: Это Dashboard?
                                    final isPinned = tab.id == TabType.dashboard.name;
                      
                                    return InkWell(
                                      onTap: () => state.setActiveTab(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOut,
                                        width: tabWidth,
                                        height: kTabBarHeight,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          // color: isActive ? colors.surface : Colors.transparent,
                                          color: isActive ? colors.surfaceContainerLowest : colors.surface,
                                          border: isActive 
                                            ? Border(
                                            top: BorderSide(color: colors.primaryBase, width: 3), 
                                            right: BorderSide(color: colors.outlineVariant, width: 0.5),
                                            // left: BorderSide(color: colors.outlineVariant, width: 0.5),
                                            )
                                            : Border(right: BorderSide(color: colors.outlineVariant, width: 0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(tab.icon, size: 16, color: isActive ? colors.primaryBase : colors.onSurfaceVariant),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                tab.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                                  color: isActive ? colors.onSurface : colors.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                            if (!isPinned) ...[const SizedBox(width: 4),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () => state.closeTab(index),
                                                child: Icon(Icons.close, size: 16, color: colors.onSurfaceVariant),
                                              ),
                                            )],
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: const Divider(height: 1, thickness: 1),
                      ),
                    ],
                  ),
                ),
                
                // const Divider(height: 1, thickness: 1),

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