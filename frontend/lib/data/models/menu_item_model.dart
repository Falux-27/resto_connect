class MenuItemModel {
  final String name;
  final int price;
  final List<String> tags;
  final String description;

  const MenuItemModel({
    required this.name,
    required this.price,
    required this.tags,
    required this.description,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      name:        json['name'] as String,
      price:       json['price'] as int,
      tags:        List<String>.from(json['tags'] ?? []),
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name':        name,
        'price':       price,
        'tags':        tags,
        'description': description,
      };
}