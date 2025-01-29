import 'package:armstrong/patient/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/patient/blocs/appointment/appointment_state.dart';
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
                      content: Text('Error: ${state.message}'),
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image Section (Hero-like)
                    Container(
                      width: double.infinity,
                      height: 300, // Adjust the height as needed
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage('images/splash/doc1.jpg')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name and Specialization (No card)
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

                    const SizedBox(height: 16),

                    // Bio Section (Not in a card)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        bio,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    // Contact Information Section (Card)
                    _buildSectionCard(
                      title: 'Contact Information',
                      content: Column(
                        children: [
                          _buildInfoRow(Icons.email, email),
                          _buildInfoRow(Icons.phone, phoneNumber),
                        ],
                      ),
                    ),

                    // Professional Details Section (Card)
                    _buildSectionCard(
                      title: 'Professional Details',
                      content: Column(
                        children: [
                          _buildInfoRow(Icons.work,
                              'Years of Experience: $yearsOfExperience'),
                          _buildInfoRow(Icons.language,
                              'Languages Spoken: ${languagesSpoken.join(", ")}'),
                          _buildInfoRow(Icons.assignment,
                              'License Number: $licenseNumber'),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _bookAppointment(context, widget.specialistId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 18),
                              minimumSize: const Size(150, 50),
                            ),
                            child: const Text(
                              'Book Appointment',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final token = await _storage.read(key: 'token');
                              if (token != null) {
                                final existingChatId =
                                    await _apiRepository.getExistingChatId(
                                        widget.specialistId, token);
                                if (existingChatId != null) {
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
                                  final newChatId = await _apiRepository
                                      .createChat(widget.specialistId, token);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        chatId: newChatId,
                                        recipientId: widget.specialistId,
                                        recipientName: name,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 18),
                              minimumSize: const Size(150, 50),
                            ),
                            child: const Text(
                              'Chat with Specialist',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            const SizedBox(height: 8.0),
            content,
          ],
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
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
