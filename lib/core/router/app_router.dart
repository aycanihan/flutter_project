import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biletick/features/discover/screens/discover_screen.dart';
import 'package:biletick/features/tickets/screens/tickets_screen.dart';
import 'package:biletick/features/profile/screens/profile_screen.dart';
import 'package:biletick/features/organizer/screens/organizer_screen.dart';
import 'package:biletick/shared/widgets/main_shell.dart';

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