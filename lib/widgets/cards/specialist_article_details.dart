import 'package:armstrong/widgets/forms/edit_article_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';

class SpecialistArticleDetailPage extends StatefulWidget {
  final String articleId;

  const SpecialistArticleDetailPage({Key? key, required this.articleId})
      : super(key: key);

  @override
  _SpecialistArticleDetailPageState createState() =>
      _SpecialistArticleDetailPageState();
}

class _SpecialistArticleDetailPageState
    extends State<SpecialistArticleDetailPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _specialistId;

  @override
  void initState() {
    super.initState();
    context.read<ArticleBloc>().add(FetchArticleById(widget.articleId));
  }

   Future<void> _loadSpecialistId() async {
    final id = await _storage.read(key: 'userId');
    setState(() {
      _specialistId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isUpdated = ModalRoute.of(context)!.settings.arguments as bool?;

        if (isUpdated == true) {
          return true;
        }

        final storage = FlutterSecureStorage();
        final userId = await storage.read(key: 'userId');
        if (userId != null) {
          context.read<ArticleBloc>().add(FetchArticlesBySpecialist(userId));
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Article Details'),
        ),
        body: BlocBuilder<ArticleBloc, ArticleState>(
          builder: (context, state) {
            if (state is ArticleLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ArticleError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            } else if (state is ArticleDetailLoaded) {
              return _buildArticleDetail(context, state.article);
            }
            return const Center(child: Text('Article not found'));
          },
        ),
      ),
    );
  }

  Widget _buildArticleDetail(BuildContext context, Article article) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    double contentPadding = screenWidth > 600 ? 32.0 : 20.0;
    double titleFontSize = screenWidth > 600 ? 24.0 : 22.0;
    double bodyFontSize = screenWidth > 600 ? 20.0 : 18.0;
    double specialistFontSize = screenWidth > 600 ? 18.0 : 16.0;
    double maxContentWidth = 800.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: contentPadding, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    article.heroImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                article.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 10),
              Text(
                'By ${article.specialistName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: specialistFontSize,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1, height: 24),
              Text(
                article.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: bodyFontSize,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.justify,
                softWrap: true,
                overflow: TextOverflow.clip,
              ),
              const SizedBox(height: 20),
              _buildEditDeleteButtons(context, article),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditDeleteButtons(BuildContext context, Article article) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToEditForm(context, article),
            ),
            const Text('Edit', style: TextStyle(color: Colors.blue)),
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, article.id),
            ),
            const Text('Delete', style: TextStyle(color: Colors.red)),
          ],
        ),
      ],
    );
  }

  void _navigateToEditForm(BuildContext context, Article article) async {
    bool? result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditArticleForm(article: article),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Start from the right
          const end = Offset.zero; // End at the center
          const curve = Curves.easeInOut; // Animation curve

          // Create a tween animation
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // Slide the child in from the right
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );

    if (result == true && mounted) {
      context.read<ArticleBloc>().add(FetchArticleById(article.id));
    }
  }

  void _confirmDelete(BuildContext context, String articleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 24), // Warning icon
            const SizedBox(width: 8),
            const Text('Delete Article?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this article? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteArticle(context, articleId);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded button
              ),
            ),
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteArticle(BuildContext context, String articleId) {
    context.read<ArticleBloc>().add(DeleteArticle(articleId, _specialistId!));
  }
}
