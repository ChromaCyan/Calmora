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
import 'package:armstrong/config/global_loader.dart';

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
  String selectedGender = '';
  String selectedArticleGender = '';

  // Specialist Type
  final List<String> specialistTypes = [
    'Psychologist',
    'Psychiatrist',
    'Counselor',
  ];

  // Article Categories
  final List<String> articleCategories = [
    'Health',
    'Social',
    'Growth',
    'Relationships',
    'Coping Strategies',
    'Self-Care',
  ];

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

    return SafeArea(
      child: Center(
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Search bar
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

                // == Specialist Filters ==
                if (selectedCategory == 'Specialist') ...[
                  _buildFilterCard(
                    'Specialist Type',
                    buildCategorySelector(
                      selectedValue: selectedSpecialistType,
                      categories: specialistTypes,
                      icons: {
                        'Psychologist': Icons.psychology,
                        'Psychiatrist': Icons.medical_information,
                        'Counselor': Icons.support_agent,
                      },
                      colors: [
                        Colors.deepPurple,
                        Colors.redAccent,
                        Colors.teal
                      ],
                      onSelect: (value) {
                        setState(() {
                          selectedSpecialistType = value;
                          _fetchSpecialists();
                        });
                      },
                    ),
                  ),
                  _buildFilterCard(
                    'Specialist Gender',
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _genderOption("Female", Icons.female, "female"),
                        _genderOption("Male", Icons.male, "male"),
                      ],
                    ),
                  ),
                ],

                // == Article Filters ==
                if (selectedCategory == 'Articles') ...[
                  _buildFilterCard(
                    'Article Category',
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
                          selectedArticleCategory =
                              newCategory == "Clear Filter"
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
                  ),
                  _buildFilterCard(
                    'Article Audience',
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _articleGenderOption("Female", Icons.female, "female"),
                        _articleGenderOption("Male", Icons.male, "male"),
                      ],
                    ),
                  ),
                ],

                const Divider(
                  thickness: 1.5,
                  color: Colors.grey,
                  indent: 40,
                  endIndent: 40,
                ),

                const SizedBox(height: 20),

                // == Content Section ==
                Container(
                  padding: const EdgeInsets.all(0),
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

  Widget _buildFilterCard(String title, Widget child) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // Helper to detect light mode and get appropriate colors
  Color _unselectedBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.grey.shade600;
  }

  Color _unselectedTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : Colors.grey.shade400;
  }

// Category Selector (Specialist Type / Article Category)
  Widget buildCategorySelector({
    required String? selectedValue,
    required List<String> categories,
    required ValueChanged<String> onSelect,
    Map<String, IconData>? icons,
    List<Color>? colors,
  }) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedValue == category;

          final baseColor = colors != null && index < colors.length
              ? colors[index]
              : Theme.of(context).colorScheme.primary;

          final icon = icons != null && icons.containsKey(category)
              ? icons[category]
              : Icons.category;

          return GestureDetector(
            onTap: () => onSelect(isSelected ? '' : category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      isSelected ? baseColor : _unselectedBorderColor(context),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color:
                        isSelected ? baseColor : _unselectedTextColor(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? baseColor
                          : _unselectedTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Specialist (Gender Card Widget)
  Widget _genderOption(String label, IconData icon, String value) {
    final bool isSelected = selectedGender == value;

    Color baseColor;
    if (value == "female") {
      baseColor = Colors.pinkAccent;
    } else {
      baseColor = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedGender == value) {
            selectedGender = "";
          } else {
            selectedGender = value;
          }
          _fetchSpecialists();
        });
      },
      child: Container(
        width: 80,
        height: 80,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? baseColor : _unselectedBorderColor(context),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? baseColor : _unselectedTextColor(context),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? baseColor : _unselectedTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Article (Gender Card Widget)
  Widget _articleGenderOption(String label, IconData icon, String value) {
    final bool isSelected = selectedArticleGender == value;

    Color baseColor;
    if (value == "female") {
      baseColor = Colors.pinkAccent;
    } else {
      baseColor = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedArticleGender == value) {
            selectedArticleGender = "";
          } else {
            selectedArticleGender = value;
          }
          _fetchArticles();
        });
      },
      child: Container(
        width: 80,
        height: 80,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? baseColor : _unselectedBorderColor(context),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? baseColor : _unselectedTextColor(context),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? baseColor : _unselectedTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistList(
      String searchQuery, String selectedSpecialistType) {
    return BlocBuilder<SpecialistBloc, SpecialistState>(
      builder: (context, state) {
        if (state is SpecialistLoading) {
          return GlobalLoader.loader;
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
            bool matchesGender = selectedGender.isEmpty ||
                specialist.gender.toLowerCase() == selectedGender.toLowerCase();

            return matchesSearchQuery && matchesSpecialistType && matchesGender;
          }).toList();

          if (filteredSpecialists.isEmpty) {
            return const Center(child: Text('No matching specialists found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchSpecialists();
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
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
            ),
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
          return GlobalLoader.loader;
        } else if (state is ArticleError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ArticleLoaded) {
          final articles = state.articles;

          final filteredArticles = articles.where((article) {
            bool matchesCategory = selectedCategory.isEmpty ||
                article.categories.contains(selectedCategory);
            bool matchesGender = selectedArticleGender.isEmpty ||
                article.targetGender.toLowerCase() ==
                    selectedArticleGender.toLowerCase();
            bool matchesSearchQuery =
                article.title.toLowerCase().contains(searchQuery.toLowerCase());
            return matchesCategory && matchesSearchQuery && matchesGender;
          }).toList();

          if (filteredArticles.isEmpty) {
            return const Center(child: Text('No matching articles found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchArticles();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          );
        } else {
          return const Center(child: Text('No articles found.'));
        }
      },
    );
  }
}
