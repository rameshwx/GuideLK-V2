import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../modules/modules.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({
    required this.module,
    required this.child,
    super.key,
  });

  final AdminModule module;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final modules = AdminModule.values;
    final selectedIndex = modules.indexOf(module);

    return Scaffold(
      appBar: AppBar(
        title: Text('GuideLK Admin — ${module.label}'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'guidelk-d1393',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            destinations: [
              for (final item in modules)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              final target = modules[index];
              if (target == module) {
                return;
              }
              context.go('/${target.pathSegment}');
            },
            labelType: NavigationRailLabelType.all,
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
