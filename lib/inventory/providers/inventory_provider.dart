import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// Manages the inventory state for the FlexiStore Inventory module.
///
/// Uses [ChangeNotifier] to integrate with Flutter's `provider` package
/// or any ancestor `ListenableBuilder`. All methods that mutate state call
/// [notifyListeners] so the UI layer reacts automatically.
///
/// **Phase 1 (current):** Methods operate on a local in-memory list with dummy
/// data. In Phase 2 these will be wired to the C++ FFI bindings that talk to
/// the MySQL backend.
class InventoryProvider extends ChangeNotifier {
  // ── Internal State ────────────────────────────────────────────────────────
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Public Getters ────────────────────────────────────────────────────────
  /// Unmodifiable view of the current product list.
  List<Product> get products => List.unmodifiable(_products);

  /// Whether a data-fetch or mutation is currently in progress.
  bool get isLoading => _isLoading;

  /// The last error message, if any. `null` when there is no error.
  String? get errorMessage => _errorMessage;

  // ── Fetch Products ────────────────────────────────────────────────────────
  /// Loads the product catalogue.
  ///
  /// **Phase 1 (stub):** Parses a hard-coded JSON string to validate the
  /// [Product.fromJson] pipeline. Will be replaced by an FFI call to
  /// `get_all_products()` in Phase 2.
  Future<void> fetchProducts() async {
    _setLoading(true);
    _clearError();

    try {
      // ── Dummy JSON simulating a C++ `const char*` response ──────────────
      const String dummyJson = '''
      [
        {
          "id": 1,
          "barcode": "6901234567890",
          "name": "Wireless Mouse",
          "purchase_price": 8.50,
          "selling_price": 14.99,
          "stock_quantity": 120,
          "status": "active"
        },
        {
          "id": 2,
          "barcode": "6909876543210",
          "name": "USB-C Hub Adapter",
          "purchase_price": 12.00,
          "selling_price": 24.99,
          "stock_quantity": 45,
          "status": "active"
        }
      ]
      ''';

      // Simulate a small async delay as if waiting on the FFI call.
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final List<dynamic> decoded = jsonDecode(dummyJson) as List<dynamic>;
      _products = decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to fetch products: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // ── Add Product ───────────────────────────────────────────────────────────
  /// Adds a new product to the inventory.
  ///
  /// **Phase 1 (stub):** Appends the product directly to the local list.
  /// Phase 2 will call the C++ `add_product(...)` FFI function and re-fetch
  /// on success.
  Future<void> addProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // TODO(team2): Replace with FFI call → add_product(barcode, name, ...)
      _products = [..._products, product];
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // ── Update Product ────────────────────────────────────────────────────────
  /// Updates an existing product identified by [product.id].
  ///
  /// **Phase 1 (stub):** Replaces the matching entry in the local list.
  /// Phase 2 will call the C++ `update_product(...)` FFI function.
  Future<void> updateProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // TODO(team2): Replace with FFI call → update_product(id, barcode, ...)
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index == -1) {
        _errorMessage = 'Product with id ${product.id} not found.';
        debugPrint(_errorMessage);
        return;
      }

      final updated = List<Product>.from(_products);
      updated[index] = product;
      _products = updated;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // ── Soft-Delete Product ───────────────────────────────────────────────────
  /// Marks a product as `inactive` instead of physically deleting it.
  ///
  /// **Phase 1 (stub):** Uses [Product.copyWith] to flip the status locally.
  /// Phase 2 will call the C++ `soft_delete_product(id)` FFI function.
  Future<void> softDeleteProduct(int productId) async {
    _setLoading(true);
    _clearError();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // TODO(team2): Replace with FFI call → soft_delete_product(id)
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _errorMessage = 'Product with id $productId not found.';
        debugPrint(_errorMessage);
        return;
      }

      final updated = List<Product>.from(_products);
      updated[index] = updated[index].copyWith(status: 'inactive');
      _products = updated;
    } catch (e) {
      _errorMessage = 'Failed to soft-delete product: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // ── Private Helpers ───────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
