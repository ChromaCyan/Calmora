import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 20),
              const Text(
                'Library',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildLibraryCards(),
              const SizedBox(height: 20),
              _buildJournalSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: const Text(
        '*AUTO SWIPING BANNER*\nContains: Motivational and uplifting messages\n\nYou’re a disappointment\nYou’re like an Asian son, a failure',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildLibraryCards() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCard(
            imagePath: 'assets/image1.jpg',
            title: 'Discover why you’re a failure',
            author: 'Dr. Juan Joe Cruz',
          ),
          _buildCard(
            imagePath: 'assets/image2.jpg',
            title: 'Reasons why you are a disappointment.',
            author: 'Dr. Leslie Ferrer',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String imagePath, required String title, required String author}) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            author,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Daily check-in/Notes/Mood tracking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your Journal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
