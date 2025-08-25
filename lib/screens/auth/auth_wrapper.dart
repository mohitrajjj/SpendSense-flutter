import 'package:flutter/material.dart';
import '../dashboard_page.dart';
import '../../helpers/auth_helper.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    AuthHelper.authStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isLoggedIn = status;
        });
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthHelper.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLoggedIn) {
      return const DashboardPage();
    } else {
      return const LoginScreen();
    }
  }
}
