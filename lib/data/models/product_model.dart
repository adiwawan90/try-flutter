class Product {
  final String id;
  final String name;
  final double price;
  final String sku;
  final int stock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.sku,
    required this.stock,
    this.imageUrl,
  });

  // Factory untuk convert JSON ke Object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'No Name',
      sku: json['sku'] ?? '-',
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'],
    );
  }

  // Convert Object ke JSON (untuk kirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'sku': sku,
      'stock': stock,
      'image_url': imageUrl,
    };
  }

  // Method copyWith untuk update state lokal sementara (optimistic update)
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? sku,
    int? stock,
    String? imageUrl
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      imageUrl: this.imageUrl
    );
  }
}