import 'package:armstrong/authentication/models/user_model.dart';
import 'package:armstrong/patient/screens/discover/specialist_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:armstrong/patient/blocs/profile/profile_bloc.dart';
import 'package:armstrong/patient/blocs/profile/profile_state.dart';
import 'package:armstrong/patient/blocs/profile/profile_event.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/widgets/navigation/category.dart';
import 'package:armstrong/widgets/navigation/search.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'Specialist';

  @override
  void initState() {
    super.initState();
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
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Browse Articles and Specialists',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
                  onSearch: () {},
                ),
                const SizedBox(height: 20),
                CategoryChip(
                  categories: ['Specialist', 'Articles'],
                  selectedCategory: selectedCategory,
                  onSelected: (String category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: 20),
                selectedCategory == 'Specialist'
                    ? _buildSpecialistList()
                    : _buildArticleList(),
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
                  ? 'assets/default_image.png'
                  : specialist['profileImage'];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SpecialistDetailScreen(
        specialistId: specialist['_id'], // Pass the specialist ID
      ),
    ),
  );
},
                  child: Column(
                    children: [
                      Image.network(
                        image,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        specialization,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
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
