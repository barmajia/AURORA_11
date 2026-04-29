import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurora/data/models/products/product.dart';
import 'package:aurora/data/sources/remote/product_service.dart';
import 'package:aurora/core/userStorage.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() { super.initState(); _loadProducts(); }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final userStorage = Provider.of<UserStorage>(context, listen: false);
      final sellerId = userStorage.currentUser?.id;
      if (sellerId != null) _products = await _productService.fetchProductsBySeller(sellerId);
    } catch (e) {}
    setState(() => _isLoading = false);
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products.where((p) => p.name.toLowerCase().contains(query) ||
        (p.brand?.toLowerCase().contains(query) ?? false) ||
        (p.sku?.toLowerCase().contains(query) ?? false) ||
        (p.asin?.toLowerCase().contains(query) ?? false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products'), actions: [IconButton(icon: const Icon(Icons.search), onPressed: () => _showSearch())]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _filteredProducts.isEmpty ? _buildEmpty() : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]), const SizedBox(height: 16),
      Text('No products yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
      const SizedBox(height: 8), Text('Add products to see them here', style: TextStyle(color: Colors.grey[500])),
    ]));
  }

  Widget _buildList() {
    return RefreshIndicator(onRefresh: _loadProducts,
      child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _filteredProducts.length,
        itemBuilder: (context, index) { final product = _filteredProducts[index]; return _ProductCard(product: product); }),
    );
  }

  void _showSearch() {
    showSearch(context: context, delegate: _ProductSearchDelegate(products: _products));
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(width: 48, height: 48,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: product.imageUrl != null
              ? ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.inventory_2, color: Colors.grey[400])))
              : Icon(Icons.inventory_2, color: Colors.grey[400])),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (product.brand != null) Text(product.brand!),
          Text('Stock: ${product.stockQuantity}', style: TextStyle(color: product.isInStock ? Colors.green : Colors.red, fontSize: 12)),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (product.hasDiscount) Text('EGP ${product.compareAtPrice!.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500], decoration: TextDecoration.lineThrough)),
          Text('EGP ${product.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 4), _StatusBadge(status: product.status, isInStock: product.isInStock),
        ]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProductStatus status; final bool isInStock;
  const _StatusBadge({required this.status, required this.isInStock});

  @override
  Widget build(BuildContext context) {
    Color color; String text;
    if (!isInStock) { color = Colors.red; text = 'Out of Stock'; }
    else {
      switch (status) {
        case ProductStatus.active: color = Colors.green; text = 'Active'; break;
        case ProductStatus.draft: color = Colors.orange; text = 'Draft'; break;
        case ProductStatus.archived: color = Colors.grey; text = 'Archived'; break;
        case ProductStatus.outOfStock: color = Colors.red; text = 'Out of Stock';
      }
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)));
  }
}

class _ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;
  _ProductSearchDelegate({required this.products});

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = query.isEmpty ? products : products.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        (p.brand?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (p.sku?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (p.asin?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
    return ListView.builder(itemCount: results.length, itemBuilder: (context, index) {
      final product = results[index];
      return ListTile(leading: Icon(Icons.inventory_2), title: Text(product.name), subtitle: Text('EGP ${product.price.toStringAsFixed(2)}'),
        onTap: () => close(context, product));
    });
  }
}
