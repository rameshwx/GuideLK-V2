import 'package:flutter/material.dart';

import 'dashboard.dart';

class GuideLkAdminApp extends StatelessWidget {
  const GuideLkAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuideLK Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185B8C)),
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}
