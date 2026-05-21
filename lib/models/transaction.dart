enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final String? comment;
  final TransactionType type;

  const Transaction({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.comment,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'comment': comment,
      'type': type.name,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      comment: map['comment'] as String?,
      type: TransactionType.values.byName(map['type'] as String),
    );
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? category,
    DateTime? date,
    String? comment,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      type: type ?? this.type,
    );
  }
}

const List<String> expenseCategories = [
  'Продукты',
  'Транспорт',
  'Развлечения',
  'Здоровье',
  'Одежда',
  'Коммунальные услуги',
  'Образование',
  'Другое',
];

const List<String> incomeCategories = [
  'Зарплата',
  'Фриланс',
  'Подарок',
  'Инвестиции',
  'Другое',
];
