import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/patient/blocs/profile/profile_bloc.dart';
import 'package:armstrong/patient/blocs/profile/profile_event.dart';
import 'package:armstrong/patient/blocs/profile/profile_state.dart';

class SpecialistDetailScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistDetailScreen({Key? key, required this.specialistId})
      : super(key: key);

  @override
  State<SpecialistDetailScreen> createState() => _SpecialistDetailScreenState();
}

class _SpecialistDetailScreenState extends State<SpecialistDetailScreen> {
  @override
  void initState() {
    super.initState();
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(FetchSpecialistDetailsEvent(widget.specialistId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialist Details'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SpecialistDetailsLoaded) {
            final specialist = state.specialistDetails;

            // Extract specialist details
            final firstName = specialist['firstName'] ?? 'No first name available';
            final lastName = specialist['lastName'] ?? 'No last name available';
            final name = '$firstName $lastName';
            final specialization = specialist['specialization'] ?? 'Unknown';
            final bio = specialist['bio'] ?? 'No bio available.';
            final profileImage = specialist['profileImage'] ?? '';
            final email = specialist['email'] ?? 'No email available';
            final phoneNumber = specialist['phoneNumber'] ?? 'No phone number available';
            final availability = specialist['availability'] ?? 'Unknown';
            final yearsOfExperience = specialist['yearsOfExperience'] ?? 0;
            final languagesSpoken = specialist['languagesSpoken'] ?? [];
            final licenseNumber = specialist['licenseNumber'] ?? 'Not available';
            final reviews = specialist['reviews'] ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image and Name
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          specialization,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bio
                  _buildSectionTitle('Bio'),
                  Text(
                    bio,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Contact Information
                  _buildSectionTitle('Contact Information'),
                  _buildInfoRow(Icons.email, email),
                  _buildInfoRow(Icons.phone, phoneNumber),
                  const SizedBox(height: 16),

                  // Professional Details
                  _buildSectionTitle('Professional Details'),
                  _buildInfoRow(Icons.work, 'Years of Experience: $yearsOfExperience'),
                  _buildInfoRow(Icons.language, 'Languages Spoken: ${languagesSpoken.join(", ")}'),
                  _buildInfoRow(Icons.assignment, 'License Number: $licenseNumber'),
                  const SizedBox(height: 16),

                  // Availability
                  _buildSectionTitle('Availability'),
                  Chip(
                    label: Text(
                      availability,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: availability == 'Available'
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(height: 24),

                  // Reviews
                  _buildSectionTitle('Reviews'),
                  if (reviews.isEmpty)
                    const Text('No reviews yet.'),
                  if (reviews.isNotEmpty)
                    Column(
                      children: reviews.map<Widget>((review) {
                        return ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text(review['reviewerName'] ?? 'Anonymous'),
                          subtitle: Text(review['comment'] ?? 'No comment'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                color: index < (review['rating'] ?? 0)
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          print("Navigate to appointment booking screen");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Book Appointment',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("Start chat with the specialist");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Chat with Specialist',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is ProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No data available.'));
        },
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Helper method to build info rows with icons
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}