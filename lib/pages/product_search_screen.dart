import 'package:flutter/material.dart';
import 'dart:async';
import 'app_colors.dart';
import 'product_detail_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  final List<Map<String, String>> allProducts;

  const ProductSearchScreen({
    Key? key,
    required this.allProducts,
  }) : super(key: key);

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredProducts = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.allProducts;
    _searchController.addListener(_onSearchChanged);
    _filterProducts(); // Boshlang'ich holatda barcha mahsulotlarni ko'rsatish
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      _isSearching = true;
    });
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterProducts();
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        _filteredProducts = widget.allProducts.where((product) {
          final titleMatches = product['title']!.toLowerCase().contains(query);
          return titleMatches;
        }).toList();
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 253, 253),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(4, 10, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Mahsulotni qidirish",
                        hintStyle: TextStyle(fontSize: 16, color: AppColors.textGreyLight),
                        prefixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textGreyLight),
                                ),
                              )
                            : const Icon(Icons.search, color: AppColors.textGreyLight),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textGreyLight, size: 20),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          "Mahsulot topilmadi",
          style: TextStyle(color: AppColors.textGrey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _ProductListItem(
          product: product,
        );
      },
    );
  }
}

// Yangi ro'yxat elementi uchun vidjet
class _ProductListItem extends StatelessWidget {
  final Map<String, String> product;

  const _ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        product['title']!,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                    title: product['title']!,
                    price: product['price']!,
                    imageUrl: product['image']!,
                    description: product['description']!)));
      },
    );
  }
}