import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/universal/chat/screen/chat_screen.dart';

class SpecialistActionButtons extends StatelessWidget {
  final String specialistId;
  final String name;
  final VoidCallback onBookAppointment;

  const SpecialistActionButtons({
    Key? key,
    required this.specialistId,
    required this.name,
    required this.onBookAppointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ApiRepository _apiRepository = ApiRepository();
    final FlutterSecureStorage _storage = FlutterSecureStorage();

    // Get current theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch, 
      children: [
        // Book Appointment Button
        SizedBox(
          height: 45,
          width: double.infinity, 
          child: ElevatedButton.icon(
            onPressed: onBookAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.calendar_today,
              color: theme.colorScheme.secondary,
            ),
            label: const Text('Book Appointment'),
          ),
        ),

        const SizedBox(height: 10), 

        // Chat with Specialist Button
        SizedBox(
          height: 45,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final token = await _storage.read(key: 'token');
              if (token != null) {
                try {
                  final existingChatId = await _apiRepository.getExistingChatId(specialistId, token);
                  final newChatId = existingChatId ?? await _apiRepository.createChat(specialistId, token);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: newChatId,
                        recipientId: specialistId,
                        recipientName: name,
                      ),
                    ),
                  );
                } catch (e) {
                  print('Error starting chat: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.chat),
            label: const Text('Chat with Specialist'),
          ),
        ),
      ],
    );
  }
}
