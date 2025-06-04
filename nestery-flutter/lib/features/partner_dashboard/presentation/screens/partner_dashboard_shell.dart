import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nestery_flutter/utils/constants.dart';

class PartnerDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PartnerDashboardShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) { // Mobile layout
          return Scaffold(
            appBar: AppBar(
              title: const Text('Partner Dashboard'),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Constants.primaryColor),
                    child: Text('Nestery Partner', style: TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () => _onTap(context, 0)),
                  ListTile(leading: const Icon(Icons.list_alt), title: const Text('Offers'), onTap: () => _onTap(context, 1)),
                  ListTile(leading: const Icon(Icons.link), title: const Text('Links'), onTap: () => _onTap(context, 2)),
                  ListTile(leading: const Icon(Icons.insights), title: const Text('Earnings'), onTap: () => _onTap(context, 3)),
                  ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => _onTap(context, 4)),
                ],
              ),
            ),
            body: navigationShell,
          );
        } else { // Web/Tablet layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) => _onTap(context, index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.list_alt_outlined),
                      selectedIcon: Icon(Icons.list_alt),
                      label: Text('Offers'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.link_outlined),
                      selectedIcon: Icon(Icons.link),
                      label: Text('Links'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Earnings'),
                    ),
                     NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: navigationShell,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
