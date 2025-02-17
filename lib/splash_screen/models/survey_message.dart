class OnBoards {
  final String text, image;

  OnBoards({required this.text, required this.image});
}

List<OnBoards> onBoardData = [
  OnBoards(
    text: "Welcome to Armstrong!\nA dedicated app for men's mental health and well-being.",
    image: "images/armstrong_transparent.png",
  ),
  OnBoards(
    text: "This survey will help us personalize your dashboard\nto suggest the most relevant resources for your needs.",
    image: "images/splash/survey_intro.png",
  ),
  OnBoards(
    text: "Your answers will guide us in providing the best tools,\narticles, and support for your mental health journey.",
    image: "images/splash/survey.png",
  ),
];