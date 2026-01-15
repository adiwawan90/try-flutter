import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stocking_app/data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc(this.productRepository) : super(ProductInitial()) {
    on<FetchProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await productRepository.getProducts();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
    // Handler untuk Update Stock (Optimistic Update)
    on<UpdateProductStock>((event, emit) async {
      // Kita bisa melakukan Optimistic Update (update UI dulu baru server)
      // atau Pessimistic (tunggu server sukses baru update UI).
      // Untuk tes ini, cara paling aman adalah refresh list setelah update sukses.

      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        final currentList = List<Product>.from(currentState.products);

        // Cari index barang yg mau diupdate
        final index = currentList.indexWhere((p) => p.id == event.id);
        if (index == -1) return; // Barang tidak ditemukan

        final oldProduct = currentList[index];

        // 1. UPDATE UI DULUAN (Optimistic)
        // Kita buat object baru karena Bloc butuh immutability
        final updatedProduct = Product(
          id: oldProduct.id,
          nama_barang: oldProduct.nama_barang,
          sku: oldProduct.sku,
          stok: event.newStock,
        );

        currentList[index] = updatedProduct;

        // Emit state baru agar UI berubah instan
        emit(ProductLoaded(currentList));

        // 2. REQUEST KE SERVER
        try {
          await productRepository.updateStock(event.id, event.newStock);
          add(FetchProducts()); // Refresh data otomatis setelah update
        } catch (e) {
          // 3. JIKA GAGAL, KEMBALIKAN (Rollback)
          currentList[index] = oldProduct;
          emit(ProductError("Gagal update stok: ${e.toString()}"));
          // Emit kembali data asli setelah error message muncul sebentar
          emit(ProductLoaded(currentList));
          // Kembalikan ke state loaded agar user bisa coba lagi (opsional)
          add(FetchProducts());
        }
      }
    });
  }
}