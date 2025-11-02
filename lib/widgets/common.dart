import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? fab;

  const AppScaffold({
    required this.title,
    required this.body,
    this.fab,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: body,
          ),
        ),
        floatingActionButton: fab,
      );
}

class AppTextField extends StatelessWidget {
  final String hint;
  final TextInputType type;

  const AppTextField({
    required this.hint,
    this.type = TextInputType.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: hint,
        ),
        keyboardType: type,
      );
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AppButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(text),
        ),
      );
}
