import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/article_details.dart';

class ArticleCard extends StatelessWidget {
  final String articleId;
  final String imageUrl;
  final String title;
  final String publisher;

  const ArticleCard({
    Key? key,
    required this.articleId,
    required this.imageUrl,
    required this.title,
    required this.publisher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                ArticleDetailPage(articleId: articleId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var tween = Tween<double>(begin: 0.95, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOutQuad));

              return ScaleTransition(
                scale: animation.drive(tween),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          // boxShadow: [
          //   BoxShadow(
          //     color: theme.brightness == Brightness.dark
          //   ? Colors.grey[200]!.withOpacity(0.25)  // Dark mode shadow color
          //   : Colors.grey[800]!.withOpacity(0.15),  // Light mode shadow color
          //     spreadRadius: 1,
          //     blurRadius: 4,
          //     offset: const Offset(0, 0),
          //   ),
          // ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
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

              // Dark overlay
              Container(color: Colors.black.withOpacity(0.5)),

              // Text overlay
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        publisher,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
