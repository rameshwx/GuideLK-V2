import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'modules/modules.dart';
import 'shared/layout/admin_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/users',
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/users',
      ),
      for (final module in AdminModule.values)
        GoRoute(
          path: '/${module.pathSegment}',
          pageBuilder: (context, state) => NoTransitionPage(
            child: AdminScaffold(
              module: module,
              child: module.build(),
            ),
          ),
        ),
    ],
    errorPageBuilder: (context, state) => NoTransitionPage(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(state.error.toString()),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/users'),
                child: const Text('Back to users'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
