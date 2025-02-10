import 'package:armstrong/universal/articles/add_articles.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/specialist_article_card.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/widgets/navigation/search.dart';

class SpecialistArticleScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistArticleScreen({
    Key? key,
    required this.specialistId,
  }) : super(key: key);

  @override
  _SpecialistArticleScreenState createState() => _SpecialistArticleScreenState();
}

class _SpecialistArticleScreenState extends State<SpecialistArticleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'Search articles...',
            searchController: _searchController,
            onChanged: (query) {
              setState(() {
                searchQuery = query.toLowerCase();
              });
            },
            onClear: () {
              setState(() {
                searchQuery = '';
                _searchController.clear();
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiRepository().getArticlesBySpecialist(widget.specialistId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No articles found.'));
                }

                final articles = snapshot.data!;
                final filteredArticles = articles.where((article) {
                  return article['title'].toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredArticles.isEmpty) {
                  return const Center(child: Text('No matching articles found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    return SpecialistArticleCard(
                      articleId: article['_id'],
                      imageUrl: article['heroImage'],
                      title: article['title'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddArticleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
