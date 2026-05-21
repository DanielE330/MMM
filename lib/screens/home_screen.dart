import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:my_finance/models/transaction.dart';
import 'package:my_finance/providers/app_provider.dart';
import 'package:my_finance/screens/add_edit_screen.dart';
import 'package:my_finance/widgets/transaction_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MMM',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final now = DateTime.now();
          final thisMonth = transactions
              .where(
                (t) => t.date.year == now.year && t.date.month == now.month,
              )
              .toList();

          final income = thisMonth
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + t.amount);
          final expense = thisMonth
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, t) => sum + t.amount);
          final balance = income - expense;

          final recent = transactions.take(5).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              const SizedBox(height: 8),
              // Balance card
              Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Баланс за ${_monthName(now.month)}',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        NumberFormat.currency(
                          locale: 'ru',
                          symbol: '₽',
                        ).format(balance),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryItem(
                              label: 'Доходы',
                              amount: income,
                              color: Colors.green,
                              icon: Icons.arrow_circle_up_outlined,
                              onBackground: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryItem(
                              label: 'Расходы',
                              amount: expense,
                              color: Colors.red,
                              icon: Icons.arrow_circle_down_outlined,
                              onBackground: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (recent.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Последние транзакции',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Всего: ${transactions.length}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...recent.map(
                  (t) => TransactionCard(
                    transaction: t,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditScreen(transaction: t),
                      ),
                    ),
                  ),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 72,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Пока нет транзакций',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Нажмите + чтобы добавить первую',
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      ],
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

  String _monthName(int month) {
    const names = [
      '',
      'январе',
      'феврале',
      'марте',
      'апреле',
      'мае',
      'июне',
      'июле',
      'августе',
      'сентябре',
      'октябре',
      'ноябре',
      'декабре',
    ];
    return names[month];
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final Color onBackground;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.onBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onBackground.withValues(alpha: 0.65),
              ),
            ),
            Text(
              NumberFormat.currency(locale: 'ru', symbol: '₽').format(amount),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: onBackground,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
