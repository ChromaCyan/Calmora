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
      appBar: AppBar(title: Text("Specialist Details")),
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
                    _buildInfoRow(
                        Icons.work, 'Years of Experience: $yearsOfExperience'),
                    _buildInfoRow(Icons.language,
                        'Languages Spoken: ${languagesSpoken.join(", ")}'),
                    _buildInfoRow(
                        Icons.assignment, 'License Number: $licenseNumber'),
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

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _bookAppointment(context, widget.specialistId),
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
                          onPressed: () async {
                            final token = await _storage.read(key: 'token');
                            if (token != null) {
                              try {
                                // Check if a chat already exists
                                final existingChatId =
                                    await _apiRepository.getExistingChatId(
                                        widget.specialistId, token);

                                if (existingChatId != null) {
                                  // Navigate to the existing chat
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        chatId: existingChatId,
                                        recipientId: widget.specialistId,
                                        recipientName: name,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Create a new chat
                                  final newChatId = await _apiRepository
                                      .createChat(widget.specialistId, token);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        chatId: existingChatId ?? newChatId,
                                        recipientId: widget.specialistId,
                                        recipientName: name,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Error starting chat: $e');
                              }
                            }
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
