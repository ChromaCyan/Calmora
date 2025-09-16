import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/widgets/cards/specialist_article_card.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:armstrong/universal/articles/add_articles.dart';

class SpecialistArticleScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistArticleScreen({Key? key, required this.specialistId})
      : super(key: key);

  @override
  _SpecialistArticleScreenState createState() =>
      _SpecialistArticleScreenState();
}

class _SpecialistArticleScreenState extends State<SpecialistArticleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context
        .read<ArticleBloc>()
        .add(FetchArticlesBySpecialist(widget.specialistId));
  }

  String _getFriendlyErrorMessage(String rawMessage) {
    if (rawMessage.contains('No articles found for this specialist')) {
      return 'You have no existing articles..';
    } else if (rawMessage.contains('Failed to connect') ||
        rawMessage.contains('SocketException')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    } else {
      return 'Something went wrong. Please try again later.';
    }
  }

  void _navigateToAddArticle() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddArticleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
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
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<ArticleBloc, ArticleState>(
                builder: (context, state) {
                  if (state is ArticleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ArticleError) {
                    String errorMessage = _getFriendlyErrorMessage(state.message);

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.question_mark,
                            size: 50,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  }

                  if (state is ArticleLoaded) {
                    final filteredArticles = state.articles.where((article) {
                      return article.title.toLowerCase().contains(searchQuery);
                    }).toList();

                    if (filteredArticles.isEmpty) {
                      return const Center(
                          child: Text("No matching articles found."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
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
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddArticle,
                label: const Text("Add Article"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
