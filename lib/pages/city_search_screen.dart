import 'package:agronom_ai/weatherpages/weather_screen.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';


class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({Key? key}) : super(key: key);

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = ['Toshkent', 'Samarqand', 'London'];
  List<String> _searchResults = [];

  // Dummy data for all cities
  final List<String> _allCities = [
    'Toshkent', 'Samarqand', 'Buxoro', 'Xiva', 'Andijon', 'Farg\'ona', 'Namangan',
    'London', 'Parij', 'Nyu-York', 'Tokio', 'Dubay', 'Istanbul'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }
    setState(() {
      _searchResults = _allCities
          .where((city) => city.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToWeather(String city) {
    if (!_recentSearches.contains(city)) {
      setState(() {
        _recentSearches.insert(0, city);
      });
    }
    // Pop all until first route and push new weather screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WeatherScreen(city: city)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
          decoration: InputDecoration(
            hintText: "Shaharni qidirish...",
            hintStyle: TextStyle(fontSize: 16, color: AppColors.textGreyLight),
            prefixIcon: const Icon(Icons.search, color: AppColors.textGreyLight),
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
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: AppColors.grey.withOpacity(0.1),
      ),
      body: isSearching ? _buildSearchResults() : _buildRecentSearches(),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Qidiruv tarixi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Center(child: Text("Qidiruv tarixi bo'sh", style: TextStyle(color: AppColors.textGrey))),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final city = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history_outlined, color: AppColors.textGrey),
                title: Text(city),
                onTap: () => _navigateToWeather(city),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textGreyLight, size: 20),
                  onPressed: () {
                    setState(() {
                      _recentSearches.removeAt(index);
                    });
                  },
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              height: 1, indent: 16, endIndent: 16, color: AppColors.greyLight,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          "Shahar topilmadi",
          style: TextStyle(color: AppColors.textGrey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return ListTile(
          leading: const Icon(Icons.search_outlined, color: AppColors.textGrey),
          title: Text(city),
          onTap: () => _navigateToWeather(city),
        );
      },
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: AppColors.greyLight,
      ),
    );
  }
}