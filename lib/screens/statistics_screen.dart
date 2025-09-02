import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../providers/transaction_provider.dart';
import '../models/category.dart';
import '../widgets/chart.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  
  CategoryType _selectedCategoryType = CategoryType.expense;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categoryStats = provider.getCategoryStats(
      _selectedCategoryType, 
      dateRange: _selectedDateRange
    );

    final totalAmount = categoryStats.values.fold(0.0, (sum, amount) => sum + amount);
    final sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text('统计'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
          PopupMenuButton<CategoryType>(
            onSelected: (CategoryType type) {
              setState(() {
                _selectedCategoryType = type;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CategoryType>>[
              PopupMenuItem<CategoryType>(
                value: CategoryType.expense,
                child: Text('支出统计'),
              ),
              PopupMenuItem<CategoryType>(
                value: CategoryType.income,
                child: Text('收入统计'),
              ),
            ],
          ),
        ],
      ),
      body: categoryStats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '暂无数据',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '请先添加一些交易记录',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期范围显示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${DateFormat('yyyy/MM/dd').format(_selectedDateRange.start)} - '
                        '${DateFormat('yyyy/MM/dd').format(_selectedDateRange.end)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // 统计摘要
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            _selectedCategoryType == CategoryType.expense ? '总支出' : '总收入',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '¥${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _selectedCategoryType == CategoryType.expense 
                                  ? Colors.red 
                                  : Colors.green,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '共${categoryStats.length}个分类',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // 饼图
                  Container(
                    height: 200,
                    child: _buildPieChart(sortedCategories, totalAmount),
                  ),
                  SizedBox(height: 24),
                  
                  // 分类明细标题
                  Text(
                    '分类明细',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  
                  // 分类明细列表
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: sortedCategories.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = sortedCategories[index];
                      final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: entry.key.color.withOpacity(0.2),
                          child: Text(
                            entry.key.icon,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        title: Text(entry.key.name),
                        subtitle: LinearProgressIndicator(
                          value: entry.value / totalAmount,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(entry.key.color),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '¥${entry.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedCategoryType == CategoryType.expense 
                                    ? Colors.red 
                                    : Colors.green,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPieChart(List<MapEntry<Category, double>> data, double totalAmount) {
    final series = [
      charts.Series<MapEntry<Category, double>, String>(
        id: '分类统计',
        domainFn: (entry, _) => entry.key.name,
        measureFn: (entry, _) => entry.value,
        colorFn: (entry, _) => charts.ColorUtil.fromDartColor(entry.key.color),
        labelAccessorFn: (entry, _) => 
            '${entry.key.name}: ¥${entry.value.toStringAsFixed(0)}',
        data: data,
      ),
    ];

    return charts.PieChart(
      series,
      animate: true,
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 60,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.auto,
            outsideLabelStyleSpec: charts.TextStyleSpec(
              fontSize: 12,
              color: charts.MaterialPalette.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}
