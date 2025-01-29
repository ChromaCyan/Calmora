import 'package:armstrong/config/colors.dart';
import 'package:armstrong/widgets/navigation/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/nav_cubit.dart'; 
import 'package:armstrong/patient/screens/pages.dart'; 
import 'package:armstrong/widgets/navigation/nav_bar.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadUserId(); 
  }

  // Method to load the userId from secure storage
  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
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
              iconTheme: const IconThemeData(
                color: Colors.black, 
                size: 28.0,
              ),
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _getDynamicTitle(),
                  key: ValueKey<int>(_selectedIndex),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
        drawer: AppDrawer(), 
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(index);
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