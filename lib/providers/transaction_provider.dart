import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionProvider with ChangeNotifier {
  late Box<Transaction> _transactionsBox;
  late Box<Category> _categoriesBox;
  bool _isInitialized = false;

  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    _transactionsBox = Hive.box<Transaction>('transactions');
    _categoriesBox = Hive.box<Category>('categories');
    
    // 初始化默认分类
    if (_categoriesBox.isEmpty) {
      await _initDefaultCategories();
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initDefaultCategories() async {
    final defaultCategories = DefaultCategories.all;
    
    for (var category in defaultCategories) {
      await _categoriesBox.put(category.id, category);
    }
  }

  bool get isInitialized => _isInitialized;

  List<Transaction> get transactions => _transactionsBox.values.toList();

  List<Transaction> get recentTransactions {
    return transactions
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Category> get categories => _categoriesBox.values.toList();

  List<Category> get expenseCategories {
    return categories
        .where((category) => category.type == CategoryType.expense)
        .toList();
  }

  List<Category> get incomeCategories {
    return categories
        .where((category) => category.type == CategoryType.income)
        .toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    // 检查是否有交易使用此分类
    final transactionsWithCategory = transactions
        .where((transaction) => transaction.category.id == id)
        .toList();
    
    if (transactionsWithCategory.isNotEmpty) {
      throw Exception('无法删除此分类，因为有交易正在使用它');
    }
    
    await _categoriesBox.delete(id);
    notifyListeners();
  }

  double get balance {
    double income = _transactionsBox.values
        .where((t) => t.category.type == CategoryType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
    
    double expense = _transactionsBox.values
        .where((t) => t.category.type == CategoryType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    
    return income - expense;
  }

  double get totalIncome {
    return _transactionsBox.values
        .where((t) => t.category.type == CategoryType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactionsBox.values
        .where((t) => t.category.type == CategoryType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // 获取指定月份的收支数据
  Map<String, double> getMonthlyData(DateTime month) {
    var filtered = _transactionsBox.values.where((t) =>
        t.date.year == month.year && t.date.month == month.month);
    
    double income = filtered
        .where((t) => t.category.type == CategoryType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
    
    double expense = filtered
        .where((t) => t.category.type == CategoryType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    
    return {'income': income, 'expense': expense};
  }

  // 获取指定时间范围内的交易
  List<Transaction> getTransactionsInRange(DateTime start, DateTime end) {
    return transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  // 获取今日交易
  List<Transaction> getTodayTransactions() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return getTransactionsInRange(todayStart, todayEnd);
  }

  // 获取本周交易
  List<Transaction> getThisWeekTransactions() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return getTransactionsInRange(
      DateTime(weekStart.year, weekStart.month, weekStart.day),
      weekEnd
    );
  }

  // 获取本月交易
  List<Transaction> getThisMonthTransactions() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return getTransactionsInRange(monthStart, monthEnd);
  }

  // 按分类统计支出/收入
  Map<Category, double> getCategoryStats(CategoryType type, {DateTimeRange? dateRange}) {
    Map<Category, double> result = {};
    
    Iterable<Transaction> filteredTransactions = transactions
        .where((t) => t.category.type == type);
    
    if (dateRange != null) {
      filteredTransactions = filteredTransactions.where((t) =>
          t.date.isAfter(dateRange.start) && t.date.isBefore(dateRange.end));
    }
    
    for (var transaction in filteredTransactions) {
      result.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount
      );
    }
    
    return result;
  }

  // 导出数据为CSV格式
  String exportToCSV() {
    final sb = StringBuffer();
    
    // CSV头部
    sb.writeln('日期,类型,分类,金额,备注');
    
    // 数据行
    for (var transaction in recentTransactions) {
      sb.write('${DateFormat('yyyy-MM-dd').format(transaction.date)},');
      sb.write('${transaction.isIncome ? "收入" : "支出"},');
      sb.write('${transaction.category.name},');
      sb.write('${transaction.amount},');
      sb.writeln('"${transaction.note.replaceAll('"', '""')}"');
    }
    
    return sb.toString();
  }

  // 清空所有数据
  Future<void> clearAllData() async {
    await _transactionsBox.clear();
    notifyListeners();
  }
}
