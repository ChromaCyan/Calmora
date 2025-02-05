import 'package:armstrong/patient/blocs/profile/profile_state.dart';
import 'package:armstrong/patient/models/widgets/banner_model.dart';
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
    bool hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;

    if (!hasCompletedOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context)
            .startShowCase([_searchKey, _categoryKey, _specialistKey]);
      });

      // Set onboarding as completed
      await prefs.setBool('hasCompletedOnboarding', true);
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
                  description: "Browse through available specialists or articles",
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
      {'title': 'Mental Health Tips for Men', 'image': 'assets/article1.jpg'},
      {'title': 'Overcoming Stress: A Guide', 'image': 'assets/article2.jpg'},
      {
        'title': 'Building Emotional Resilience',
        'image': 'assets/article3.jpg'
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
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Image.asset(
              article['image']!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(article['title']!),
          ),
        );
      },
    );
  }
}
