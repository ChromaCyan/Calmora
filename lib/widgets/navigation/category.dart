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
    return Center( 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: widget.categories.map((category) {
            bool isSelected = widget.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), 
              child: ChoiceChip(
                label: Text(
                  category,
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) widget.onSelected(category);
                },
                selectedColor: orangeContainer,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFE9879) : buttonColor,
                    width: 1.5,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
