class Product {
  final String id;
  final String nama_barang;
  final String sku;
  final int stok;
  final String? imageUrl;

  Product({
    required this.id,
    required this.nama_barang,
    required this.sku,
    required this.stok,
    this.imageUrl,
  });

  // Factory untuk convert JSON ke Object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      nama_barang: json['nama_barang'] ?? 'No Name',
      sku: json['sku'] ?? '-',
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      imageUrl: json['image_url'],
    );
  }

  // Convert Object ke JSON (untuk kirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': nama_barang,
      'sku': sku,
      'stock': stok,
      'image_url': imageUrl,
    };
  }

  // Method copyWith untuk update state lokal sementara (optimistic update)
  Product copyWith({
    String? id,
    String? nama_barang,
    String? sku,
    int? stok,
    String? imageUrl
  }) {
    return Product(
      id: id ?? this.id,
      nama_barang: nama_barang ?? this.nama_barang,
      sku: sku ?? this.sku,
      stok: stok ?? this.stok,
      imageUrl: this.imageUrl
    );
  }
}