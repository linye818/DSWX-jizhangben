import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'models/transaction.dart';
import 'models/category.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/categories_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // 注册Hive适配器
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(CategoryTypeAdapter());
  
  // 打开Hive盒子
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Category>('categories');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: '个人记账本',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) => HomeScreen(),
          '/add': (context) => AddTransactionScreen(),
          '/stats': (context) => StatisticsScreen(),
          '/categories': (context) => CategoriesScreen(),
        },
      ),
    );
  }
}
