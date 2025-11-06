import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/settings.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(bookingSettingsProvider);
    _urlController =
        TextEditingController(text: settings.portabilityUrl ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(bookingSettingsProvider);
    final controller = ref.read(bookingSettingsProvider.notifier);

    final expectedUrl = settings.portabilityUrl ?? '';
    if (_urlController.text != expectedUrl) {
      _urlController.text = expectedUrl;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsIntro,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            title: Text(l10n.bookingImportToggle),
            subtitle: Text(l10n.bookingImportDescription),
            value: settings.enabled,
            onChanged: (value) => controller.update(enabled: value),
          ),
          const Divider(),
          Text(l10n.bookingImportScopeHeader,
              style: Theme.of(context).textTheme.titleMedium),
          RadioListTile<BookingPortabilityScope>(
            value: BookingPortabilityScope.dma,
            groupValue: settings.scope,
            onChanged: settings.enabled
                ? (value) => controller.update(scope: value)
                : null,
            title: Text(l10n.scopeOneTime),
            subtitle: Text(l10n.scopeOneTimeDesc),
          ),
          RadioListTile<BookingPortabilityScope>(
            value: BookingPortabilityScope.dmaContinuous,
            groupValue: settings.scope,
            onChanged: settings.enabled
                ? (value) => controller.update(scope: value)
                : null,
            title: Text(l10n.scopeContinuous),
            subtitle: Text(l10n.scopeContinuousDesc),
          ),
          const Divider(),
          TextField(
            controller: _urlController,
            enabled: settings.enabled,
            decoration: InputDecoration(
              labelText: l10n.bookingPortabilityUrlLabel,
              hintText: 'https://account.booking.com/data-portability/...',
            ),
            keyboardType: TextInputType.url,
            minLines: 1,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: settings.enabled
                ? () async {
                    await controller.update(
                      portabilityUrl: _urlController.text.trim().isEmpty
                          ? null
                          : _urlController.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.settingsSavedMessage)),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.saveSettingsCta),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.offlineDataSubtitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.offlineDataDescription),
        ],
      ),
    );
  }
}
