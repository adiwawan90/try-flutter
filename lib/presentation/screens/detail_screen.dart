import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stocking_app/common/constants/images.dart';
import 'package:flutter_stocking_app/data/models/product_model.dart';
import 'package:flutter_stocking_app/data/repositories/product_repository.dart';
import '../../logic/blocs/product_bloc.dart';
import '../../logic/blocs/product_event.dart';

class DetailScreen extends StatefulWidget {
  final String productId;
  final Product? initialData;

  const DetailScreen({
    super.key,
    required this.productId,
    this.initialData,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Product displayProduct;
  bool isLoading = false;
  late int currentStock;

  @override

  void initState() {
    super.initState();
    currentStock = widget.initialData?.stok ?? 0;
    
    if (widget.initialData != null) {
      displayProduct = widget.initialData!;

      _fetchFreshData();
    }
  }

  void _updateStock(int value) {
    setState(() {
      currentStock += value;
      if (currentStock < 0) currentStock = 0; // Prevent minus
    });
    
    // Panggil API via Bloc
    context.read<ProductBloc>().add(
      UpdateProductStock(
        id: widget.productId,
        newStock: currentStock,
      ),
    );
  }

  void _fetchFreshData() {
    setState(() => isLoading = true);

    context.read<ProductRepository>().getProductById(widget.productId).then((freshProduct) {
      if (mounted) {
        setState(() {
          displayProduct = freshProduct;
          isLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal refresh data: $e")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          "Perubahan stok otomatis tersimpan ke server",
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GAMBAR ---
              Center(
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    // Pastikan fungsi ini ada di dalam class atau bisa diakses
                    child: _buildProductImage(displayProduct.imageUrl),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(displayProduct.nama_barang, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('SKU: ${displayProduct.sku}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _updateStock(-1),
                    icon: const Icon(Icons.remove_circle, size: 40, color: Colors.red),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      '$currentStock',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _updateStock(1),
                    icon: const Icon(Icons.add_circle, size: 40, color: Colors.green),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          )
      ))
    );
  }
  Widget _buildProductImage(String? url) {
    const String fallbackImage = Images.noImage;
    // 1. Jika URL tidak ada atau kosong, pakai Asset lokal
    if (url == null || url.isEmpty) {
      return Image.asset(
        fallbackImage,
        fit: BoxFit.cover,
      );
    }

    // 2. Jika ada URL, load pakai Network
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator()); // Tampilkan loading muter
        },
        errorBuilder: (context, error, stackTrace) {
          // 3. Jika URL error (mati/internet putus), fallback ke Asset lokal
          return Image.asset(
            fallbackImage,
            fit: BoxFit.cover,
          );
        },
      );
    }

    // 3. Jika bukan http (berarti path asset lokal) -> Gunakan Image.asset
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Ini akan muncul jika file tidak ditemukan di folder assets
        // atau belum didaftarkan di pubspec.yaml
        return _buildErrorWidget(); 
      },
    );  
  }
}

// Helper widget untuk tampilan error biar tidak duplikasi kode
Widget _buildErrorWidget() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      const SizedBox(height: 8),
      const Text("Gagal muat", style: TextStyle(color: Colors.grey)),
    ],
  );
}
