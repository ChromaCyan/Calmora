import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryChip({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: categories.map((category) {
        final bool isSelected = category == selectedCategory;

        return GestureDetector(
          onTap: () => onSelected(category),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isLight ? Colors.black : Colors.white.withOpacity(0.8)),
                width: 1.5,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isLight ? Colors.black : Colors.white.withOpacity(0.8)),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
