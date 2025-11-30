// lib/widgets/common.dart (ОНОВЛЕНО)

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
            padding: const EdgeInsets.all(20), // Збільшений відступ
            child: body,
          ),
        ),
        floatingActionButton: fab,
      );
}

class AppTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType type;
  final bool obscure;
  final bool enabled;

  const AppTextField({
    required this.hint,
    this.controller,
    this.type = TextInputType.text,
    this.obscure = false,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        enabled: enabled,
        // Використовуємо декорації з теми
        decoration: InputDecoration(
          labelText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        style: const TextStyle(fontSize: 16),
      );
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color color;

  const AppButton({
    required this.text,
    required this.onTap,
    this.color = const Color(0xFF455A64), // Dark Grey-Blue
    super.key,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
}