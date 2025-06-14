class Business {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final String priceRange;
  final int deliveryTime;
  final double deliveryFee;
  final bool isFreeDelivery;
  final List<String> categoryIds;

  Business({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.priceRange,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.isFreeDelivery,
    required this.categoryIds,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/400x200',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      priceRange: json['price_range'] ?? 'Da',
      deliveryTime: json['delivery_time'] ?? 30,
      deliveryFee: (json['delivery_fee'] ?? 0.0).toDouble(),
      isFreeDelivery: json['is_free_delivery'] ?? false,
      categoryIds: List<String>.from(json['category_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
      'price_range': priceRange,
      'delivery_time': deliveryTime,
      'delivery_fee': deliveryFee,
      'is_free_delivery': isFreeDelivery,
      'category_ids': categoryIds,
    };
  }
}
