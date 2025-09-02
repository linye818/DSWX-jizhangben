import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? editingTransaction;

  const AddTransactionScreen({Key? key, this.editingTransaction}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  late CategoryType _selectedType;
  late Category _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，初始化表单数据
    if (widget.editingTransaction != null) {
      final transaction = widget.editingTransaction!;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note;
      _selectedType = transaction.category.type;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
      _selectedTime = TimeOfDay.fromDateTime(transaction.date);
    } else {
      // 新建模式，设置默认值
      _selectedType = CategoryType.expense;
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      _selectedCategory = provider.expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = _selectedType == CategoryType.income 
        ? provider.incomeCategories 
        : provider.expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingTransaction != null ? '编辑交易' : '添加交易'),
        actions: [
          if (widget.editingTransaction != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTransaction(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 收入/支出切换
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('支出', style: TextStyle(color: Colors.white)),
                      selected: _selectedType == CategoryType.expense,
                      selectedColor: Colors.red,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = CategoryType.expense;
                            _selectedCategory = provider.expenseCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('收入', style: TextStyle(color: Colors.white)),
                      selected: _selectedType == CategoryType.income,
                      selectedColor: Colors.green,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = CategoryType.income;
                            _selectedCategory = provider.incomeCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // 金额输入
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '金额',
                  prefixText: '¥ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入金额';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              
              // 分类选择
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Row(
                      children: [
                        Text(category.icon),
                        SizedBox(width: 10),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              
              // 日期和时间选择
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '日期',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '时间',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // 备注输入
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 30),
              
              // 保存按钮
              ElevatedButton(
                onPressed: () => _saveTransaction(context),
                child: Text('保存', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTransaction(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text;
      
      // 合并日期和时间
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      if (widget.editingTransaction != null) {
        // 更新现有交易
        final updatedTransaction = Transaction(
          id: widget.editingTransaction!.id,
          amount: amount,
          note: note,
          date: dateTime,
          category: _selectedCategory,
        );
        
        provider.updateTransaction(updatedTransaction);
      } else {
        // 添加新交易
        final newTransaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          note: note,
          date: dateTime,
          category: _selectedCategory,
        );
        
        provider.addTransaction(newTransaction);
      }
      
      Navigator.pop(context);
    }
  }

  void _deleteTransaction(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除这条交易记录吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final provider = Provider.of<TransactionProvider>(context, listen: false);
                provider.deleteTransaction(widget.editingTransaction!.id);
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回上一页
              },
              child: Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
