import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:my_finance/models/transaction.dart';

class ExportService {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _stampFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');

  static const _headers = ['Тип', 'Сумма', 'Категория', 'Дата', 'Комментарий'];

  static List<List<dynamic>> _rows(List<Transaction> transactions) => [
        _headers,
        ...transactions.map(
          (t) => [
            t.type == TransactionType.income ? 'Доход' : 'Расход',
            t.amount,
            t.category,
            _dateFormat.format(t.date),
            t.comment ?? '',
          ],
        ),
      ];

  static Future<String> exportCsv(List<Transaction> transactions) async {
    final csv = const ListToCsvConverter().convert(_rows(transactions));
    // utf-8 bom so excel opens russian text correctly
    final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(csv)];
    final file = await _save(
      'mmm_${_stampFormat.format(DateTime.now())}.csv',
      bytes,
    );
    return file.path;
  }

  static Future<String> exportExcel(List<Transaction> transactions) async {
    final wb = Excel.createExcel();
    final sheet = wb['Транзакции'];
    wb.delete('Sheet1');

    final rows = _rows(transactions);
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        final v = rows[r][c];
        if (v is double) {
          cell.value = DoubleCellValue(v);
        } else {
          cell.value = TextCellValue(v.toString());
        }
        // bold header row
        if (r == 0) {
          cell.cellStyle = CellStyle(bold: true);
        }
      }
    }

    final bytes = wb.encode();
    if (bytes == null) throw Exception('Не удалось создать Excel файл');
    final file = await _save(
      'mmm_${_stampFormat.format(DateTime.now())}.xlsx',
      bytes,
    );
    return file.path;
  }

  static Future<File> _save(String name, List<int> bytes) async {
    final dir = await _exportDir();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<Directory> _exportDir() async {
    // desktop: ~/downloads
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '';
      if (home.isNotEmpty) {
        final downloads = Directory('$home/Downloads');
        if (await downloads.exists()) return downloads;
      }
    }
    return getApplicationDocumentsDirectory();
  }
}
