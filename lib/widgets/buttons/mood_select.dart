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
        _moodButton('😊', 'Very Happy', 4, Colors.green),
        _moodButton('🙂', 'Happy', 3, Colors.lightGreen),
        _moodButton('☹️', 'Sad', 2, Colors.orange),
        _moodButton('😭', 'Very Sad', 1, Colors.red),
      ],
    );
  }

  Widget _moodButton(String emoji, String label, int mood, Color activeColor) {
    bool isSelected = selectedMood == mood;

    // Set a **fixed** text color for standby mode
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
          color: isSelected ? activeColor.withOpacity(0.6) : Colors.transparent, // Invisible when not selected
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent, // Border also invisible when not selected
            width: 3,
          ),
        ),
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: isSelected ? 40 : 30,
          ),
        ),
      ),
      SizedBox(height: 8), // Spacing between emoji and text
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? activeColor : standbyColor, // Always readable in standby mode
        ),
      ),
    ],
  ),
);

  }
}
