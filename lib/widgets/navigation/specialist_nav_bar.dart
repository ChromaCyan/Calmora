import 'dart:ui';
import 'package:flutter/material.dart';

class SpecialistBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final int notificationCount;
  final int chatNotificationCount;

  const SpecialistBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.notificationCount = 0,
    this.chatNotificationCount = 0,
  }) : super(key: key);

  Widget _buildBadge(BuildContext context, int count) {
    final theme = Theme.of(context);
    if (count <= 0) return const SizedBox.shrink();

    return Positioned(
      right: -6,
      top: -6,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          shape: BoxShape.circle,
        ),
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        child: Center(
          child: Text(
            '$count',
            style: TextStyle(
              color: theme.colorScheme.onError,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_filled, "Home", 0, false),
                _buildNavItem(context, Icons.newspaper, "Articles", 1, false),
                _buildNavItem(context, Icons.message_outlined, "Messages", 2, true, chatNotificationCount),
                _buildNavItem(context, Icons.date_range, "Timeslot", 3, false),
                _buildNavItem(context, Icons.checklist, "Appointments", 4, true, notificationCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    bool hasBadge, [
    int badgeCount = 0,
  ]) {
    final theme = Theme.of(context);
    final bool isSelected = selectedIndex == index;

    Widget iconWidget = Icon(
      icon,
      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
    );

    if (hasBadge && badgeCount > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          _buildBadge(context, badgeCount),
        ],
      );
    }

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          children: [
            iconWidget,
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
