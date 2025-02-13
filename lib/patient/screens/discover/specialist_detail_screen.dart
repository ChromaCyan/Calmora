import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/universal/chat/screen/chat_screen.dart';
import 'package:armstrong/widgets/forms/appointment_booking_form.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/patient/blocs/profile/profile_bloc.dart';
import 'package:armstrong/patient/blocs/profile/profile_event.dart';
import 'package:armstrong/patient/blocs/profile/profile_state.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/buttons/specialist_action_button.dart';
import 'package:armstrong/widgets/cards/specialist_bio_card.dart';
import 'package:armstrong/widgets/buttons/toggle_button.dart';
import 'package:armstrong/patient/screens/discover/contact_info_card.dart';
import 'package:armstrong/patient/screens/discover/pro_deets_card.dart';

class SpecialistDetailScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistDetailScreen({Key? key, required this.specialistId})
      : super(key: key);

  @override
  State<SpecialistDetailScreen> createState() => _SpecialistDetailScreenState();
}

class _SpecialistDetailScreenState extends State<SpecialistDetailScreen> {
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool showContactInfo = true;

  @override
  void initState() {
    super.initState();
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(FetchSpecialistDetailsEvent(widget.specialistId));
  }

  void _bookAppointment(BuildContext context, String specialistId) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: BlocProvider.of<AppointmentBloc>(context),
          child: AppointmentBookingForm(specialistId: specialistId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: "Specialist Details",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SpecialistDetailsLoaded) {
            final specialist = state.specialistDetails;

            // Extract specialist details
            final firstName =
                specialist['firstName'] ?? 'No first name available';
            final lastName = specialist['lastName'] ?? 'No last name available';
            final name = '$firstName $lastName';
            final specialization = specialist['specialization'] ?? 'Unknown';
            final bio = specialist['bio'] ?? 'No bio available.';
            final profileImage = specialist['profileImage'] ?? '';
            final email = specialist['email'] ?? 'No email available';
            final phoneNumber =
                specialist['phoneNumber'] ?? 'No phone number available';
            final availability = specialist['availability'] ?? 'Unknown';
            final yearsOfExperience = specialist['yearsOfExperience'] ?? 0;
            final languagesSpoken = specialist['languagesSpoken'] ?? [];
            final licenseNumber =
                specialist['licenseNumber'] ?? 'Not available';
            final reviews = specialist['reviews'] ?? [];

            return BlocListener<AppointmentBloc, AppointmentState>(
              listener: (context, state) {
                if (state is AppointmentBooked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment booked successfully!'),
                    ),
                  );
                } else if (state is AppointmentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message ?? 'An error occurred!'),
                      backgroundColor: Colors.red, // Make the error stand out
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
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
                    SpecialistBioSection(bio: bio),

                    const SizedBox(height: 16),

                    // Contact Information
                    Container(
                      height: MediaQuery.of(context).size.height * 0.30, // 35% of screen height

                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // Matches theme
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Toggle Buttons
                          ToggleButton(
                            onToggle: (isContactInfo) {
                              setState(() {
                                showContactInfo = isContactInfo;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Display the selected section
                          Expanded(
                            child: SingleChildScrollView(
                              child: showContactInfo
                                  ? ContactInfoCard(
                                      email: specialist['email'] ?? 'No email',
                                      phoneNumber: specialist['phoneNumber'] ?? 'No phone',
                                    )
                                  : ProDeetsCard(
                                      yearsOfExperience: specialist['yearsOfExperience'] ?? 0,
                                      languagesSpoken: specialist['languagesSpoken'] ?? [],
                                      licenseNumber: specialist['licenseNumber'] ?? 'N/A',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Availability
                    _buildSectionTitle('Availability:'),
                    Text(
                      availability,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: availability == 'Available'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // // Reviews
                    // _buildSectionTitle('Reviews'),
                    // if (reviews.isEmpty) const Text('No reviews yet.'),
                    // if (reviews.isNotEmpty)
                    //   Column(
                    //     children: reviews.map<Widget>((review) {
                    //       return ListTile(
                    //         leading:
                    //             const Icon(Icons.person, color: Colors.blue),
                    //         title: Text(review['reviewerName'] ?? 'Anonymous'),
                    //         subtitle: Text(review['comment'] ?? 'No comment'),
                    //         trailing: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: List.generate(
                    //             5,
                    //             (index) => Icon(
                    //               Icons.star,
                    //               color: index < (review['rating'] ?? 0)
                    //                   ? Colors.amber
                    //                   : Colors.grey,
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     }).toList(),
                    //   ),
                    // const SizedBox(height: 24),

                    // Action Buttons
                    SpecialistActionButtons(
                      specialistId: widget.specialistId,
                      name: name,
                      onBookAppointment: () => _bookAppointment(context, widget.specialistId),
                    ),
                  ],
                ),
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
