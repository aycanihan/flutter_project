import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OrganizerScreen extends StatelessWidget {
  const OrganizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        leading: GestureDetector(
          onTap: () => context.go('/discover'),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
        ),
        title: const Text('Etkinlik Oluştur'),
      ),
      body: const Center(
        child: Text(
          'Etkinlik Oluştur',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
