import 'package:flutter/material.dart';
import '../widgets/common.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
        title: 'Login',
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextField(hint: 'Email'),
            const SizedBox(height: 12),
            AppTextField(hint: 'Password'),
            const SizedBox(height: 18),
            AppButton(
              text: 'Sign in',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/home'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Register'),
            ),
          ],
        ),
      );
}
