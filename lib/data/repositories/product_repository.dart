import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_model.dart';

class ProductRepository {
  // Opsi: Set ke 'false' jika Backend sudah siap
  final bool useMockData = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final List<Product> _dummyProducts = [
    Product(id: '1', nama_barang: 'Laptop Gaming ROG', sku: 'LPT-001', stok: 15, imageUrl: 'assets/images/laptop.jpg'),
    Product(id: '2', nama_barang: 'Mouse Wireless Logitech', sku: 'ACC-023', stok: 3, imageUrl: 'assets/images/mouse.jpg'), // Stok < 5 (Merah)
    Product(id: '3', nama_barang: 'Keyboard Mechanical', sku: 'ACC-055', stok: 8, imageUrl: 'assets/images/keyboard.jpg'),
    Product(id: '4', nama_barang: 'Monitor Samsung 24"', sku: 'MNT-099', stok: 0, imageUrl: null), // Stok Habis
  ];

  Future<List<Product>> getProducts() async {
    if (useMockData) {
      // Simulasi delay jaringan (agar Loading Indicator terlihat di UI)
      await Future.delayed( const Duration(seconds: 2));
      // return list dari dummy data
      return List<Product>.from(_dummyProducts);
    }
    try {
      final response = await _dio.get('/items');
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
        _dummyProducts[index] = _dummyProducts[index].copyWith(stok: newStock);
        // Update data di memori agar saat kembali ke Home, angkanya berubah
        // Kita buat object baru karena field Product biasanya final
        Product oldData = _dummyProducts[index];
        _dummyProducts[index] = Product(
          id: oldData.id,
          nama_barang: oldData.nama_barang,
          sku: oldData.sku,
          stok: newStock,
          imageUrl: oldData.imageUrl,
        );
      }else {
        throw Exception("Barang tidak ditemukan di dummy DB");
      }
      return; // Selesai, jangan jalankan kode Dio di bawah
    }

    try {
      final response = await _dio.put('/items/$id', data: {
        'nama_barang': 'Product Name',
        'sku': 'Product SKU',
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
