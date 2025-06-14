class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final String? parentId;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
      parentId: json['parent_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'parent_id': parentId,
    };
  }
}
