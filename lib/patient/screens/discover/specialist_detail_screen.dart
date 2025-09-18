import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/universal/chat/screen/chat_screen.dart';
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
import 'dart:ui';

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
          value: BlocProvider.of<TimeSlotBloc>(context),
          child: AppointmentBookingForm(specialistId: specialistId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        final userId = await _storage.read(key: 'userId');
        if (userId != null) {
          context.read<SpecialistBloc>().add(FetchSpecialists());
        }
        return true; 
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.transparent,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: () async {
              final storage = FlutterSecureStorage();
              final userId = await storage.read(key: 'userId');

              if (userId != null) {
                context.read<SpecialistBloc>().add(FetchSpecialists());
              }

              Navigator.pop(context);
            },
          ),
          title: Text(
            "Specialist Details",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            /// Background image
            Image.asset(
              "images/login_bg_image.png",
              fit: BoxFit.cover,
            ),

            /// Frosted glass blur
            Container(
              color: theme.colorScheme.surface.withOpacity(0.6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: const SizedBox.expand(),
              ),
            ),

            /// Main content
            BlocBuilder<SpecialistBloc, SpecialistState>(
              builder: (context, state) {
                if (state is SpecialistLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SpecialistDetailLoaded) {
                  final specialist = state.specialist;

                  final firstName =
                      specialist.firstName ?? 'No first name available';
                  final lastName =
                      specialist.lastName ?? 'No last name available';
                  final name = '$firstName $lastName';
                  final specialization = specialist.specialization ?? 'Unknown';
                  final bio = specialist.bio ?? 'No bio available.';
                  final profileImage = specialist.profileImage ?? '';
                  final email = specialist.email ?? 'No email available';
                  final phoneNumber =
                      specialist.phoneNumber ?? 'No phone number available';

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
                            duration: Duration(seconds: 3),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// Profile Image and Name
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 80,
                                  backgroundImage: profileImage.isNotEmpty
                                      ? NetworkImage(profileImage)
                                      : const AssetImage(
                                              'images/no_profile.png')
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

                          /// Availability
                          Center(
                            child: _buildAvailabilityCard(context,
                                specialist.availability ?? 'Unavailable'),
                          ),

                          const SizedBox(height: 5),

                          /// Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _bookAppointment(
                                      context, widget.specialistId),
                                  icon: const Icon(Icons.calendar_today,
                                      size: 22),
                                  label: const Text(
                                    "Schedule",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final token =
                                        await _storage.read(key: 'token');
                                    if (token != null) {
                                      try {
                                        final existingChatId =
                                            await _apiRepository
                                                .getExistingChatId(
                                                    widget.specialistId, token);
                                        final newChatId = existingChatId ??
                                            await _apiRepository.createChat(
                                                widget.specialistId, token);

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
                                      } catch (e) {
                                        print('Error starting chat: $e');
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.message, size: 22),
                                  label: const Text(
                                    "Message",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),
                          const Divider(thickness: 1, color: Colors.grey),
                          const SizedBox(height: 15),

                          /// Professional details
                          _SectionCard(
                            title: "Professional Details",
                            children: [
                              ProDeetsCard(
                                yearsOfExperience:
                                    specialist.yearsOfExperience ?? 0,
                                languagesSpoken:
                                    specialist.languagesSpoken ?? [],
                                location: specialist.location ?? 'Unknown',
                                clinic: specialist.clinic ?? 'Not Provided',
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// Contact
                          _SectionCard(
                            title: "Contact Information",
                            children: [
                              ContactInfoCard(
                                email: email,
                                phoneNumber: phoneNumber,
                              )
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// Bio
                          _SectionCard(
                            title: "Biography",
                            children: [
                              Text(
                                bio.isNotEmpty ? bio : "No bio available.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color,
                                  height: 1.4,
                                ),
                              ),
                            ],
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
          ],
        ),
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
Widget _buildAvailabilityCard(BuildContext context, String availability) {
  final isAvailable = availability == 'Available';
  final theme = Theme.of(context);

  final Color borderColor = isAvailable ? Colors.green : Colors.red;

  final Color textColor = isAvailable ? Colors.green : Colors.red;

  final IconData icon = isAvailable ? Icons.check_circle : Icons.cancel;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.7), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            availability,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.3),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        //],
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.3) // light border in dark mode
              : Colors.black.withOpacity(0.2), // dark border in light mode
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// --- Reusable Info Row ---
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "$label: $value",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

/// --- Chip Tag ---
class _ChipTag extends StatelessWidget {
  final String label;
  const _ChipTag({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.blueAccent.withOpacity(0.15),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
