// lib/screens/register.dart

import 'package:flutter/material.dart';
import '../widgets/common.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final AuthService authService;
  const RegisterPage({required this.authService, super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _onCreate() async {
    final res = await widget.authService.register(
      name: _nameC.text,
      email: _emailC.text,
      password: _passC.text,
    );
    if (!res.success) {
      setState(() => _error = res.message);
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar( // Перекладено
        const SnackBar(content: Text('Registration success — you can login')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        title: 'Register Account', // Перекладено
        body: Center( 
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 30),
                const Text( // Перекладено
                  'Create Your Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF455A64)),
                ),
                const SizedBox(height: 25),

                AppTextField(hint: 'Name', controller: _nameC),
                const SizedBox(height: 15),
                AppTextField(hint: 'Email', controller: _emailC, type: TextInputType.emailAddress),
                const SizedBox(height: 15),
                AppTextField(hint: 'Password', controller: _passC, obscure: true),
                const SizedBox(height: 30),
                
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  ),
                
                AppButton(
                  text: 'Create account', // Перекладено
                  onTap: _onCreate,
                ),
              ],
            ),
          ),
        ),
      );
}