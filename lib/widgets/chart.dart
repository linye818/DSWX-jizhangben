import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Chart extends StatelessWidget {
  final Map<String, double> monthlyData;

  const Chart({Key? key, required this.monthlyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final income = monthlyData['income'] ?? 0.0;
    final expense = monthlyData['expense'] ?? 0.0;
    final total = income + expense;

    // 如果没有数据，显示空状态
    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              '暂无数据',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 创建图表数据
    final data = [
      _ChartData('收入', income, Colors.green),
      _ChartData('支出', expense, Colors.red),
    ];

    // 创建图表系列
    final series = [
      charts.Series<_ChartData, String>(
        id: '月度收支',
        domainFn: (_ChartData data, _) => data.category,
        measureFn: (_ChartData data, _) => data.amount,
        colorFn: (_ChartData data, _) => 
            charts.ColorUtil.fromDartColor(data.color),
        labelAccessorFn: (_ChartData data, _) => 
            '${data.category}: ¥${data.amount.toStringAsFixed(0)}',
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
            labelPosition: charts.ArcLabelPosition.inside,
            insideLabelStyleSpec: charts.TextStyleSpec(
              fontSize: 14,
              color: charts.MaterialPalette.white,
            ),
            outsideLabelStyleSpec: charts.TextStyleSpec(
              fontSize: 12,
              color: charts.MaterialPalette.black,
            ),
          ),
        ],
      ),
      behaviors: [
        charts.InitialSelection(selectedDataConfig: [
          charts.SeriesDatumConfig<String>(series[0].id, 0)
        ]),
      ],
    );
  }
}

// 图表数据类
class _ChartData {
  final String category;
  final double amount;
  final Color color;

  _ChartData(this.category, this.amount, this.color);
}
