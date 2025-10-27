import 'package:armstrong/specialist/screens/appointments/appointment_screen.dart';
import 'package:armstrong/specialist/screens/appointments/timeslot_screen.dart';
import 'package:armstrong/universal/chat/screen/chat_list_screen.dart';
import 'package:armstrong/universal/notification/notification_screen.dart';
import 'package:armstrong/universal/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/nav_cubit.dart';
import 'package:armstrong/specialist/screens/pages.dart';
import 'package:armstrong/widgets/navigation/specialist_nav_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/socket_service.dart';
import 'dart:ui';
import 'package:armstrong/config/global_loader.dart';

class SpecialistHomeScreen extends StatefulWidget {
  final int initialTabIndex;
  const SpecialistHomeScreen({Key? key, this.initialTabIndex = 0})
      : super(key: key);

  @override
  _SpecialistHomeScreenState createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends State<SpecialistHomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _userId;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadUserId();
    _init();
  }

  Future<void> _init() async {
    final userId = await _storage.read(key: 'userId');
    final token = await _storage.read(key: 'token');

    if (userId != null && token != null) {
      setState(() => _userId = userId);

      SocketService().connect(token, userId);
      SocketService().registerUserRoom(userId);

      SocketService().onNotificationReceived = (data) async {
        if (!mounted) return;
        setState(() {
          _unreadCount++;
        });
        print('🔔 [SOCKET] Notification received. Unread: $_unreadCount');
      };

      await _fetchUnreadNotificationsCount();
    }
  }

  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');
    print('📦 [LOAD] Loaded userId: $userId');

    setState(() {
      _userId = userId;
    });

    if (_userId != null) {
      await _fetchUnreadNotificationsCount();
      SocketService().onNotificationReceived = (data) async {
        if (!mounted) return;
        await _fetchUnreadNotificationsCount();
      };
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    try {
      List<Map<String, dynamic>> notifications =
          await ApiRepository().getNotifications(_userId!);
      int unreadCount = notifications.where((n) => n["isRead"] == false).length;

      setState(() {
        _unreadCount = unreadCount;
      });
    } catch (e) {
      print("Failed to fetch unread notifications: $e");
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    SocketService().disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => BottomNavCubit(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              kToolbarHeight + MediaQuery.of(context).padding.top + 20),
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 5,
              left: 10,
              right: 10,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: theme.iconTheme.color,
                  size: 28,
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.person_2,
                    size: 28,
                    color: theme.iconTheme.color ??
                        theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
                title: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    _getDynamicTitle(),
                    key: ValueKey<int>(_selectedIndex),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          theme.textTheme.headlineMedium?.color ?? Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications,
                          size: 28,
                          color: theme.iconTheme.color ??
                              theme.colorScheme.onSurfaceVariant,
                        ),
                        if (_unreadCount > 0)
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$_unreadCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push<int>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(
                            onUnreadCountChanged: (count) {
                              setState(() {
                                _unreadCount = count; // instant badge update
                              });
                            },
                          ),
                        ),
                      ).then((selectedTab) {
                        if (selectedTab != null) {
                          _onTabSelected(selectedTab);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // --- 1) Background Image ---
            Positioned.fill(
              child: Image.asset(
                "images/login_bg_image.png",
                fit: BoxFit.cover,
              ),
            ),

            // --- 2) Blur Layer ---
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black
                      .withOpacity(0.2), // adjust opacity/color as needed
                ),
              ),
            ),

            // --- 3) Main Content ---
            SafeArea(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  _userId != null
                      ? SpecialistDashboardScreen(specialistId: _userId!)
                      : Center(
                          child: GlobalLoader.loader,
                        ),
                  _userId != null
                      ? SpecialistArticleScreen(specialistId: _userId!)
                      : Center(
                          child: GlobalLoader.loader,
                        ),
                  ChatListScreen(),
                  _userId != null
                      ? TimeSlotListScreen(specialistId: _userId!)
                      : Center(
                          child: GlobalLoader.loader,
                        ),
                  _userId != null
                      ? SpecialistAppointmentListScreen(specialistId: _userId!)
                      : Center(
                          child: GlobalLoader.loader,
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SpecialistBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onTabSelected,
        ),
      ),
    );
  }

  String _getDynamicTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Articles';
      case 2:
        return 'Chat';
      case 3:
        return 'Time Slot';
      case 4:
        return 'Appointments';
      default:
        return 'Home';
    }
  }
}

class SpecialistNavHelper {
  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_SpecialistHomeScreenState>();
    state?._onTabSelected(index);
  }
}
