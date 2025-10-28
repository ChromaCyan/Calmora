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
import 'dart:ui';
import 'package:armstrong/services/socket_service.dart';
import 'package:armstrong/config/global_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:armstrong/helpers/storage_helpers.dart';

class PatientHomeScreen extends StatefulWidget {
  final int initialTabIndex;
  const PatientHomeScreen({Key? key, this.initialTabIndex = 0})
      : super(key: key);

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
    print('🩵 [INIT] PatientHomeScreen initState() called');
    _checkShowcaseStatus();
    _pageController = PageController(initialPage: 0);
    _loadUserId();
    _init();
  }

  Future<void> _init() async {
    final userId = await _storage.read(key: 'userId');
    final token = await _storage.read(key: 'token');
    print('🧠 [INIT] userId=$userId | token=${token != null}');

    if (userId != null && token != null) {
      setState(() => _userId = userId);
      print('✅ [INIT] User ID set: $_userId');

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

  Future<void> _completeShowcase() async {
    print("💾 [SHOWCASE] Completing showcase...");
    await _storage.write(key: 'showcaseCompleted', value: 'true');

    final verify = await _storage.read(key: 'showcaseCompleted');
    print("✅ [SHOWCASE] Showcase saved as completed: $verify");

    setState(() {
      _showcaseCompleted = true;
    });
  }

  Future<void> _checkShowcaseStatus() async {
    print("🟦 [SHOWCASE] Checking showcase status...");
    final value = await _storage.read(key: 'showcaseCompleted');
    final showcaseCompleted = value == 'true';

    print("🟢 [SHOWCASE] Stored value: $showcaseCompleted");

    setState(() {
      _showcaseCompleted = showcaseCompleted;
    });

    if (!showcaseCompleted) {
      print("🚀 [SHOWCASE] Showcase not completed — starting sequence now...");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          _homeKey,
          _discoverKey,
          _chatKey,
          _appointmentsKey,
        ]);
      });
    } else {
      print("✅ [SHOWCASE] Already completed — skipping showcase.");
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
      print('📨 [NOTIF] Unread notifications count: $_unreadCount');
    } catch (e) {
      print("❌ [ERROR] Failed to fetch unread notifications: $e");
    }
  }

  void _onTabSelected(int index) {
    print('📱 [NAV] Switched tab to index: $index');
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
    print('🧹 [DISPOSE] Disposing PatientHomeScreen');
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        '🎨 [BUILD] Building PatientHomeScreen — showcaseCompleted=$_showcaseCompleted');
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
                      Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(
                            onUnreadCountChanged: (count) {
                              setState(() {
                                _unreadCount =
                                    count; 
                              });
                            },
                          ),
                        ),
                      ).then((result) async {
                        if (result != null) {
                          // Handle unread count update
                          if (result["unreadCount"] != null) {
                            setState(
                                () => _unreadCount = result["unreadCount"]);
                          }

                          if (result["selectedTab"] != null) {
                            _onTabSelected(result["selectedTab"]);
                          }
                        }

                        await _fetchUnreadNotificationsCount();
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
            Positioned.fill(
              child: Image.asset(
                "images/login_bg_image.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
            SafeArea(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                children: [
                  DashboardScreen(),
                  DiscoverScreen(),
                  ChatListScreen(),
                  _userId != null
                      ? AppointmentListScreen(patientId: _userId!)
                      : Center(child: GlobalLoader.loader),
                ],
              ),
            ),
          ],
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
        return 'Appointments';
      default:
        return 'Home';
    }
  }
}

class PatientNavHelper {
  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_PatientHomeScreenState>();
    state?._onTabSelected(index);
  }
}
