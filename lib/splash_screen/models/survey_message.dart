class OnBoards {
  final String text, image;

  OnBoards({required this.text, required this.image});
}

List<OnBoards> onBoardData = [
  OnBoards(
    text: "Understanding your mental health\nis the first step toward positive change.\n\nThis survey helps us get to know\nyour situation and mental health.",
    image: "images/icons/mental-disorder.png",
  ),
  OnBoards(
    text: "By answering honestly,\nwe can personalize your dashboard\nwith articles\ntailored just for you.",
    image: "images/icons/hopeless.png",
  ),
  OnBoards(
    text: "Your mental well-being matters.\n\nThe more we understand your challenges,\nthe better we can provide the right\nguidance and resources to support you.",
    image: "images/icons/very-happy.png",
  ),
];
