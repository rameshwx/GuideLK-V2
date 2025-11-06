import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/feature_flag_controller.dart';
import '../../state/system_settings_controller.dart';
import '../../shared/widgets/section_header.dart';

class SystemModule extends ConsumerStatefulWidget {
  const SystemModule({super.key});

  @override
  ConsumerState<SystemModule> createState() => _SystemModuleState();
}

class _SystemModuleState extends ConsumerState<SystemModule> {
  late TextEditingController _tilesController;
  late TextEditingController _mediaController;
  late TextEditingController _uploadController;
  final TextEditingController _extensionController = TextEditingController();
  late List<String> _extensions;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(systemSettingsProvider);
    _tilesController = TextEditingController(text: settings.adminTilesUrl);
    _mediaController = TextEditingController(text: settings.mediaBaseUrl);
    _uploadController = TextEditingController(text: settings.maxUploadSizeMb.toString());
    _extensions = List<String>.from(settings.allowedExtensions);
    ref.listen(systemSettingsProvider, (_, next) {
      if (!mounted) return;
      setState(() {
        _tilesController.value = TextEditingValue(text: next.adminTilesUrl);
        _mediaController.value = TextEditingValue(text: next.mediaBaseUrl);
        _uploadController.value = TextEditingValue(text: next.maxUploadSizeMb.toString());
        _extensions = List<String>.from(next.allowedExtensions);
      });
    });
  }

  @override
  void dispose() {
    _tilesController.dispose();
    _mediaController.dispose();
    _uploadController.dispose();
    _extensionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featureFlags = ref.watch(featureFlagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'System settings',
          subtitle: 'Configure hosting integration, uploads, and feature flags.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hosting & media', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _tilesController,
                            decoration: const InputDecoration(
                              labelText: 'Admin tiles URL',
                              helperText: 'XYZ raster endpoint for flutter_map web admin.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _mediaController,
                            decoration: const InputDecoration(
                              labelText: 'Media base URL',
                              helperText: 'Public path where uploads are served.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _uploadController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max upload size (MB)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Allowed extensions',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final ext in _extensions)
                                InputChip(
                                  label: Text(ext.toUpperCase()),
                                  onDeleted: () {
                                    setState(() {
                                      _extensions.remove(ext);
                                    });
                                  },
                                ),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _extensionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Add ext',
                                  ),
                                  onSubmitted: (value) {
                                    final cleaned = value.trim().toLowerCase();
                                    if (cleaned.isEmpty) return;
                                    if (_extensions.contains(cleaned)) {
                                      _extensionController.clear();
                                      return;
                                    }
                                    setState(() {
                                      _extensions.add(cleaned);
                                    });
                                    _extensionController.clear();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _persistSystemSettings,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save settings'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Feature flags', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          for (final flag in featureFlags) ...[
                            SwitchListTile.adaptive(
                              value: flag.enabled,
                              onChanged: (_) => ref.read(featureFlagsProvider.notifier).toggle(flag),
                              title: Text(flag.label),
                              subtitle: Text(flag.description),
                            ),
                            const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _persistSystemSettings() {
    final upload = int.tryParse(_uploadController.text.trim());
    if (upload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload size must be a number.')),
      );
      return;
    }
    final notifier = ref.read(systemSettingsProvider.notifier);
    notifier.updateTilesUrl(_tilesController.text.trim());
    notifier.updateMediaBaseUrl(_mediaController.text.trim());
    notifier.updateMaxUploadSize(upload);
    notifier.updateAllowedExtensions(_extensions);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System settings saved')),
    );
  }
}
