class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });
}

// Static seed categories
final kStaticCategories = [
  const CategoryModel(id: 'cat-1', name: 'Handmade Goods'),
  const CategoryModel(id: 'cat-2', name: 'Clothing'),
  const CategoryModel(id: 'cat-3', name: 'Books'),
  const CategoryModel(id: 'cat-4', name: 'Jewelry'),
  const CategoryModel(id: 'cat-5', name: 'Art & Prints'),
];
