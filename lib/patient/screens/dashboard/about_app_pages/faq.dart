import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/search.dart';

class FrequentlyAskedQuestions extends StatefulWidget {
  const FrequentlyAskedQuestions({super.key});

  @override
  State<FrequentlyAskedQuestions> createState() =>
      _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> {
  // Keeps track of which FAQ is expanded
  final Map<String, bool> isExpandedMap = {};

  // Search text controller
  final TextEditingController _searchController = TextEditingController();

  // All FAQs
  final List<Map<String, String>> faqData = [
    {
      'question': 'How do I reset my password?',
      'answer':
          'To reset your password, first log out of your account to return to the login page. On the login screen, tap "Forgot Password?" and enter your registered email address. You’ll receive a One-Time Password (OTP) via email. Once you receive it, enter the OTP, then set and confirm your new password.'
    },
    {
      'question': 'Can I use the app offline?',
      'answer':
          'No. Most features require an internet connection. You may still see locally stored data from before you went offline, but syncing, updates, and chat features will not work without an active internet connection.'
    },
    {
      'question': 'How do I start a conversation with a specialist?',
      'answer':
          'To start chatting with a specialist, navigate to the "Discovery" page (next to the Dashboard). You can filter or browse specialists based on your needs. Tap on a specialist’s profile, then press the "Message" button to begin your conversation.'
    },
    {
      'question': 'Where can I see my chat history?',
      'answer':
          'You can view your previous conversations by navigating to the "Chat" page, or by tapping the chat icon on the navigation bar. There, you’ll find all the specialists you’ve previously chatted with.'
    },
    {
      'question': 'How do I book an appointment?',
      'answer': 'You can book or schedule an appointment in two ways:\n\n'
          '1. From the Discovery page:\n'
          '- Navigate to "Discovery".\n'
          '- Find and tap the specialist you wish to book.\n'
          '- Tap their profile and press the "Schedule" button.\n\n'
          '2. From the Chat page:\n'
          '- Open the conversation with the specialist you want to book.\n'
          '- Tap the "Schedule" button at the top of the chat screen.\n\n'
          'Once booked, you can check the status of your appointment (accepted or rejected) on the "Appointments" page, located next to the chat icon on the navigation bar.'
    },
    {
      'question':
          'Can I see the history of the successful appointments I have made?',
      'answer':
          'Yes. You can view your completed appointments by going to your Profile (upper-left corner of the screen). Tap the clock icon on the left side to open your "Completed Appointments" list.'
    },
    {
      'question': 'How does the AI chatbot work?',
      'answer': 'Our AI chatbot serves as a helpful assistant to guide you through various features and provide general emotional support. It can help with:\n\n'
          '- Getting quick guidance on mild concerns.\n'
          '- Offers as a conversation companion and providing wellness tips and advice.\n\n'
          'Please note that while the chatbot can provide helpful insights, it has limitations.\n\n'
          '- It can only be a conversation AI that can provide wellness tips\n'
          '- It will not give you diagnosis for your mental health problems.\n\n' 
          'For more serious or ongoing concerns, You should connect with a qualified specialist in this application.'
    },
    {
      'question':
          'Are my chats with the specialist and AI chatbot secure and safe',
      'answer':
          'Yes. All your conversations with specialists are only accessible to you and the specialist you are communicating with.\n\n'
              'As for the AI chatbot, it does not retain or store any conversation history. Once you leave or navigate back from the chat screen, the session is cleared. This ensures your privacy and keeps your data secure.'
    },
  ];

  // Filtered FAQs based on search text
  List<Map<String, String>> get filteredFaqData {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return faqData;
    return faqData
        .where((faq) =>
            faq['question']!.toLowerCase().contains(query) ||
            faq['answer']!.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Help Center'),
      //   backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
      //   elevation: 0,
      // ),
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Frequently Asked Questions",
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
          /// Background
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.fill,
          ),

          /// Blur overlay
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          /// Scrollable foreground content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.asset(
                      'images/help_center.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: Text(
                        "Got Questions? We've got answers",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: CustomSearchBar(
                    hintText: 'Search',
                    searchController: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // FAQ list (no Expanded anymore)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: filteredFaqData.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text(
                                'No results found.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ]
                        : filteredFaqData
                            .map((faq) => _buildFAQItem(
                                  faq['question']!,
                                  faq['answer']!,
                                  theme,
                                ))
                            .toList(),
                  ),
                ),

                const SizedBox(height: 50), // padding at bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable widget for each FAQ card
  Widget _buildFAQItem(String title, String description, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpandedMap[title] = !(isExpandedMap[title] ?? false);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            /// Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(
                  (isExpandedMap[title] ?? false)
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 20,
                ),
              ],
            ),

            /// Expanding answer text
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: (isExpandedMap[title] ?? false)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
