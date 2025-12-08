import 'package:agronom_ai/pages/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';




import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_assets.dart';
import 'full_screen_image_viewer.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String description;
  
  const ProductDetailScreen({
    Key? key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<String> _imageUrls;
  late final Product _product;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Mock images for the carousel
    _imageUrls = [
      widget.imageUrl,
      AppAssets.productMedicine2, // Qo'shimcha rasm misoli
      AppAssets.productMedicine1, // Qo'shimcha rasm misoli
    ];
    _product = Product(
      id: widget.title + widget.price, // Vaqtinchalik unikal ID
      title: widget.title,
      price: widget.price,
      imageUrl: widget.imageUrl,
      description: widget.description,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(_product);

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(widget.title, style: const TextStyle(color: AppColors.textBlack, fontSize: 18)),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart, // O'zgartirildi
            color: isFavorite ? AppColors.errorRed : AppColors.textBlack,
          ),
          onPressed: () {
            favoritesProvider.toggleFavorite(_product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isFavorite
                    ? "Mahsulot savatdan olib tashlandi"
                    : "Mahsulot savatga qo'shildi"),
                backgroundColor: isFavorite ? AppColors.warningOrange : AppColors.primaryGreen,
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.textBlack),
          onPressed: () {
            Share.share('Ushbu mahsulotga qarang: ${widget.title} - ${widget.price}');
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles.headline2),
                const SizedBox(height: 8),
                _buildRatingSection(),
                const SizedBox(height: 16),
                Text(
                  widget.price,
                  style: AppTextStyles.headline2.copyWith(color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Mahsulot tavsifi",
                  style: AppTextStyles.headline3,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: AppTextStyles.bodyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageViewer(
              imageUrls: _imageUrls,
              initialIndex: _currentPage,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 350,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.greyLight,
                    child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildLineIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  // Yangi chiziqli indikator
  Widget _buildLineIndicator() {
    const double totalWidth = 80.0; // Indikatorning umumiy kengligi
    final double segmentWidth = totalWidth / _imageUrls.length;

    return Container(
      width: totalWidth,
      height: 10, // Chiziq qalinligi
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 211, 209, 209).withOpacity(0.2), // Orqa fon rangi
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _currentPage * segmentWidth, // Silliq harakatlanish uchun
            child: Container(
              width: segmentWidth,
              height: 6,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 178, 180, 178), // Asosiy rang
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    // Mock data for rating
    const double rating = 4.5;
    const int reviewCount = 125;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor()
                  ? Icons.star_rounded
                  : index < rating
                      ? Icons.star_half_rounded
                      : Icons.star_border_rounded,
              color: Colors.amber,
              size: 22,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '($reviewCount ta izoh)',
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(_product);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.greyLight.withOpacity(0.5), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Narxi",
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                widget.price,
                style: AppTextStyles.headline2.copyWith(fontSize: 20, color: AppColors.primaryGreen),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                favoritesProvider.toggleFavorite(_product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isFavorite
                        ? "Mahsulot savatdan olib tashlandi"
                        : "Mahsulot savatga qo'shildi!"), // O'zgartirildi
                    backgroundColor: isFavorite ? AppColors.warningOrange : AppColors.primaryGreen,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: isFavorite
                      ? const LinearGradient(colors: [Colors.white, Colors.white]) // O'chirish uchun gradient
                      : const LinearGradient( // Qo'shish uchun gradient
                          colors: [AppColors.primaryGreenDark, AppColors.accentGreen],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  border: isFavorite ? Border.all(color: AppColors.primaryGreen) : null,
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: Text(
                    isFavorite ? "Savatdan o'chirish" : "Savatga qo'shish",
                    style: TextStyle(color: isFavorite ? AppColors.primaryGreen : Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}