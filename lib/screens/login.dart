// lib/screens/login.dart

import 'package:flutter/material.dart';
import '../widgets/common.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;
  const LoginPage({required this.authService, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    final res = await widget.authService.login(email: _emailC.text, password: _passC.text);
    if (!res.success) {
      setState(() => _error = res.message);
      return;
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home', arguments: res.user);
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        title: 'Sign In', // Перекладено
        body: Center( 
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 30),
                const Text( // Перекладено
                  'Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF455A64)),
                ),
                const SizedBox(height: 25),
                
                AppTextField(hint: 'Email', controller: _emailC, type: TextInputType.emailAddress),
                const SizedBox(height: 15),
                AppTextField(hint: 'Password', controller: _passC, obscure: true),
                const SizedBox(height: 25),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  ),
                
                AppButton(
                  text: 'Sign In', // Перекладено
                  onTap: _onSignIn,
                ),
                
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text( // Перекладено
                    'Create an account',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}