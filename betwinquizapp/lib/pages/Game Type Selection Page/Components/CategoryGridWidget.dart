import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGrid extends StatelessWidget {
  static final List<Category> categories = [
    Category("Music", 'music', 'assets/categories/music.png'),
    Category("Science", 'science', 'assets/categories/chemistry.png'),
    Category("Society & Culture", 'society_and_culture', 'assets/categories/society.png'),
    Category("Sport & Leisure", 'sport_and_leisure', 'assets/categories/basketball.png'),
    Category("Arts & Literature", 'arts_and_literature', 'assets/categories/flower.png'),
    Category("Film & TV", 'film_and_tv', 'assets/categories/film-slate.png'),
    Category("Food & Drink", 'food_and_drink', 'assets/categories/fast-food.png'),
    Category("General Knowledge", 'general_knowledge', 'assets/categories/book.png'),
    Category("History", 'history', 'assets/categories/clock.png'),
    Category("Geography", 'geography', 'assets/categories/globe.png'),
  ];

  const CategoryGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 600 ? 3 : 2;
    final childAspectRatio = size.width > 600 ? 3 / 4 : 8 / 10;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: categories.length,
      itemBuilder: (_, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context,
          '/game-type-selection',
          arguments: category.apiEndpoint
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                category.iconPath,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                category.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Category {
  final String title;
  final String apiEndpoint;
  final String iconPath;

  const Category(this.title, this.apiEndpoint, this.iconPath);
}
