// lib/screens/profile.dart

import 'package:flutter/material.dart';
import '../widgets/common.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  final AuthService authService;
  const ProfilePage({required this.authService, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController? _nameC;
  TextEditingController? _emailC;
  TextEditingController? _passC;

  User? _initialUser;
  String? _error;

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is User) {
      _initialUser = arg;
    }

    _nameC = TextEditingController(text: _initialUser?.name ?? '');
    _emailC = TextEditingController(text: _initialUser?.email ?? '');
    _passC = TextEditingController(text: _initialUser?.password ?? '');

    _loaded = true;
  }

  @override
  void dispose() {
    _nameC?.dispose();
    _emailC?.dispose();
    _passC?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameC!.text;
    final email = _emailC!.text;
    final pass = _passC!.text;
    final oldEmail = _initialUser?.email;

    if (oldEmail == null) {
      return setState(() => _error = 'Cannot find initial user email.');
    }
    
    setState(() => _error = null);

    final res = await widget.authService.updateProfile(
      oldEmail: oldEmail,
      name: name,
      email: email,
      password: pass,
    );
    
    if (!res.success) {
      return setState(() => _error = res.message);
    }

    setState(() {
      _initialUser = res.user;
      _error = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved changes'))); // Перекладено
    }
  }

  Future<void> _delete() async {
    final email = _initialUser?.email ?? _emailC!.text.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog( // Перекладено
        title: const Text('Delete account?'),
        content: const Text('This will remove the user from local storage.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await widget.authService.deleteUser(email);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: 'Profile Settings', // Перекладено
      body: Center( 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                child: Icon(Icons.person, size: 45, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 35),
              
              AppTextField(hint: 'Name', controller: _nameC!),
              const SizedBox(height: 15),
              AppTextField(hint: 'Email', controller: _emailC!, type: TextInputType.emailAddress),
              const SizedBox(height: 15),
              AppTextField(hint: 'Password', controller: _passC!, obscure: true),
              const SizedBox(height: 30),
              
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                ),
              
              AppButton(text: 'Save Changes', onTap: _save), // Перекладено
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Log Out', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)), // Перекладено
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Delete Account', // Перекладено
                onTap: _delete,
                color: Colors.red.shade400, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}