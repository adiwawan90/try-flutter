import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/product_bloc.dart';
import '../../logic/blocs/product_event.dart';
import '../../logic/blocs/product_state.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stok Barang')),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(FetchProducts());
              },
              child: ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  final isLowStock = product.stok < 5;
                  
                  return ListTile(
                    title: Text(product.nama_barang, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('SKU: ${product.sku}'),
                    trailing: Text(
                      'Stok: ${product.stok}',
                      style: TextStyle(
                        color: isLowStock ? Colors.red : Colors.black,
                        fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(productId: product.id, initialData: product),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const Center(child: Text("Tidak ada stok data"));
        },
      ),  
    );
  }
}