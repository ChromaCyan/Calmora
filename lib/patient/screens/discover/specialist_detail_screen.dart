import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/widgets/forms/appointment_booking_form.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/patient/blocs/specialist_list/specialist_bloc.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/buttons/specialist_action_button.dart';
import 'package:armstrong/widgets/cards/specialist_bio_card.dart';
import 'package:armstrong/widgets/buttons/toggle_button.dart';
import 'package:armstrong/widgets/cards/contact_info_card.dart';
import 'package:armstrong/widgets/cards/profession_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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
    final specialistBloc = BlocProvider.of<SpecialistBloc>(context);
    specialistBloc.add(FetchSpecialistDetails(widget.specialistId));
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
        onBackPressed: () async {
          final storage = FlutterSecureStorage();
          final userId = await storage.read(key: 'userId');

          if (userId != null) {
            context.read<SpecialistBloc>().add(FetchSpecialists());
          }

          Navigator.pop(context);
        },
      ),
      body: BlocBuilder<SpecialistBloc, SpecialistState>(
        builder: (context, state) {
          if (state is SpecialistLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SpecialistDetailLoaded) {
            final specialist = state.specialist;

            // Extract specialist details
            final firstName = specialist.firstName ?? 'No first name available';
            final lastName = specialist.lastName ?? 'No last name available';
            final name = '$firstName $lastName';
            final specialization = specialist.specialization ?? 'Unknown';
            final bio = specialist.bio ?? 'No bio available.';
            final profileImage = specialist.profileImage ?? '';
            final email = specialist.email ?? 'No email available';
            final phoneNumber =
                specialist.phoneNumber ?? 'No phone number available';
            final availability = specialist.availability ?? 'Unknown';
            final yearsOfExperience = specialist.yearsOfExperience ?? 0;
            final languagesSpoken = specialist.languagesSpoken ?? [];
            final licenseNumber = specialist.licenseNumber ?? 'Not available';
            final location = specialist.location ?? 'Unknown';
            final clinic = specialist.clinic ?? 'Unknown';

            return BlocListener<AppointmentBloc, AppointmentState>(
              listener: (context, state) {
                if (state is AppointmentBooked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Appointment Booked successfully!',
                        message:
                            'Your appointment has been successfully booked!',
                        contentType: ContentType.success,
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (state is AppointmentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Error!',
                        message: state.message.isNotEmpty
                            ? state.message
                            : 'An error has occurred while booking your appointment, please try again.',
                        contentType: ContentType.failure,
                      ),
                      duration: const Duration(seconds: 3),
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
                                : const AssetImage('images/armstrong_transparent.png')
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.mapPin,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.cross,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          clinic,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bio
                    SpecialistBioSection(bio: bio),

                    const SizedBox(height: 16),

                    // Contact Information
                    Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                                      email: specialist.email ?? 'No email',
                                      phoneNumber:
                                          specialist.phoneNumber ?? 'No phone',
                                    )
                                  : ProDeetsCard(
                                      yearsOfExperience:
                                          specialist.yearsOfExperience ?? 0,
                                      languagesSpoken:
                                          specialist.languagesSpoken ?? [],
                                      licenseNumber:
                                          specialist.licenseNumber ?? 'N/A',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Availability
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Availability:'),
                        _buildAvailabilityCard(availability),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    SpecialistActionButtons(
                      specialistId: widget.specialistId,
                      name: name,
                      onBookAppointment: () =>
                          _bookAppointment(context, widget.specialistId),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is SpecialistError) {
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

// Availability Section as a Card
Widget _buildAvailabilityCard(String availability) {
  Color bgColor =
      availability == 'Available' ? Colors.green[100]! : Colors.red[100]!;
  Color textColor =
      availability == 'Available' ? Colors.green[800]! : Colors.red[800]!;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              availability == 'Available' ? Icons.check_circle : Icons.cancel,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              availability,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
