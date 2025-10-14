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
          'To reset your password, you can do so, by logging out first which will navigate you to the login page, on the login page, tap on the "Forgot Password?" button. Enter a valid email address, wait for the OTP that was sent to the email you entered to arrive, once received, enter the valid OTP, and enter your New Password and Confirm it.'
    },
    {
      'question': 'Can I use the app offline?',
      'answer':
          'No, some features are available offline. However, for syncing data and updates, it can lead to failures when offline, therefore an internet connection is required.'
    },
    {
      'question': 'How do I start a convo with a specialist?',
      'answer':
          'To chat a specialist, you can find them by navigating to the "Discovery" page, the page next to Dashboard.\n\nFeel free to categorize them to allign it with what you seek, choose and tap one of them then press the "Message" button, and start chatting with them.'
    },
    {
      'question': 'Where can I see my chats history?',
      'answer':
          "To see your chat history, you can simply navigate to the 'Chat' page, the page next to the 'Discovery' page.\n\nAnd there, you will see all the specialists that you've previousely chatted."
    },
    {
      'question': 'How do I book an appointment?',
      'answer':
          "To book or schedule an appointment with a specialists, you can do it two ways.\n\n1:\n- Navigate to Discovery.\n- Find the specialist you want to book an appointment to.\n- Tap their profile.\n- And press the 'Schedule' button.\n\n2:\n- Navigate to Chat.\n- Open the conversation of the specialist you have chatted whom you want to book an appointment to.\n- And above is the button where you can schedule an appointment.\n\nOnce you have successfully booked your appointment, you view its status if the specialist has accepted or rejected your appointment by navigating to the 'Appointment' page on the very last page next to 'Chat'."
    },
    {
      'question': 'Can I see the history of the successful appointments that I have made?',
      'answer':
          "Yes, you can see it, simply go to your profile on the upper-left corner of your screen, and you will see an clock icon on the left side, tap it and you will see your Completed Appointments."
    },
    {
      'question': 'How does the AI chatbot work?',
      'answer':
          "Our AI chatbot works as a basic assitance that can help guide you through your needs and convenience on certain topics, such as:\n\n- You want to know the features that you can find on the app.\n- You need quick a response on a serious topic that's not yet severe.\n- And in case you are not yet sure which specialist to reach out, our chatbot can help you to address your current state, however, some limitations are applied and it is still advisable to reach out to a specialist.\n\nYou also ask the chatbot itself regarding what it can provide, please feel free to do so."
    },
    {
      'question': 'Are my all my chats with the specialist and the AI chatbot secured, safe, and encrypted?',
      'answer':
          "..."
    },
    {
      'question': 'Can I delete the conversation with the specialist I have previously chatted?',
      'answer':
          "..."
    },
    {
      'question': 'How do I delete my account?',
      'answer':
          "To delete your account, you will have to send an Account Deletion request letter, and our team will review your request for 7 days before proceeding.\n\nTo do so, simply... ..."
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
          "Help Center",
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
                          color: theme.colorScheme.onSurface
                        ),
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
