import 'package:armstrong/config/colors.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.categories.map((category) {
          bool isSelected = widget.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0), 
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250), 
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected ? orangeContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFE9879) : buttonColor,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: orangeContainer.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => widget.onSelected(category),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
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
