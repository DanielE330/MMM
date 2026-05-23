import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:my_finance/models/transaction.dart';
import 'package:my_finance/providers/app_provider.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddEditScreen({super.key, this.transaction});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _category;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toStringAsFixed(
          t.amount == t.amount.truncate() ? 0 : 2);
      _commentController.text = t.comment ?? '';
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      _type == TransactionType.income ? incomeCategories : expenseCategories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать' : 'Новая транзакция'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // type toggle
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Расход'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Доход'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category = null;
              }),
            ),
            const SizedBox(height: 20),
            // amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Сумма *',
                prefixText: '₽ ',
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              autofocus: !_isEditing,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите сумму';
                final val = double.tryParse(v.trim().replaceAll(',', '.'));
                if (val == null || val <= 0) return 'Введите корректную сумму';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // category
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Категория *'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Выберите категорию' : null,
            ),
            const SizedBox(height: 16),
            // date picker
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Дата',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(DateFormat('dd MMMM yyyy', 'ru').format(_date)),
              ),
            ),
            const SizedBox(height: 16),
            // comment
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                hintText: 'Необязательно',
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Сохранить изменения' : 'Сохранить'),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: _confirmDelete,
                child: const Text('Удалить транзакцию'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
        _amountController.text.trim().replaceAll(',', '.'));
    final t = Transaction(
      id: widget.transaction?.id,
      amount: amount,
      category: _category!,
      date: _date,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      type: _type,
    );

    if (_isEditing) {
      await ref.read(transactionsProvider.notifier).edit(t);
    } else {
      await ref.read(transactionsProvider.notifier).add(t);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? 'Изменения сохранены' : 'Транзакция сохранена'),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить транзакцию?'),
        content:
            const Text('Вы уверены, что хотите удалить эту транзакцию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref
          .read(transactionsProvider.notifier)
          .delete(widget.transaction!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Транзакция удалена')),
        );
        Navigator.pop(context);
      }
    }
  }
}
