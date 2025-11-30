import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/models/product.dart';

class ProductsState {
  final List<Product> products;
  
  ProductsState(this.products);
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsState([]));

  void addProduct(String name, double price) {
    final newProduct = Product(DateTime.now().millisecondsSinceEpoch.toString(), name, price);
    final newList = List<Product>.from(state.products)..add(newProduct);
    emit(ProductsState(newList));
  }

  Product? findById(String id) {
    try {
      return state.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}