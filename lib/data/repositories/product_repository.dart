import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_model.dart';

class ProductRepository {
  // Opsi: Set ke 'false' jika Backend sudah siap
  final bool useMockData = true;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['BASE_URL'] ?? 'https://api.example.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final List<Product> _dummyProducts = [
    Product(id: '1', name: 'Laptop Gaming ROG', sku: 'LPT-001', stock: 15, price: 1500000, imageUrl: 'assets/images/laptop.jpg'),
    Product(id: '2', name: 'Mouse Wireless Logitech', sku: 'ACC-023', stock: 3, price: 200000, imageUrl: 'assets/images/mouse.jpg'), // Stok < 5 (Merah)
    Product(id: '3', name: 'Keyboard Mechanical', sku: 'ACC-055', stock: 8, price: 400000, imageUrl: 'assets/images/keyboard.jpg'),
    Product(id: '4', name: 'Monitor Samsung 24"', sku: 'MNT-099', stock: 0, price: 1200000, imageUrl: null), // Stok Habis
    Product(id: '5', name: 'USB Hub Baseus', sku: 'ACC-102', stock: 4, price: 150000, imageUrl: null), // Stok < 5 (Merah)
  ];

  Future<List<Product>> getProducts() async {
    if (useMockData) {
      // Simulasi delay jaringan (agar Loading Indicator terlihat di UI)
      await Future.delayed( const Duration(seconds: 2));
      // return list dari dummy data
      return List<Product>.from(_dummyProducts);
    }
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateStock(String id, int newStock) async {
    if (useMockData) {
      // Simulasi delay jaringan
      await Future.delayed(const Duration(milliseconds: 500));
      // Update dummy data lokal
      final index = _dummyProducts.indexWhere((p) => p.id == id);
      if (index != -1) {
        _dummyProducts[index] = _dummyProducts[index].copyWith(stock: newStock);
        // Update data di memori agar saat kembali ke Home, angkanya berubah
        // Kita buat object baru karena field Product biasanya final
        Product oldData = _dummyProducts[index];
        _dummyProducts[index] = Product(
          id: oldData.id,
          name: oldData.name,
          sku: oldData.sku,
          price: oldData.price,
          stock: newStock,
          imageUrl: oldData.imageUrl,
        );
      }else {
        throw Exception("Barang tidak ditemukan di dummy DB");
      }
      return; // Selesai, jangan jalankan kode Dio di bawah
    }

    try {
      final response = await _dio.put('/products/update/$id', data: {
        'stock': newStock,
      });
      if (response.statusCode != 200) {
        throw Exception('failed to update stock: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.receiveTimeout) {
      return "Koneksi internet lambat atau terputus.";
    } else if (error.type == DioExceptionType.badResponse) {
      return "Server error: ${error.response?.statusCode}";
    }
    return "Terjadi kesalahan koneksi.";
  }
}
