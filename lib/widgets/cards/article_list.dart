import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/config/global_loader.dart';
import 'package:armstrong/widgets/cards/article_card3.dart';
import 'package:armstrong/patient/screens/survey/questions_screen.dart';

class ArticleList extends StatefulWidget {
  final String searchQuery;

  const ArticleList({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  String _errorMessage = '';
  String? _patientId;
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndArticles();
  }

  Future<void> _loadUserIdAndArticles() async {
    try {
      final userId = await _storage.read(key: 'userId');
      if (userId == null) throw 'No user found';

      setState(() {
        _patientId = userId;
        _isLoading = true;
        _errorMessage = '';
      });

      final articles = await _apiRepository.getRecommendedArticles(userId);

      if (!mounted) return;
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshArticles() async {
    if (_patientId != null) {
      await _loadUserIdAndArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return GlobalLoader.loader;
    }

    // 🧠 Handle “no survey” error
    if (_errorMessage.contains("No survey responses found")) {
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
            const _QuickTestButton(),
          ],
        ),
      );
    }

    // 🧱 Other errors
    if (_errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshArticles,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 230,
            child: Center(
              child: Text(
                "Something went wrong.\nPull down to retry.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      );
    }

    // 🔎 Filter by search
    final filteredArticles = _articles.where((article) {
      return article.title
          .toLowerCase()
          .contains(widget.searchQuery.toLowerCase());
    }).toList();

    if (filteredArticles.isEmpty) {
      return const Center(child: Text('No matching articles found.'));
    }

    // 📰 Display articles
    return SizedBox(
      height: 230,
      child: RefreshIndicator(
        onRefresh: _refreshArticles,
        child: ListView.builder(
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
        ),
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
