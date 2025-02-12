import 'package:armstrong/specialist/screens/appointments/appointment_screen.dart';
import 'package:armstrong/universal/chat/screen/chat_list_screen.dart';
import 'package:armstrong/universal/notification/notification_screen.dart';
import 'package:armstrong/universal/profile/profile_screen.dart';
import 'package:armstrong/widgets/navigation/specialist_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/nav_cubit.dart';
import 'package:armstrong/specialist/screens/pages.dart';
import 'package:armstrong/widgets/navigation/specialist_nav_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';

class SpecialistHomeScreen extends StatefulWidget {
  const SpecialistHomeScreen({Key? key}) : super(key: key);

  @override
  _SpecialistHomeScreenState createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends State<SpecialistHomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _userId;
  int _unreadCount = 0; // Track unread notifications

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
    if (_userId != null) {
      await _fetchUnreadNotificationsCount();
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    return BlocProvider(
      create: (context) => BottomNavCubit(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
           child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: theme.iconTheme.color, 
                size: 28.0,
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.person_2,
                  size: 28,
                  color: theme.iconTheme.color ??
                      Colors.black, 
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
              ),
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
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
                      const Icon(Icons.notifications, size: 28),
                      if (_unreadCount > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '$_unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(),
                      ),
                    ).then((value) {
                      if (_userId != null) {
                        _fetchUnreadNotificationsCount();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              SpecialistDashboardScreen(),
              _userId != null
                  ? SpecialistArticleScreen(specialistId: _userId!)
                  : Center(child: CircularProgressIndicator()),
              ChatListScreen(),
              _userId != null
                  ? SpecialistAppointmentListScreen(specialistId: _userId!)
                  : Center(child: CircularProgressIndicator()),
            ],
          ),
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
        return 'Appointment';
      default:
        return 'Home';
    }
  }
}
