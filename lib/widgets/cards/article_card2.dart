import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/article_details_2.dart';

class ArticleCard2 extends StatelessWidget {
  final String articleId;
  final String imageUrl;
  final String title;
  final String publisher;

  const ArticleCard2({
    Key? key,
    required this.articleId,
    required this.imageUrl,
    required this.title,
    required this.publisher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = screenWidth * 0.5;
    if (screenWidth > 600) cardWidth = screenWidth * 0.35;
    if (screenWidth > 900) cardWidth = screenWidth * 0.25;
    cardWidth = cardWidth.clamp(220, 400);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ArticleDetailPage2(articleId: articleId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var tween = Tween<double>(begin: 0.95, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOutQuad));
              return ScaleTransition(
                scale: animation.drive(tween),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        );
      },
      child: SizedBox(
        width: cardWidth,
        height: 200,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 16 / 9, // responsive height based on width
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),

                // Gradient overlay + text
                Container(
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        publisher,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
