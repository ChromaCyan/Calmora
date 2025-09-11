import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final int notificationCount;
  final int chatNotificationCount;
  final bool showcaseCompleted; 
  final VoidCallback completeShowcase; 

  final GlobalKey homeKey;
  final GlobalKey discoverKey;
  final GlobalKey chatKey;
  final GlobalKey appointmentsKey;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.notificationCount = 0,
    this.chatNotificationCount = 0,
    required this.showcaseCompleted, 
    required this.completeShowcase, 
    required this.homeKey,
    required this.discoverKey,
    required this.chatKey,
    required this.appointmentsKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              Icons.home_filled,
              "Home",
              0,
              colorScheme.primary,
              homeKey,
              context,
              "Dashboard with personalized recommended articles, add your mood, and view your upcoming appointments"),
          _buildNavItem(
              Icons.handshake_outlined,
              "Discover",
              1,
              colorScheme.primary,
              discoverKey,
              context,
              "Browse for articles and specialists you can chat and book an appointment."),
          _buildNavItemWithBadge(
              Icons.message_outlined,
              "Messages",
              2,
              chatNotificationCount,
              colorScheme.primary,
              colorScheme.secondary,
              chatKey,
              context,
              "View existing chats you had with a specialist"),
          _buildNavItemWithBadge(
              Icons.checklist,
              "Appointments",
              3,
              notificationCount,
              colorScheme.primary,
              colorScheme.secondary,
              appointmentsKey,
              context,
              "Check your existing appointment status"),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon,
      String label,
      int index,
      Color primaryColor,
      GlobalKey key,
      BuildContext context,
      String description) {
    bool isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        onItemTapped(index);
        if (!showcaseCompleted) {
          completeShowcase(); 
        }
      },
      child: Showcase(
        key: key,
        description: description,
        textColor: theme.colorScheme.onPrimary,
        tooltipBackgroundColor: theme.colorScheme.primary,
        targetPadding: const EdgeInsets.all(16),
        targetShapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        descTextStyle: TextStyle(
          fontSize: 18,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : Colors.grey,
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
  IconData icon,
  String label,
  int index,
  int count,
  Color primaryColor,
  Color badgeColor,
  GlobalKey key,
  BuildContext context,
  String description,
) {
  bool isSelected = selectedIndex == index;
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: () {
      onItemTapped(index);
      if (!showcaseCompleted) {
        completeShowcase();
      }
    },
    child: Showcase(
      key: key,
      description: description,
      textColor: theme.colorScheme.onPrimary,
      tooltipBackgroundColor: theme.colorScheme.primary,
      targetPadding: const EdgeInsets.all(16),
      targetShapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      descTextStyle: TextStyle(
        fontSize: 18,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryColor : Colors.grey,
                ),
                if (count > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: badgeColor, shape: BoxShape.circle),
                      child: Text('$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
}