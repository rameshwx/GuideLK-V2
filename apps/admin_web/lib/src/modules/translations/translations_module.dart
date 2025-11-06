import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/translation_entry.dart';
import '../../state/translation_controller.dart';
import '../../shared/widgets/section_header.dart';

class TranslationsModule extends ConsumerStatefulWidget {
  const TranslationsModule({super.key});

  @override
  ConsumerState<TranslationsModule> createState() => _TranslationsModuleState();
}

class _TranslationsModuleState extends ConsumerState<TranslationsModule> {
  static const supportedLocales = ['en', 'ta', 'zh', 'ru', 'hi', 'pl'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = ref.watch(translationsProvider);
    final filtered = translations.where((entry) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      return entry.key.toLowerCase().contains(query) ||
          entry.values.values.any((value) => value.toLowerCase().contains(query));
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Translations',
          subtitle: 'Manage localized strings across supported locales.',
          actions: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search keys or values',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _openDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add key'),
            ),
          ],
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${filtered.length} strings configured',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return ListTile(
                      title: Text(entry.key, style: const TextStyle(fontFamily: 'monospace')),
                      subtitle: Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          for (final locale in supportedLocales)
                            Chip(
                              label: Text('${locale.toUpperCase()}: ${entry.values[locale] ?? ''}'),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit translations',
                        onPressed: () => _openDialog(context, existing: entry),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openDialog(BuildContext context, {TranslationEntry? existing}) async {
    final formKey = GlobalKey<FormState>();
    final keyController = TextEditingController(text: existing?.key ?? '');
    final Map<String, TextEditingController> controllers = {
      for (final locale in supportedLocales)
        locale: TextEditingController(text: existing?.values[locale] ?? ''),
    };

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Add translation key' : 'Edit translation key'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: keyController,
                      decoration: const InputDecoration(labelText: 'Key (e.g. home.title)'),
                      validator: (value) => value == null || value.isEmpty ? 'Key required' : null,
                      readOnly: existing != null,
                    ),
                    const SizedBox(height: 12),
                    for (final locale in supportedLocales)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: controllers[locale],
                          decoration: InputDecoration(
                            labelText: '${locale.toUpperCase()} value',
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final values = {
                    for (final locale in supportedLocales)
                      locale: controllers[locale]!.text.trim(),
                  };
                  ref.read(translationsProvider.notifier).upsertEntry(
                        TranslationEntry(key: keyController.text.trim(), values: values),
                      );
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Translation added' : 'Translation updated')),
      );
    }
  }
}
