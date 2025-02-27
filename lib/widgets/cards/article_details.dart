import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/models/article/article.dart';

class ArticleDetailPage extends StatefulWidget {
  final String articleId;

  const ArticleDetailPage({Key? key, required this.articleId})
      : super(key: key);

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Article? article;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    try {
      final fetchedArticle =
          await ApiRepository().getArticleById(widget.articleId);
      setState(() {
        article = fetchedArticle;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final Map<String, Color> categoryColors = {
      "health": Colors.green,
      "social": Colors.blue,
      "relationships": Colors.pink,
      "growth": Colors.orange,
      "coping strategies": Colors.purple,
      "mental wellness": Colors.teal,
      "self-care": Colors.red,
    };

    // Define dynamic text sizes & padding based on screen width
    double contentPadding =
        screenWidth > 600 ? 32.0 : 20.0; // More padding on larger screens
    double titleFontSize = screenWidth > 600 ? 24.0 : 22.0;
    double bodyFontSize = screenWidth > 600 ? 20.0 : 18.0;
    double specialistFontSize = screenWidth > 600 ? 18.0 : 16.0;
    double maxContentWidth =
        800.0; // Ensures text doesn't stretch too wide on large screens

    return Scaffold(
      appBar: AppBar(title: Text(article?.title ?? 'Article Details')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : article == null
                  ? Center(
                      child: Text(
                        'Article not found',
                        style: TextStyle(color: theme.colorScheme.onBackground),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: contentPadding, vertical: 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: maxContentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Image (Responsive)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: AspectRatio(
                                  aspectRatio:
                                      16 / 9, // Maintains correct scaling
                                  child: Image.network(
                                    article!.heroImage,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error, size: 50),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Article Title
                              Text(
                                article!.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                                softWrap: true, // Prevents text overflow
                              ),
                              const SizedBox(height: 10),

                              // Specialist Name
                              Text(
                                'By ${article!.specialistName}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                  fontSize: specialistFontSize,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Categories as Tags
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Wrap(
                                  spacing: screenWidth > 600
                                      ? 12.0
                                      : 8.0, // More spacing on bigger screens
                                  runSpacing: screenWidth > 600
                                      ? 6.0
                                      : 4.0, // Better spacing between lines
                                  children: article!.categories.map((category) {
                                    String capitalizedCategory = category
                                        .split(' ')
                                        .map((word) =>
                                            word[0].toUpperCase() +
                                            word.substring(1))
                                        .join(' ');

                                    return Chip(
                                      label: Text(
                                        capitalizedCategory,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontSize: screenWidth > 600
                                              ? 16.0
                                              : 14.0, // Bigger font on tablets
                                        ),
                                      ),
                                      backgroundColor: categoryColors[
                                              category] ??
                                          theme.colorScheme
                                              .primary, // Default if not found
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth > 600
                                            ? 16.0
                                            : 12.0, // Adjust padding
                                        vertical: screenWidth > 600 ? 8.0 : 6.0,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const Divider(
                                  thickness: 1, height: 24), // Adds separation

                              // Article Content (Responsive & Readable)
                              Text(
                                article!.content,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: bodyFontSize,
                                  height: 1.6, // Improved line spacing
                                  letterSpacing: 0.3, // Helps readability
                                ),
                                textAlign: TextAlign
                                    .justify, // Ensures proper paragraph alignment
                                softWrap: true, // Prevents overflow
                                overflow: TextOverflow
                                    .clip, // Ensures text stays within bounds
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}
