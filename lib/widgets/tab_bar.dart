import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/logic/navigation_cubit.dart';
import '../models/tab_config.dart';
import '../theme.dart';

// --- КОНСТАНТЫ РАЗМЕРОВ ---
const double kMinTabWidth = 120.0; // Минимальная ширина (включается скролл)
const double kMaxTabWidth = 250.0; // Максимальная ширина (если места много)
const double kTabBarHeight = 40.0; // Высота шапки

class AppTabBar extends StatefulWidget {
  const AppTabBar({
    super.key,
    required this.state,
  });

  final NavigationState state;

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {
  // Контроллер для управления скроллом программно
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: kTabBarHeight,
      color: colors.surfaceContainer, // Исправлено: widget.colors -> colors
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tabsCount = widget.state.tabs.length;
              if (tabsCount == 0) return const SizedBox();

              // Расчет ширины
              double tabWidth = constraints.maxWidth / tabsCount;
              tabWidth = tabWidth.clamp(kMinTabWidth, kMaxTabWidth);

              // Listener для перехвата колесика мыши
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
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(widget.state.tabs.length, (index) {
                        final tab = widget.state.tabs[index];
                        final isActive = index == widget.state.activeTabIndex;
                        // Проверка: Это Dashboard?
                        final isPinned = tab.id == TabType.dashboard.name;

                        return InkWell(
                          // Исправлено: вызываем метод Cubit через context.read
                          onTap: () => context.read<NavigationCubit>().setActiveTab(index),
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
                                if (!isPinned) ...[
                                  const SizedBox(width: 4),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      // Исправлено: вызываем метод Cubit через context.read
                                      onTap: () => context.read<NavigationCubit>().closeTab(index),
                                      child: Icon(Icons.close, size: 16, color: colors.onSurfaceVariant),
                                    ),
                                  )
                                ],
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
    );
  }
}
