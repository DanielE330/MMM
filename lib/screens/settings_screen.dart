import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_finance/providers/app_provider.dart';
import 'package:my_finance/services/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SectionLabel('Внешний вид'),
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
          _SectionLabel('Данные'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _ExportTile(
                  icon: Icons.table_rows_outlined,
                  iconColor: Colors.green.shade700,
                  label: 'Экспорт в CSV',
                  description: 'Таблица с разделителями, совместима с любым редактором',
                  onTap: () => _export(context, ref, ExportFormat.csv),
                ),
                const Divider(height: 1, indent: 56),
                _ExportTile(
                  icon: Icons.grid_on_outlined,
                  iconColor: Colors.green.shade600,
                  label: 'Экспорт в Excel',
                  description: 'Файл .xlsx с форматированием заголовков',
                  onTap: () => _export(context, ref, ExportFormat.excel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel('О приложении'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('MMM — Monthly Money Metrics'),
                  subtitle: Text('Версия 1.0.0'),
                ),
                const Divider(height: 1, indent: 56),
                const ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined),
                  title: Text('Хранение данных'),
                  subtitle: Text('Все данные хранятся локально на устройстве'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    final transactions = ref.read(transactionsProvider).valueOrNull;
    if (transactions == null || transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных для экспорта')),
      );
      return;
    }

    try {
      final path = format == ExportFormat.csv
          ? await ExportService.exportCsv(transactions)
          : await ExportService.exportExcel(transactions);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Файл сохранён:\n$path'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e')),
        );
      }
    }
  }
}

enum ExportFormat { csv, excel }

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
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
      leading: Icon(icon, color: selected ? colorScheme.primary : null),
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

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ExportTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label),
      subtitle: Text(description),
      trailing: const Icon(Icons.download_outlined),
      onTap: onTap,
    );
  }
}
