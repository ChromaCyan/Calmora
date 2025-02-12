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
import 'package:armstrong/widgets/banners/patient_banner_card.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchSpecialists();
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: HealthAdviceSection(items: carouselData),
              ),
              const SizedBox(height: 20),
              Showcase(
                key: _searchKey,
                description: "Search for specialists or articles here.",
                textColor: theme.colorScheme.onPrimary,
                tooltipBackgroundColor: theme.colorScheme.primary,
                targetPadding: EdgeInsets.all(12),
                targetShapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
                textColor: theme.colorScheme.onPrimary,
                tooltipBackgroundColor: theme.colorScheme.primary,
                targetPadding: EdgeInsets.all(12),
                targetShapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CategoryChip(
                  categories: ['Specialist', 'Articles'],
                  selectedCategory: selectedCategory,
                  onSelected: (String category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              Showcase(
                key: _specialistKey,
                description: "Browse through available specialists or articles",
                textColor: theme.colorScheme.onPrimary,
                tooltipBackgroundColor: theme.colorScheme.primary,
                targetPadding: EdgeInsets.all(12),
                targetShapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: selectedCategory == 'Specialist'
                    ? _buildSpecialistList()
                    : _buildArticleList(),
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
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SpecialistsLoaded) {
          final filteredSpecialists = state.specialists.where((specialist) {
            final name = '${specialist['firstName']} ${specialist['lastName']}';
            return name.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          if (filteredSpecialists.isEmpty) {
            return const Center(child: Text('No results found.'));
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
              final name =
                  '${specialist['firstName']} ${specialist['lastName']}';
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
                    _fetchSpecialists();
                  }
                },
              );
            },
          );
        } else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('No data available.'));
      },
    );
  }

  Widget _buildArticleList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
          return article['title']
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
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
              articleId: article['_id'],
              imageUrl: article['heroImage'],
              title: article['title'],
              publisher:
                  'By ${article['specialistId']?['firstName'] ?? "Unknown"} ${article['specialistId']?['lastName'] ?? ""}'
                      .trim(),
            );
          },
        );
      },
    );
  }
}
