import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

// ── COLORS ──
class AppColors {
  static const bgPrimary = Color(0xFF060610);
  static const bgSecondary = Color(0xFF0F0F1E);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFA855F7);
  static const pink = Color(0xFFEC4899);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textTertiary = Color(0x40FFFFFF);
  static const borderSubtle = Color(0x15FFFFFF);
}

// ── SCREENS ──
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(child: Text('Keşfet', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(child: Text('Biletlerim', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(child: Text('Profil', style: TextStyle(color: Colors.white, fontSize: 24))),
    );
  }
}

// ── NAVIGATION SHELL ──
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/tickets')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgPrimary,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.grid_view_rounded, label: 'Keşfet', isActive: currentIndex == 0, onTap: () => context.go('/discover')),
                _NavItem(icon: Icons.confirmation_number_outlined, label: 'Biletler', isActive: currentIndex == 1, onTap: () => context.go('/tickets')),
                _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', isActive: currentIndex == 2, onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? AppColors.purpleLight : AppColors.textTertiary),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? AppColors.purpleLight : AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

// ── ROUTER ──
final _router = GoRouter(
  initialLocation: '/discover',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/discover', builder: (context, state) => const DiscoverScreen()),
        GoRoute(path: '/tickets', builder: (context, state) => const TicketsScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
  ],
);

// ── MAIN ──
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const EtkinlikApp());
}

class EtkinlikApp extends StatelessWidget {
  const EtkinlikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Etkinlik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.pink,
        ),
      ),
      routerConfig: _router,
    );
  }
}