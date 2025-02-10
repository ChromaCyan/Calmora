import 'package:armstrong/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpecialistAppDrawer extends StatelessWidget {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SpecialistAppDrawer({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'jwt');
    await Supabase.instance.client.auth.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: buttonColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 45), 
            _buildListTile(
              icon: Icons.logout,
              text: 'Logout',
              onTap: () async {
                await _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}
