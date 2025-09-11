import 'package:flutter/material.dart';

class CategoryChip extends StatefulWidget {
  final List<String> categories;
  final Function(String) onSelected;
  final String selectedCategory;

  const CategoryChip({
    Key? key,
    required this.categories,
    required this.onSelected,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.categories.map((category) {
          bool isSelected = widget.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0), 
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 120, // Adjust width as needed
              height: 45,  // Box style with fixed height
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25), // Less rounded for a box-style look
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10), 
                onTap: () => widget.onSelected(category),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
