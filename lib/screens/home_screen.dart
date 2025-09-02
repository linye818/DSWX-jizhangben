import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import './add_transaction_screen.dart';
import './statistics_screen.dart';
import '../widgets/transaction_list.dart';
import '../widgets/chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final monthlyData = transactionProvider.getMonthlyData(_selectedDate);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('个人记账本'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              transactionProvider.clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已清空所有数据')),
              );
            },
          ),
        ],
      ),
      body: _currentIndex == 0 
          ? _buildHomeTab(transactionProvider, monthlyData) 
          : StatisticsScreen(),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeTab(TransactionProvider provider, Map<String, double> monthlyData) {
    return Column(
      children: [
        // 月度概览
        Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('yyyy年MM月').format(_selectedDate),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, size: 24),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAmountItem('收入', monthlyData['income']!, Colors.green),
                    _buildAmountItem('支出', monthlyData['expense']!, Colors.red),
                    _buildAmountItem('结余', monthlyData['income']! - monthlyData['expense']!, 
                        (monthlyData['income']! - monthlyData['expense']!) >= 0 ? Colors.blue : Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),
        // 图表
        Container(
          height: 200,
          child: Chart(monthlyData: monthlyData),
        ),
        // 交易列表标题
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('最近交易', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('总计: ${provider.transactions.length}笔',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        // 交易列表
        Expanded(
          child: TransactionList(),
        ),
      ],
    );
  }

  Widget _buildAmountItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 4),
        Text('¥${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
