import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/article_card.dart';

class ArticleList extends StatelessWidget {
  final List<Map<String, String>> articles = [
    {
      'imageUrl': 'https://images.unsplash.com/photo-1693168057717-56c81308a680?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Replace with your image URLs
      'title': "Ease your mind by masturbating. See how it is beneficial to your health.",
      'publisher': 'Dr. Bogart Fernandez',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1724820205981-8321546b81c5?q=80&w=1918&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'title':
          "It isn't so bad to enjoy little things. See how it can affect your mental health.",
      'publisher': 'Dr. Brando Sison',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1440133197387-5a6020d5ace2?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'title': "Try new things for a healthier mind.",
      'publisher': 'Dr. Joelito Bugarin',
    },
    {
      'imageUrl': 'https://as2.ftcdn.net/v2/jpg/01/31/30/73/1000_F_131307393_VCryyNEp2CDVJHunQqJtfwmXA8QHUmPp.jpg',
      'title': "Suicide is not the answer. You are more than what you think.",
      'publisher': 'Dr. Lulu',
    },
    // Add more articles here
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleCard(
            imageUrl: article['imageUrl']!,
            title: article['title']!,
            publisher: article['publisher']!,
          );
        },
      ),
    );
  }
}
