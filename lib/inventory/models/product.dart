/// Data model representing a product in the FlexiStore inventory.
///
/// Maps directly to the `products` MySQL table. JSON deserialization is used
/// for read operations where the C++ FFI layer returns a `const char*`
/// containing a JSON-encoded string.
class Product {
  final int id;
  final String barcode;
  final String name;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQuantity;
  final String status;

  const Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.status = 'active',
  });

  // ── Soft-Delete Helper ──────────────────────────────────────────────────────
  /// Returns `true` when the product has been soft-deleted on the backend.
  bool get isInactive => status == 'inactive';

  // ── JSON Serialization ──────────────────────────────────────────────────────

  /// Creates a [Product] from a decoded JSON map.
  ///
  /// The JSON originates from the C++ FFI layer (`const char*` → Dart String →
  /// `jsonDecode` → `Map<String, dynamic>`).
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      status: json['status'] as String? ?? 'active',
    );
  }

  /// Serializes this product to a JSON-compatible map.
  ///
  /// Primarily kept for debugging/logging. Write operations to the C++ backend
  /// are handled via positional FFI arguments, not JSON payloads.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'status': status,
    };
  }

  // ── CopyWith ────────────────────────────────────────────────────────────────
  /// Returns a new [Product] with the given fields replaced.
  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    double? purchasePrice,
    double? sellingPrice,
    int? stockQuantity,
    String? status,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'Product(id: $id, barcode: $barcode, name: $name, '
      'purchasePrice: $purchasePrice, sellingPrice: $sellingPrice, '
      'stockQuantity: $stockQuantity, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          barcode == other.barcode &&
          name == other.name &&
          purchasePrice == other.purchasePrice &&
          sellingPrice == other.sellingPrice &&
          stockQuantity == other.stockQuantity &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        barcode,
        name,
        purchasePrice,
        sellingPrice,
        stockQuantity,
        status,
      );
}
