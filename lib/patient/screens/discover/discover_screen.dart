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
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                    ],
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
          bool matchesSearchQuery =
              name.toLowerCase().contains(searchQuery.toLowerCase());
          bool matchesSpecialistType = selectedSpecialistType.isEmpty ||
              specialist['specialization'] == selectedSpecialistType;

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
            childAspectRatio: 0.75,
          ),
          itemCount: filteredSpecialists.length,
          itemBuilder: (context, index) {
            final specialist = filteredSpecialists[index];
            final name = '${specialist['firstName']} ${specialist['lastName']}';
            final location = specialist['location'] ?? 'Unknown';
            final specialization = specialist['specialization'] ?? 'Unknown';
            final image = specialist['profileImage']?.isEmpty ?? true
                ? 'images/splash/doc1.jpg'
                : specialist['profileImage'];

            return SpecialistCard(
              specialist: Specialist(
                name: name,
                location: location,
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
