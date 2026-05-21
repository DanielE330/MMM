import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_finance/models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final amountStr =
        '${isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'ru', symbol: '₽').format(transaction.amount)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(_categoryIcon(transaction.category), color: color, size: 20),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          [
            DateFormat('dd.MM.yyyy').format(transaction.date),
            if (transaction.comment != null && transaction.comment!.isNotEmpty)
              transaction.comment!,
          ].join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          amountStr,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Продукты' => Icons.shopping_cart,
      'Транспорт' => Icons.directions_bus,
      'Развлечения' => Icons.movie,
      'Здоровье' => Icons.local_hospital,
      'Одежда' => Icons.checkroom,
      'Коммунальные услуги' => Icons.home,
      'Образование' => Icons.school,
      'Зарплата' => Icons.work,
      'Фриланс' => Icons.laptop,
      'Подарок' => Icons.card_giftcard,
      'Инвестиции' => Icons.trending_up,
      _ => Icons.attach_money,
    };
  }
}
