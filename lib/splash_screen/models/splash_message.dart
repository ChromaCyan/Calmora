class OnBoards {
  final String text, image;

  OnBoards({required this.text, required this.image});
}

List<OnBoards> onBoardData = [
  OnBoards(
    text: "Welcome to Armstrong!\nA dedicated app for men's mental health and well-being.",
    image: "images/mens_mental_health.png",
  ),
  OnBoards(
    text: "Discover Resources\nAccess articles, tools, and tips to help manage stress, anxiety, and mental health challenges.",
    image: "images/resources.png",
  ),
  OnBoards(
    text: "Connect with Specialists\nFind licensed therapists and mental health experts to guide you through your journey.",
    image: "images/specialist.png",
  ),
  OnBoards(
    text: "Join the Conversation\nChat with peers and share experiences in a safe, supportive community.",
    image: "images/chat_community.png",
  ),
];
