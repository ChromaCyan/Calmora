import 'package:armstrong/patient/screens/survey/questions_screen.dart';
import 'package:armstrong/widgets/cards/article_card3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/config/global_loader.dart';
import 'package:armstrong/patient/screens/survey/questions_screen.dart';

class ArticleList extends StatefulWidget {
  final String searchQuery;

  const ArticleList({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Future<void> _loadUserId() async {
  //   final storage = FlutterSecureStorage();
  //   final userId = await storage.read(key: 'userId');
  //   print("🔵 User ID Loaded: $userId");

  //   if (userId != null) {
  //     setState(() {
  //       _patientId = userId;
  //     });

  //     print("🟡 Dispatching FetchRecommendedArticles event...");
  //     context.read<ArticleBloc>().add(FetchRecommendedArticles(userId));
  //   }
  // }

  Future<void> _loadUserId() async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    if (!mounted) return; // ✅
    setState(() {
      _patientId = userId;
    });
    if (userId != null && mounted) {
      context.read<ArticleBloc>().add(FetchRecommendedArticles(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_patientId == null) {
      return GlobalLoader.loader;
    }

    return SizedBox(
      height: 230,
      child: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state is ArticleLoading) {
            return GlobalLoader.loader;
          } else if (state is ArticleError) {
            final message = state.message;

            // ✅ Check if no survey responses were found
            if (message.contains("No survey responses found")) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You haven’t taken the mental health survey yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _QuickTestButton(),
                  ],
                ),
              );
            }

            // Fallback for other errors
            return RefreshIndicator(
              onRefresh: () async {
                if (_patientId != null) {
                  context
                      .read<ArticleBloc>()
                      .add(FetchRecommendedArticles(_patientId!));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 230,
                  child: Center(
                    child: Text(
                      "Something went wrong. Pull down to retry.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            );
          } else if (state is ArticleLoaded) {
            final filteredArticles = state.articles.where((article) {
              return article.title
                  .toLowerCase()
                  .contains(widget.searchQuery.toLowerCase());
            }).toList();

            if (filteredArticles.isEmpty) {
              return const Center(child: Text('No matching articles found.'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: SizedBox(
                    width: 245,
                    child: ArticleCard(
                      articleId: article.id,
                      imageUrl: article.heroImage,
                      title: article.title,
                      publisher: 'By ${article.specialistName}',
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No articles found.'));
          }
        },
      ),
    );
  }
}

class _QuickTestButton extends StatelessWidget {
  const _QuickTestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const AssetImage('images/breath.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Take a quick survey about your mental health \n to get recommended articles',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 140,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology, color: Colors.white),
                  label: const Text(
                    'Start Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
