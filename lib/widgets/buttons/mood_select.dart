import 'package:flutter/material.dart';

class MoodSelect extends StatelessWidget {
  final int? selectedMood;
  final Function(int) onMoodSelected;

  const MoodSelect({
    Key? key,
    required this.selectedMood,
    required this.onMoodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _moodButton("images/icons/depression.png", 'Very Sad', 1, Colors.red),
        _moodButton("images/icons/mental-disorder.png", 'Sad', 2, Colors.orange),
        _moodButton("images/icons/relax.png", 'Happy', 3, Colors.lightGreen),
        _moodButton("images/icons/very-happy.png", 'Very Happy', 4, Colors.green),
      ],
    );
  }

  Widget _moodButton(String imagePath, String label, int mood, Color activeColor) {
    bool isSelected = selectedMood == mood;
    Color standbyColor = Colors.grey[700]!;

    return GestureDetector(
      onTap: () => onMoodSelected(mood),
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(isSelected ? 16 : 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? activeColor.withOpacity(0.6) : Colors.transparent,
              border: Border.all(
                color: isSelected ? activeColor : Colors.transparent,
                width: 3,
              ),
            ),
            child: Image.asset(
              imagePath,
              width: isSelected ? 60 : 50,
              height: isSelected ? 60 : 50,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? activeColor : standbyColor,
            ),
          ),
        ],
      ),
    );
  }
}
