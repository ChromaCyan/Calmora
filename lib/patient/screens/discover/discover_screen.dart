import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/patient/blocs/profile/profile_state.dart';
import 'package:armstrong/patient/models/widgets/banner_model.dart';
import 'package:armstrong/widgets/cards/article_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:armstrong/widgets/cards/specialist_card.dart';
import 'package:armstrong/widgets/navigation/category.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:armstrong/widgets/cards/daily_advice_card.dart';
import 'package:armstrong/patient/blocs/profile/profile_bloc.dart';
import 'package:armstrong/patient/blocs/profile/profile_event.dart';
import 'package:armstrong/patient/screens/discover/specialist_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:armstrong/services/api.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _specialistKey = GlobalKey();
  final ApiRepository _apiRepository = ApiRepository();

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'Specialist';
  String selectedArticleCategory = '';

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _fetchSpecialists();
  }

  void _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasCompletedOnboarding2 =
        prefs.getBool('hasCompletedOnboarding2') ?? false;

    if (!hasCompletedOnboarding2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context)
            .startShowCase([_searchKey, _categoryKey, _specialistKey]);
      });

      // Set onboarding as completed for the discovery screen
      await prefs.setBool('hasCompletedOnboarding2', true);
    }
  }

  @override
  void _fetchSpecialists() {
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(FetchSpecialistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: HealthAdviceSection(items: carouselData),
                ),
                const SizedBox(height: 20),
                Showcase(
                  key: _searchKey,
                  description: "Search for specialists or articles here.",
                  textColor: theme.colorScheme.onBackground,
                  tooltipBackgroundColor: theme.colorScheme.primary,
                  targetPadding: const EdgeInsets.all(16),
                  targetShapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  descTextStyle: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                  child: CustomSearchBar(
                    hintText: 'Search',
                    searchController: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    onClear: () {
                      setState(() {
                        searchController.clear();
                        searchQuery = '';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Showcase(
                  key: _categoryKey,
                  description: "Select the category of your choice.",
                  textColor: theme.colorScheme.onBackground,
                  tooltipBackgroundColor: theme.colorScheme.primary,
                  targetPadding: const EdgeInsets.all(16),
                  targetShapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  descTextStyle: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                  child: CategoryChip(
                    categories: ['Specialist', 'Articles'],
                    selectedCategory: selectedCategory,
                    onSelected: (String category) {
                      setState(() {
                        selectedCategory = category;
                        selectedArticleCategory =
                            ''; // Reset article category filter when switching to Specialist
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Category filter for articles
                if (selectedCategory == 'Articles')
                  Showcase(
                    key: GlobalKey(),
                    description: "Filter articles by category.",
                    textColor: theme.colorScheme.onBackground,
                    tooltipBackgroundColor: theme.colorScheme.primary,
                    targetPadding: const EdgeInsets.all(16),
                    targetShapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    descTextStyle: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value: selectedArticleCategory.isEmpty
                          ? null
                          : selectedArticleCategory,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context)
                            .colorScheme
                            .primary, 
                      ),
                      isExpanded: true,
                      elevation: 16,
                      onChanged: (String? newCategory) {
                        setState(() {
                          selectedArticleCategory = newCategory ?? '';
                        });
                      },
                      items: [
                        'health',
                        'social',
                        'growth',
                        'relationships',
                        'coping strategies',
                        'self-care'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            width: double.infinity,
                            height: 45, // Similar height as CategoryChip
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: selectedArticleCategory == value
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                              border: Border.all(
                                color: selectedArticleCategory == value
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: 1.5,
                              ),
                              boxShadow: selectedArticleCategory == value
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                value[0].toUpperCase() + value.substring(1),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedArticleCategory == value
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: selectedCategory == 'Specialist'
                      ? _buildSpecialistList()
                      : _buildArticleList(searchQuery,
                          selectedArticleCategory), // Pass the article category filter
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistList() {
    return FutureBuilder<List<dynamic>>(
      future: ApiRepository().getSpecialistList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No specialists found.'));
        }

        final specialists = snapshot.data!;
        final filteredSpecialists = specialists.where((specialist) {
          final name = '${specialist['firstName']} ${specialist['lastName']}';
          return name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        if (filteredSpecialists.isEmpty) {
          return const Center(child: Text('No matching specialists found.'));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredSpecialists.length,
          itemBuilder: (context, index) {
            final specialist = filteredSpecialists[index];
            final name = '${specialist['firstName']} ${specialist['lastName']}';
            final specialization = specialist['specialization'] ?? 'Unknown';
            final image = specialist['profileImage']?.isEmpty ?? true
                ? 'images/splash/doc1.jpg'
                : specialist['profileImage'];

            return SpecialistCard(
              specialist: Specialist(
                name: name,
                specialization: specialization,
                imageUrl: image,
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecialistDetailScreen(
                      specialistId: specialist['_id'],
                    ),
                  ),
                );
                if (result != null && result == 'refresh') {
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildArticleList(String searchQuery, String selectedCategory) {
    return FutureBuilder<List<Article>>(
      future: ApiRepository().getAllArticles(),
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
          bool matchesCategory = selectedCategory.isEmpty ||
              article.categories.contains(selectedCategory);
          bool matchesSearchQuery =
              article.title.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesCategory && matchesSearchQuery;
        }).toList();

        if (filteredArticles.isEmpty) {
          return const Center(child: Text('No matching articles found.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredArticles.length,
          itemBuilder: (context, index) {
            final article = filteredArticles[index];
            return ArticleCard(
              articleId: article.id,
              imageUrl: article.heroImage,
              title: article.title,
              publisher: 'By ${article.specialistName}',
            );
          },
        );
      },
    );
  }
}
