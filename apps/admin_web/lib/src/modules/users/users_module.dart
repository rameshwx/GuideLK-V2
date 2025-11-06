import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/admin_user.dart';
import '../../state/sample_data.dart';
import '../../state/users_controller.dart';
import '../../shared/widgets/section_header.dart';

class UsersModule extends ConsumerStatefulWidget {
  const UsersModule({super.key});

  @override
  ConsumerState<UsersModule> createState() => _UsersModuleState();
}

enum _UserStatusFilter { all, active, inactive }

class _UsersModuleState extends ConsumerState<UsersModule> {
  final TextEditingController _searchController = TextEditingController();
  _UserStatusFilter _status = _UserStatusFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final filtered = users.where(_matchesSearch).where(_matchesStatus).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Users',
          subtitle: 'Search, review, and manage GuideLK travellers.',
          actions: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by name or email',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SegmentedButton<_UserStatusFilter>(
              segments: const [
                ButtonSegment(value: _UserStatusFilter.all, label: Text('All')),
                ButtonSegment(value: _UserStatusFilter.active, label: Text('Active')),
                ButtonSegment(value: _UserStatusFilter.inactive, label: Text('Inactive')),
              ],
              selected: {_status},
              onSelectionChanged: (values) {
                setState(() {
                  _status = values.first;
                });
              },
            ),
            OutlinedButton.icon(
              onPressed: filtered.isEmpty
                  ? null
                  : () {
                      final csv = _exportCsv(filtered);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export prepared — copy from console.')),
                      );
                      // ignore: avoid_print
                      print(csv);
                    },
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export CSV'),
            ),
          ],
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceVariant,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('${filtered.length} users'),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Locale')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (final user in filtered)
                      DataRow(
                        cells: [
                          DataCell(Text(user.displayName)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.locale)),
                          DataCell(Text(formatDate(user.createdAt))),
                          DataCell(
                            Chip(
                              label: Text(user.active ? 'Active' : 'Inactive'),
                              backgroundColor: user.active
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.orange.withOpacity(0.12),
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                color: user.active ? Colors.green.shade800 : Colors.orange.shade800,
                              ),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed: () => ref.read(usersProvider.notifier).toggleActive(user),
                              child: Text(user.active ? 'Deactivate' : 'Reactivate'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _matchesSearch(AdminUser user) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return true;
    }
    return user.displayName.toLowerCase().contains(query) || user.email.toLowerCase().contains(query);
  }

  bool _matchesStatus(AdminUser user) {
    switch (_status) {
      case _UserStatusFilter.all:
        return true;
      case _UserStatusFilter.active:
        return user.active;
      case _UserStatusFilter.inactive:
        return !user.active;
    }
  }

  String _exportCsv(List<AdminUser> users) {
    final header = 'id,name,email,locale,status,created_at';
    final rows = users.map((u) =>
        '${u.id},"${u.displayName}","${u.email}",${u.locale},${u.active ? 'active' : 'inactive'},${formatDate(u.createdAt)}');
    return ([header, ...rows]).join('\n');
  }
}
