import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/widgets/cards/specialist_article_card.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:armstrong/universal/articles/add_articles.dart';
import 'package:armstrong/config/global_loader.dart';

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

  // void _navigateToAddArticle() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => AddArticleScreen()),
  //   );
  // }
    void _navigateToAddArticle() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddArticleScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0), 
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );
          return SlideTransition(position: slideAnimation, child: child);
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
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
        child: Stack(
          children: [
            Column(
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
                const SizedBox(height: 20),
                const Divider(
                  thickness: 1.5,
                  color: Colors.grey,
                  indent: 40,
                  endIndent: 40,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<ArticleBloc, ArticleState>(
                    builder: (context, state) {
                      if (state is ArticleLoading) {
                        return GlobalLoader.loader;
                      }
                      if (state is ArticleError) {
                        String errorMessage =
                            _getFriendlyErrorMessage(state.message);
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
                            ],
                          ),
                        );
                      }

                      if (state is ArticleLoaded) {
                        final filteredArticles =
                            state.articles.where((article) {
                          return article.title
                              .toLowerCase()
                              .contains(searchQuery);
                        }).toList();

                        if (filteredArticles.isEmpty) {
                          return const Center(
                              child: Text("No matching articles found."));
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<ArticleBloc>().add(
                                FetchArticlesBySpecialist(widget.specialistId));
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 70),
                            itemCount: filteredArticles.length,
                            itemBuilder: (context, index) {
                              final article = filteredArticles[index];
                              return SpecialistArticleCard(
                                articleId: article.id,
                                imageUrl: article.heroImage,
                                title: article.title,
                              );
                            },
                          ),
                        );
                      }

                      return const Center(child: Text("No articles found."));
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _navigateToAddArticle,
                  elevation: 0,
                  backgroundColor: theme.colorScheme.primary,
                  mini: true,
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: theme.colorScheme.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
