import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Text('Biletlerim', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}