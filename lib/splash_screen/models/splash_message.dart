class OnBoards {
  final String text, image;

  OnBoards({required this.text, required this.image});
}

List<OnBoards> onBoardData = [
  OnBoards(
    text: "This is Calmora! Where mental health meets trusted care.",
    image: "images/calmora_circle_crop.png",
  ),
  // OnBoards(
  //   text: "It's okay to feel broken sometimes. Showing your vulnerable side is not a sign of weakness it's a step toward true strength and healing.",
  //   image: "images/splash/image5.png",
  // ),
  OnBoards(
    text: "Discover Resources, including articles, tools, and tips to help manage stress, anxiety, and other mental health challenges.",
    image: "images/splash/resources.png",
  ),
    OnBoards(
    text: "Talk to our chatbot to assist you and guide you through your needs.",
    image: "images/splash/chatbot.png",
  ),
  OnBoards(
    text: "Find licensed therapists, and mental health experts to guide you through your journey.",
    image: "images/splash/specialist.png",
  ),
  OnBoards(
    text: "Begin your journey to a healthier mental health now and achive the peace you've always desserve.",
    image: "images/splash/peace.png",
  ),
];
