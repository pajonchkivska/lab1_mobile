import 'package:flutter/material.dart';
import '../widgets/common.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
        title: 'Profile',
        body: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ірина Пайончківська',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            AppButton(
              text: 'Log out',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      );
}
