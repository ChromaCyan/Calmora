import 'package:armstrong/widgets/navigation/category.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:flutter/material.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'Specialist'; // Set default category to 'Specialist'

  @override
  void initState() {
    super.initState();
    // Initialize any necessary logic
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Title Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Browse Articles and Specialist',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Search Bar
                CustomSearchBar(
                  hintText: 'Search',
                  searchController: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  onClear: () {
                    setState(() {
                      searchController.clear();
                      searchQuery = '';
                    });
                  },
                  onSearch: () {},
                ),
                const SizedBox(height: 20),
                // Category Filter
                CategoryChip(
                  categories: ['Specialist', 'Articles'],
                  selectedCategory: selectedCategory,
                  onSelected: (String category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Display content based on selected category
                selectedCategory == 'Specialist' 
                  ? _buildSpecialistList() 
                  : _buildArticleList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mock list of specialists for discovery
  Widget _buildSpecialistList() {
    List<Map<String, String>> specialists = [
      {'name': 'John Doe', 'title': 'Therapist', 'image': 'assets/specialist1.jpg'},
      {'name': 'Jane Smith', 'title': 'Counselor', 'image': 'assets/specialist2.jpg'},
      {'name': 'Michael Brown', 'title': 'Coach', 'image': 'assets/specialist3.jpg'},
    ];

    var filteredSpecialists = specialists.where((specialist) {
      return specialist['name']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredSpecialists.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredSpecialists.length,
      itemBuilder: (context, index) {
        final specialist = filteredSpecialists[index];
        return Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Image.asset(specialist['image']!, height: 100, width: 100, fit: BoxFit.cover),
                const SizedBox(height: 8),
                Text(
                  specialist['name']!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  specialist['title']!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dummy list of articles for discovery
  Widget _buildArticleList() {
    List<Map<String, String>> articles = [
      {'title': 'Mental Health Tips for Men', 'image': 'assets/article1.jpg'},
      {'title': 'Overcoming Stress: A Guide', 'image': 'assets/article2.jpg'},
      {'title': 'Building Emotional Resilience', 'image': 'assets/article3.jpg'},
    ];

    var filteredArticles = articles.where((article) {
      return article['title']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredArticles.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Image.asset(article['image']!, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(article['title']!),
          ),
        );
      },
    );
  }
}
