import 'package:hive/hive.dart';
import 'category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String note;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final Category category;

  @HiveField(5)
  final String? imagePath;

  Transaction({
    required this.id,
    required this.amount,
    required this.note,
    required this.date,
    required this.category,
    this.imagePath,
  });

  // 获取交易类型（收入或支出）
  bool get isIncome => category.type == CategoryType.income;

  // 格式化金额显示
  String get formattedAmount {
    return '${isIncome ? '+' : '-'}¥${amount.toStringAsFixed(2)}';
  }

  // 从Map创建Transaction对象
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      amount: map['amount'] as double,
      note: map['note'] as String,
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as Category,
      imagePath: map['imagePath'] as String?,
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'category': category,
      'imagePath': imagePath,
    };
  }

  @override
  String toString() {
    return 'Transaction{id: $id, amount: $amount, note: $note, date: $date, category: $category}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// 交易类型枚举
enum TransactionType {
  income,
  expense,
}

// 交易过滤器
class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final Category? category;
  final double? minAmount;
  final double? maxAmount;

  TransactionFilter({
    this.startDate,
    this.endDate,
    this.category,
    this.minAmount,
    this.maxAmount,
  });

  bool appliesTo(Transaction transaction) {
    if (startDate != null && transaction.date.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && transaction.date.isAfter(endDate!)) {
      return false;
    }
    if (category != null && transaction.category != category) {
      return false;
    }
    if (minAmount != null && transaction.amount < minAmount!) {
      return false;
    }
    if (maxAmount != null && transaction.amount > maxAmount!) {
      return false;
    }
    return true;
  }
}
