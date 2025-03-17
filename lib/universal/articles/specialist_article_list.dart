import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/widgets/cards/specialist_article_card.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:armstrong/universal/articles/add_articles.dart';

class SpecialistArticleScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistArticleScreen({Key? key, required this.specialistId}) : super(key: key);

  @override
  _SpecialistArticleScreenState createState() => _SpecialistArticleScreenState();
}

class _SpecialistArticleScreenState extends State<SpecialistArticleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ArticleBloc>().add(FetchArticlesBySpecialist(widget.specialistId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'Search from your articles...',
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
            child: BlocBuilder<ArticleBloc, ArticleState>(
              builder: (context, state) {
                if (state is ArticleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ArticleError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is ArticleLoaded) {
                  final filteredArticles = state.articles.where((article) {
                    return article.title.toLowerCase().contains(searchQuery);
                  }).toList();

                  if (filteredArticles.isEmpty) {
                    return const Center(child: Text("No matching articles found."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];
                      return SpecialistArticleCard(
                        articleId: article.id,
                        imageUrl: article.heroImage,
                        title: article.title,
                      );
                    },
                  );
                }
                return const Center(child: Text("No articles found."));
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
        child: const Icon(Icons.add, size: 35),
      ),
    );
  }
}
