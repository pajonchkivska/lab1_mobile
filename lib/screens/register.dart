import 'package:flutter/material.dart';
import '../widgets/common.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
        title: 'Register',
        body: SingleChildScrollView(
          child: Column(
            children: [
              AppTextField(hint: 'Name'),
              const SizedBox(height: 12),
              AppTextField(hint: 'Email'),
              const SizedBox(height: 12),
              AppTextField(hint: 'Password'),
              const SizedBox(height: 18),
              AppButton(
                text: 'Create account',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
}
