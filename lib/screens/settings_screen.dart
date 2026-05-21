import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_finance/providers/app_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Внешний вид',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _ThemeOption(
                  icon: Icons.light_mode_outlined,
                  label: 'Светлая тема',
                  description: 'Всегда светлый интерфейс',
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeModeProvider.notifier).state =
                      ThemeMode.light,
                ),
                const Divider(height: 1, indent: 56),
                _ThemeOption(
                  icon: Icons.dark_mode_outlined,
                  label: 'Тёмная тема',
                  description: 'Всегда тёмный интерфейс',
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).state =
                      ThemeMode.dark,
                ),
                const Divider(height: 1, indent: 56),
                _ThemeOption(
                  icon: Icons.settings_suggest_outlined,
                  label: 'Системная тема',
                  description: 'Следовать настройкам устройства',
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).state =
                      ThemeMode.system,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'О приложении',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('MMM — Monthly Money Metrics'),
                  subtitle: const Text('Версия 1.0.0'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Хранение данных'),
                  subtitle: const Text('Все данные хранятся локально на устройстве'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(description),
      trailing: selected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: onTap,
    );
  }
}
