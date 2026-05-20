import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:etkinlik_app/features/discover/screens/discover_screen.dart';
import 'package:etkinlik_app/features/tickets/screens/tickets_screen.dart';
import 'package:etkinlik_app/features/profile/screens/profile_screen.dart';
import 'package:etkinlik_app/features/organizer/screens/organizer_screen.dart';
import 'package:etkinlik_app/shared/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/discover',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/discover',
          builder: (context, state) => const DiscoverScreen(),
        ),
        GoRoute(
          path: '/tickets',
          builder: (context, state) => const TicketsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/organizer',
      builder: (context, state) => const OrganizerScreen(),
    ),
  ],
);