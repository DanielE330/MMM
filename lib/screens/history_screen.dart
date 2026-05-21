import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_finance/models/transaction.dart';
import 'package:my_finance/providers/app_provider.dart';
import 'package:my_finance/screens/add_edit_screen.dart';
import 'package:my_finance/widgets/transaction_card.dart';

enum DateFilter { today, week, month, all }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateFilter _dateFilter = DateFilter.all;
  TransactionType? _typeFilter;

  List<Transaction> _applyFilters(List<Transaction> all) {
    final now = DateTime.now();
    return all.where((t) {
      switch (_dateFilter) {
        case DateFilter.today:
          if (t.date.year != now.year ||
              t.date.month != now.month ||
              t.date.day != now.day) {
            return false;
          }
        case DateFilter.week:
          if (now.difference(t.date).inDays > 7) {
            return false;
          }
        case DateFilter.month:
          if (t.date.year != now.year || t.date.month != now.month) {
            return false;
          }
        case DateFilter.all:
          break;
      }
      if (_typeFilter != null && t.type != _typeFilter) return false;
      return true;
    }).toList();
  }

  String _dateFilterLabel(DateFilter f) => switch (f) {
        DateFilter.today => 'Сегодня',
        DateFilter.week => 'За неделю',
        DateFilter.month => 'За месяц',
        DateFilter.all => 'Все',
      };

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('История'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Фильтры',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (all) {
          final filtered = _applyFilters(all);

          return Column(
            children: [
              // Active filter chips
              if (_dateFilter != DateFilter.all || _typeFilter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_dateFilter != DateFilter.all)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InputChip(
                              label: Text(_dateFilterLabel(_dateFilter)),
                              onDeleted: () =>
                                  setState(() => _dateFilter = DateFilter.all),
                            ),
                          ),
                        if (_typeFilter != null)
                          InputChip(
                            label: Text(_typeFilter == TransactionType.income
                                ? 'Доходы'
                                : 'Расходы'),
                            onDeleted: () => setState(() => _typeFilter = null),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              'Транзакций за выбранный\nпериод не найдено',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.outline),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => TransactionCard(
                          transaction: filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditScreen(transaction: filtered[i]),
                            ),
                          ),
                          onLongPress: () => _showDeleteDialog(filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Период', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: DateFilter.values
                    .map(
                      (f) => ChoiceChip(
                        label: Text(_dateFilterLabel(f)),
                        selected: _dateFilter == f,
                        onSelected: (_) =>
                            setModalState(() => _dateFilter = f),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Тип', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Все'),
                    selected: _typeFilter == null,
                    onSelected: (_) => setModalState(() => _typeFilter = null),
                  ),
                  ChoiceChip(
                    label: const Text('Доходы'),
                    selected: _typeFilter == TransactionType.income,
                    onSelected: (_) => setModalState(
                        () => _typeFilter = TransactionType.income),
                  ),
                  ChoiceChip(
                    label: const Text('Расходы'),
                    selected: _typeFilter == TransactionType.expense,
                    onSelected: (_) => setModalState(
                        () => _typeFilter = TransactionType.expense),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _dateFilter = DateFilter.all;
                          _typeFilter = null;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Сбросить'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: const Text('Применить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Transaction t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить транзакцию?'),
        content: const Text('Вы уверены, что хотите удалить эту транзакцию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(transactionsProvider.notifier).delete(t.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Транзакция удалена')),
                );
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
