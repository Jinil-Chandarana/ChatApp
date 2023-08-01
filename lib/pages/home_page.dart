import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                authService.signOut();
              },
              child: Text('Sign Out'))),
    );
  }
}
