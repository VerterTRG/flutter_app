import 'package:flutter/material.dart';
import 'package:flutter_app/lib/logic/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/tab_config.dart';

class SideBar extends StatelessWidget {
  const SideBar({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        NavigationRail(
          selectedIndex: null,
          onDestinationSelected: (index) {
            final nav = context.read<NavigationCubit>();
            switch (index) {
              case 0: nav.openTab(TabType.dashboard); break;
              case 1: nav.openTab(TabType.clients); break;
              case 2: nav.openTab(TabType.addresses); break;
              case 3: nav.openTab(TabType.products); break;
              case 4: nav.openTab(TabType.invoices); break;
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
