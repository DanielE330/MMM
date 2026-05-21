import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_finance/database/database_helper.dart';
import 'package:my_finance/models/transaction.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return DatabaseHelper.instance.getTransactions();
  }

  Future<void> add(Transaction t) async {
    await DatabaseHelper.instance.insertTransaction(t);
    ref.invalidateSelf();
  }

  Future<void> edit(Transaction t) async {
    await DatabaseHelper.instance.updateTransaction(t);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    ref.invalidateSelf();
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);
