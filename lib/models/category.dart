import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final CategoryType type;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final int colorValue;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.colorValue = 0xFF4CAF50, // 默认绿色
  });

  Color get color => Color(colorValue);

  // 从Map创建Category对象
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: CategoryType.values[map['type'] as int],
      icon: map['icon'] as String,
      colorValue: map['colorValue'] as int? ?? 0xFF4CAF50,
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'icon': icon,
      'colorValue': colorValue,
    };
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, type: $type, icon: $icon}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 2)
enum CategoryType {
  @HiveField(0)
  income,
  
  @HiveField(1)
  expense,
}

// 默认分类数据
class DefaultCategories {
  static List<Category> get expenseCategories => [
        Category(
          id: '1',
          name: '餐饮',
          type: CategoryType.expense,
          icon: '🍔',
          colorValue: 0xFFF44336,
        ),
        Category(
          id: '2',
          name: '购物',
          type: CategoryType.expense,
          icon: '🛒',
          colorValue: 0xFF9C27B0,
        ),
        Category(
          id: '3',
          name: '交通',
          type: CategoryType.expense,
          icon: '🚗',
          colorValue: 0xFF3F51B5,
        ),
        Category(
          id: '4',
          name: '娱乐',
          type: CategoryType.expense,
          icon: '🎬',
          colorValue: 0xFFFF9800,
        ),
        Category(
          id: '5',
          name: '医疗',
          type: CategoryType.expense,
          icon: '🏥',
          colorValue: 0xFF607D8B,
        ),
        Category(
          id: '6',
          name: '教育',
          type: CategoryType.expense,
          icon: '📚',
          colorValue: 0xFF009688,
        ),
      ];

  static List<Category> get incomeCategories => [
        Category(
          id: '7',
          name: '工资',
          type: CategoryType.income,
          icon: '💰',
          colorValue: 0xFF4CAF50,
        ),
        Category(
          id: '8',
          name: '奖金',
          type: CategoryType.income,
          icon: '🎁',
          colorValue: 0xFF8BC34A,
        ),
        Category(
          id: '9',
          name: '投资',
          type: CategoryType.income,
          icon: '📈',
          colorValue: 0xFFCDDC39,
        ),
        Category(
          id: '10',
          name: '兼职',
          type: CategoryType.income,
          icon: '💼',
          colorValue: 0xFFFFEB3B,
        ),
        Category(
          id: '11',
          name: '红包',
          type: CategoryType.income,
          icon: '🧧',
          colorValue: 0xFFFFC107,
        ),
      ];

  static List<Category> get all => [...expenseCategories, ...incomeCategories];
}
