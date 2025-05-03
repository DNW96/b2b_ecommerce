// lib/providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(CartItem item) {
    final index = state.indexWhere((element) => element.name == item.name);
    if (index != -1) {
      state[index].quantity += 1;
      state = [...state];
    } else {
      state = [...state, item];
    }
  }

  void removeFromCart(CartItem item) {
    state = state.where((i) => i.name != item.name).toList();
  }

  double get total =>
      state.fold(0, (sum, item) => sum + item.price * item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
