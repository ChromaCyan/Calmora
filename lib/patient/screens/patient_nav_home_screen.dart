import 'package:armstrong/universal/notification/notification_screen.dart';
import 'package:armstrong/universal/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/nav_cubit.dart';
import 'package:armstrong/patient/screens/pages.dart';
import 'package:armstrong/widgets/navigation/nav_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:armstrong/services/socket_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _userId;
  int _unreadCount = 0;

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _discoverKey = GlobalKey();
  final GlobalKey _chatKey = GlobalKey();
  final GlobalKey _appointmentsKey = GlobalKey();

  bool _showcaseCompleted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadUserId();
    _init();
    _checkShowcaseStatus();
  }

  Future<void> _init() async {
    final userId = await _storage.read(key: 'userId');
    final token = await _storage.read(key: 'token');

    if (userId != null && token != null) {
      setState(() => _userId = userId);

      SocketService().connect(token, userId);

      SocketService().onNotificationReceived = (data) async {
        print("🔔 Notification event received: $data");
        if (!mounted) return;

        setState(() {
          _unreadCount++;
        });
      };

      await _fetchUnreadNotificationsCount();
    }
  }

  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');

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

  // Method to check if the showcase has been completed
  Future<void> _checkShowcaseStatus() async {
    final showcaseCompleted = await _storage.read(key: 'showcase_completed');
    setState(() {
      _showcaseCompleted = showcaseCompleted == 'true';
    });

    // Start showcase if it hasn't been completed
    if (!_showcaseCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          _homeKey,
          _discoverKey,
          _chatKey,
          _appointmentsKey,
        ]);
      });
    }
  }

  // Method to mark the showcase as completed
  Future<void> _completeShowcase() async {
    await _storage.write(key: 'showcase_completed', value: 'true');
    setState(() {
      _showcaseCompleted = true;
    });
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
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 5, right: 5),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
                    color: theme.iconTheme.color ?? Colors.black,
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
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$_unreadCount',
                                style: const TextStyle(
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
              DashboardScreen(),
              DiscoverScreen(),
              ChatListScreen(),
              _userId != null
                  ? AppointmentListScreen(patientId: _userId!)
                  : Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onTabSelected,
          showcaseCompleted: _showcaseCompleted,
          completeShowcase: _completeShowcase,
          homeKey: _homeKey,
          discoverKey: _discoverKey,
          chatKey: _chatKey,
          appointmentsKey: _appointmentsKey,
        ),
      ),
    );
  }

  String _getDynamicTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Discover';
      case 2:
        return 'Chat';
      case 3:
        return 'Your Appointments';
      default:
        return 'Home';
    }
  }
}
