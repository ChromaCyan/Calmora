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

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _specialistKey = GlobalKey();

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Center(
                  child: HealthAdviceSection(items: carouselData),
                ),
                Showcase(
                  key: _searchKey,
                  description: "Search for specialists or articles here.",
                  textColor: Colors.white,
                  tooltipBackgroundColor: Colors.blueAccent,
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

                // Showcase for Category Chip
                Showcase(
                  key: _categoryKey,
                  description: "Select the category of your choice.",
                  textColor: Colors.white,
                  tooltipBackgroundColor: Colors.blueAccent,
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

                // Showcase for Specialist List
                Showcase(
                  key: _specialistKey,
                  description:
                      "Browse through available specialists or articles",
                  textColor: Colors.white,
                  tooltipBackgroundColor: Colors.blueAccent,
                  targetPadding: EdgeInsets.all(12),
                  targetShapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: selectedCategory == 'Specialist'
                      ? _buildSpecialistList()
                      : _buildArticleList(),
                ),
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
    List<Map<String, String>> articles = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1693168057717-56c81308a680?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Replace with your image URLs
        'title':
            "Ease your mind by talking to someone. See how it is beneficial to your health.",
        'publisher': 'Dr. Bogart Fernandez',
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1724820205981-8321546b81c5?q=80&w=1918&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'title':
            "It isn't so bad to enjoy little things. See how it can affect your mental health.",
        'publisher': 'Dr. Brando Sison',
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1440133197387-5a6020d5ace2?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'title': "Try new things for a healthier mind.",
        'publisher': 'Dr. Joelito Bugarin',
      },
      {
        'imageUrl':
            'https://as2.ftcdn.net/v2/jpg/01/31/30/73/1000_F_131307393_VCryyNEp2CDVJHunQqJtfwmXA8QHUmPp.jpg',
        'title': "Suicide is not the answer. You are more than what you think.",
        'publisher': 'Dr. Lulu',
      },
    ];

    var filteredArticles = articles.where((article) {
      return article['title']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    if (filteredArticles.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles[index];
        return ArticleCard(
          imageUrl: article['imageUrl']!,
          title: article['title']!,
          publisher: article['publisher']!,
        );
      },
    );
  }
}
