import 'package:flutter/material.dart';
import '../models/tab_config.dart';
import '../state.dart';

class SideBar extends StatelessWidget {
  const SideBar({
    super.key,
    required this.state,
  });

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
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
        VerticalDivider(thickness: 0, width: 1, color: colors.secondary),
      ],
    );
  }
}
