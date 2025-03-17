import 'package:armstrong/models/banner_model.dart';
import 'package:armstrong/patient/blocs/specialist_list/specialist_bloc.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/widgets/cards/article_card2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/widgets/cards/specialist_card.dart';
import 'package:armstrong/widgets/navigation/category.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:armstrong/widgets/cards/daily_advice_card.dart';
import 'package:armstrong/patient/screens/discover/specialist_detail_screen.dart';
import 'package:armstrong/services/api.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ApiRepository _apiRepository = ApiRepository();

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'Specialist';
  String selectedArticleCategory = '';
  String selectedSpecialistType = '';

  @override
  void initState() {
    super.initState();
    _fetchSpecialists();
    _fetchArticles();
  }

  @override
  void _fetchSpecialists() {
    final specialistBloc = BlocProvider.of<SpecialistBloc>(context);
    specialistBloc.add(FetchSpecialists());
  }

  @override
  void _fetchArticles() {
    final articleBloc = BlocProvider.of<ArticleBloc>(context);
    articleBloc.add(FetchAllArticles());
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

                CustomSearchBar(
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

                const SizedBox(height: 20),

                // Category Selection
                CategoryChip(
                  categories: ['Specialist', 'Articles'],
                  selectedCategory: selectedCategory,
                  onSelected: (String category) {
                    setState(() {
                      selectedCategory = category;
                      selectedArticleCategory = '';
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Specialist Type Dropdown
                if (selectedCategory == 'Specialist')
                  DropdownButton<String>(
                    value: selectedSpecialistType.isEmpty
                        ? null
                        : selectedSpecialistType,
                    icon: Icon(Icons.arrow_drop_down,
                        color: theme.colorScheme.primary),
                    isExpanded: true,
                    elevation: 16,
                    hint: Text("Select Specialist Type"),
                    onChanged: (String? newType) {
                      setState(() {
                        selectedSpecialistType =
                            newType == "Clear Filter" ? '' : newType ?? '';
                        _fetchSpecialists();
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: "Clear Filter",
                        child: Text("Clear Filter",
                            style: TextStyle(color: Colors.red)),
                      ),
                      ...['Psychologist', 'Psychiatrist', 'Counselor']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                    ],
                  ),

                // Article Category Dropdown
                if (selectedCategory == 'Articles')
                  DropdownButton<String>(
                    value: selectedArticleCategory.isEmpty
                        ? null
                        : selectedArticleCategory,
                    icon: Icon(Icons.arrow_drop_down,
                        color: theme.colorScheme.primary),
                    isExpanded: true,
                    elevation: 16,
                    hint: Text("Select Article Category"),
                    onChanged: (String? newCategory) {
                      setState(() {
                        selectedArticleCategory = newCategory == "Clear Filter"
                            ? ''
                            : newCategory ?? '';
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: "Clear Filter",
                        child: Text("Clear Filter",
                            style: TextStyle(color: Colors.red)),
                      ),
                      ...[
                        'health',
                        'social',
                        'growth',
                        'relationships',
                        'coping strategies',
                        'self-care'
                      ].map<DropdownMenuItem<String>>((String value) {
                        String capitalizedValue = value
                            .split(' ')
                            .map((word) =>
                                word[0].toUpperCase() + word.substring(1))
                            .join(' ');

                        return DropdownMenuItem<String>(
                          value: value, 
                          child: Text(capitalizedValue,
                              style: TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                    ],
                  ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? theme.cardColor
                            .withOpacity(0.65) 
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white12 
                            : Colors.black12,
                        blurRadius:
                            10, 
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: selectedCategory == 'Specialist'
                      ? _buildSpecialistList(
                          searchQuery, selectedSpecialistType)
                      : _buildArticleList(searchQuery, selectedArticleCategory),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistList(
      String searchQuery, String selectedSpecialistType) {
    return BlocBuilder<SpecialistBloc, SpecialistState>(
      builder: (context, state) {
        if (state is SpecialistLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SpecialistError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is SpecialistLoaded) {
          final specialists = state.specialists;

          final filteredSpecialists = specialists.where((specialist) {
            final name = '${specialist.firstName} ${specialist.lastName}';
            bool matchesSearchQuery =
                name.toLowerCase().contains(searchQuery.toLowerCase());
            bool matchesSpecialistType = selectedSpecialistType.isEmpty ||
                specialist.specialization == selectedSpecialistType;

            return matchesSearchQuery && matchesSpecialistType;
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
              childAspectRatio: 0.65,
            ),
            itemCount: filteredSpecialists.length,
            itemBuilder: (context, index) {
              final specialist = filteredSpecialists[index];

              return SpecialistCard(
                specialist: specialist,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecialistDetailScreen(
                        specialistId: specialist.id,
                      ),
                    ),
                  );
                  if (result != null && result == 'refresh') {
                    _fetchSpecialists(); 
                  }
                },
              );
            },
          );
        }

        return const Center(child: Text('No specialists found.'));
      },
    );
  }

  Widget _buildArticleList(String searchQuery, String selectedCategory) {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ArticleError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ArticleLoaded) {
          final articles = state.articles;
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
              return ArticleCard2(
                articleId: article.id,
                imageUrl: article.heroImage,
                title: article.title,
                publisher: 'By ${article.specialistName}',
              );
            },
          );
        } else {
          return const Center(child: Text('No articles found.'));
        }
      },
    );
  }
}
