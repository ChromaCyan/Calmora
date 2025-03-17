class OnBoards {
  final String text, image;

  OnBoards({required this.text, required this.image});
}

List<OnBoards> onBoardData = [
  OnBoards(
    text: "Understanding your mental health is the first step toward positive change.\nThis survey helps us get to know your situation and mental health.",
    image: "images/icons/mental-disorder.png",
  ),
  OnBoards(
    text: "By answering honestly, we can personalize your dashboard with articles tailored just for you.",
    image: "images/icons/hopeless.png",
  ),
  OnBoards(
    text: "Your mental well-being matters.\nThe more we understand your challenges, the better we can provide the right guidance and resources to support you.",
    image: "images/icons/very-happy.png",
  ),
];
