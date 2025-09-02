import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/category.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  
  CategoryType _selectedType = CategoryType.expense;
  bool _isAdding = false;

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final expenseCategories = provider.expenseCategories;
    final incomeCategories = provider.incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text('分类管理'),
        actions: [
          IconButton(
            icon: Icon(_isAdding ? Icons.close : Icons.add),
            onPressed: () {
              setState(() {
                _isAdding = !_isAdding;
                if (!_isAdding) {
                  _nameController.clear();
                  _iconController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 添加分类表单
          if (_isAdding) _buildAddForm(),
          
          // 分类列表
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: '支出分类 (${expenseCategories.length})'),
                      Tab(text: '收入分类 (${incomeCategories.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCategoryList(expenseCategories, provider),
                        _buildCategoryList(incomeCategories, provider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加新分类',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              // 类型选择
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
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // 名称输入
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入分类名称';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // 图标输入
              TextFormField(
                controller: _iconController,
                decoration: InputDecoration(
                  labelText: '图标符号 (如: 🍔)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入图标符号';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // 按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _addCategory(context),
                      child: Text('添加'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, TransactionProvider provider) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          '暂无分类',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isDefault = DefaultCategories.all.any((c) => c.id == category.id);
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: category.color.withOpacity(0.2),
            child: Text(category.icon, style: TextStyle(fontSize: 16)),
          ),
          title: Text(category.name),
          subtitle: Text(
            category.type == CategoryType.expense ? '支出' : '收入',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: isDefault
              ? null
              : IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(context, category),
                ),
        );
      },
    );
  }

  void _addCategory(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        icon: _iconController.text,
      );
      
      provider.addCategory(newCategory);
      
      // 重置表单
      _nameController.clear();
      _iconController.clear();
      setState(() {
        _isAdding = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分类添加成功')),
      );
    }
  }

  void _deleteCategory(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除"${category.name}"分类吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                try {
                  final provider = Provider.of<TransactionProvider>(context, listen: false);
                  provider.deleteCategory(category.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('分类删除成功')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
