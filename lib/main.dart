import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'firebase_options.dart';
import 'package:biletick/features/discover/screens/discover_screen.dart';

// ── COLORS ──
class AppColors {
  static final _eventGradients = const [
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF97316), Color(0xFFEF4444)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomRight, colors: [Color(0xFF059669), Color(0xFF0D9488)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4338CA), Color(0xFFA855F7)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFEC4899), Color(0xFFF97316)]),
    LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFFE11D48), Color(0xFF7C3AED)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD97706), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF10B981), Color(0xFF3B82F6)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomLeft, colors: [Color(0xFFEF4444), Color(0xFFF97316)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF14B8A6), Color(0xFF22D3EE)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF43F5E), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF84CC16), Color(0xFF22C55E)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomRight, colors: [Color(0xFFEAB308), Color(0xFFF97316)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF7C3AED), Color(0xFF4338CA)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF43F5E), Color(0xFFEF4444)]),
    LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF0891B2), Color(0xFF059669)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDB2777), Color(0xFF9333EA)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFDC2626), Color(0xFFD97706)]),
    LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomLeft, colors: [Color(0xFF0D9488), Color(0xFF0284C7)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9333EA), Color(0xFFEC4899)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFF59E0B), Color(0xFF10B981)]),
    LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)]),
  ];

  static LinearGradient gradientForEvent(String id) =>
      _eventGradients[id.hashCode.abs() % _eventGradients.length];
  static const bgPrimary = Color(0xFF060610);
  static const bgSecondary = Color(0xFF0F0F1E);
  static const bgCard = Color(0xFF0D0D22);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFA855F7);
  static const pink = Color(0xFFEC4899);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x80FFFFFF);
  static const textTertiary = Color(0x40FFFFFF);
  static const borderSubtle = Color(0x15FFFFFF);
  static const borderLight = Color(0x25FFFFFF);
  static const orange = Color(0xFFF97316);
}

// ── SCREENS ──
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});
  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final userId = authSnapshot.data?.uid ?? '';

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => context.go('/profile'),
                  )
                : null,
          ),
          body: Stack(
            children: [
              Positioned(top: -60, right: -40, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.35), Colors.transparent])))),
              Positioned(bottom: 100, left: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.pink.withOpacity(0.25), Colors.transparent])))),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Biletlerim', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                  .collection('tickets')
                                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                                  .snapshots(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.docs.length ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('$count bilet', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('tickets')
                                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(color: AppColors.purple));
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 80, height: 80,
                                          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderSubtle)),
                                          child: const Icon(Icons.confirmation_number_outlined, size: 36, color: AppColors.textTertiary),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Henüz biletiniz yok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        const SizedBox(height: 8),
                                        const Text('Etkinlikleri keşfet ve bilet al', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () => context.go('/discover'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]), borderRadius: BorderRadius.circular(12)),
                                            child: const Text('Etkinlikleri Keşfet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final tickets = snapshot.data!.docs;
                                return ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                  itemCount: tickets.length,
                                  itemBuilder: (context, index) {
                                    final ticket = tickets[index].data() as Map<String, dynamic>;
                                    final ticketId = tickets[index].id;
                                    return _buildTicketCard(ticket, ticketId);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, String ticketId) {
    final isVip = ticket['ticketType'] == 'VIP Alan';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isVip
                      ? [const Color(0xFF160535), const Color(0xFF4c1d95), const Color(0xFF7c3aed), const Color(0xFFc026d3)]
                      : [const Color(0xFF0d1f3c), const Color(0xFF1e3a7a), const Color(0xFF2563eb)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(ticket['eventTitle'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3))),
                      if (isVip)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]), borderRadius: BorderRadius.circular(20)),
                          child: const Text('VIP', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoItem('TARİH', ticket['eventDate'] ?? ''),
                      const SizedBox(width: 20),
                      _infoItem('SAAT', ticket['eventTime'] ?? ''),
                      const SizedBox(width: 20),
                      _infoItem('ADET', '${ticket['quantity']}x'),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.bgPrimary, borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)))),
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
                  return Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate((constraints.constrainWidth() / 12).floor(), (index) => Container(width: 6, height: 1.5, color: AppColors.borderSubtle)),
                  );
                })),
                Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.bgPrimary, borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.bgCard,
              child: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: QrImageView(data: ticketId, version: QrVersions.auto, backgroundColor: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.purple.withOpacity(0.3))),
                          child: Text(ticket['ticketType'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.purpleLight, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 6),
                        Text(ticket['venue'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('#${ticketId.substring(0, 8).toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontFamily: 'monospace')),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF34d399), shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            const Text('Aktif', style: TextStyle(fontSize: 11, color: Color(0xFF34d399), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₺${(ticket['totalPrice'] as num).toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.purpleLight)),
                      const SizedBox(height: 4),
                      const Text('toplam', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w700, letterSpacing: 0.08)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isOrganizer = false;
  StreamSubscription<DocumentSnapshot>? _roleSub;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _subscribeRole(uid);
  }

  void _subscribeRole(String uid) {
    _roleSub?.cancel();
    _roleSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (!mounted) return;
      final data = doc.data();
      final roleValue = data?['role'];
      setState(() => _isOrganizer = roleValue is String && roleValue == 'organizer');
    });
  }

  @override
  void dispose() {
    _roleSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user != null && _roleSub == null) _subscribeRole(user.uid);

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: Stack(
            children: [
              Positioned(top: -60, right: -40, child: Container(width: 220, height: 220, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.4), Colors.transparent])))),
              Positioned(bottom: 100, left: -40, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.pink.withOpacity(0.3), Colors.transparent])))),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
                          boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Center(
                          child: Text(
                            (user?.displayName ?? user?.email ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.displayName ?? 'Kullanıcı',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 8),
                      // Rol badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: _isOrganizer
                              ? const LinearGradient(colors: [AppColors.purple, AppColors.pink])
                              : null,
                          color: _isOrganizer ? null : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _isOrganizer ? Colors.transparent : AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_isOrganizer ? Icons.event : Icons.person_outline_rounded, size: 14, color: _isOrganizer ? Colors.white : AppColors.textTertiary),
                            const SizedBox(width: 6),
                            Text(
                              _isOrganizer ? 'Organizatör' : 'Katılımcı',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isOrganizer ? Colors.white : AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // İstatistikler
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                                  .collection('tickets')
                                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                                  .snapshots(),
                        builder: (context, snapshot) {
                          final ticketCount = snapshot.data?.docs.length ?? 0;
                          final totalSpent = snapshot.data?.docs.fold<double>(0, (sum, doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return sum + (data['totalPrice'] as num? ?? 0).toDouble();
                          }) ?? 0;

                          return Row(
                            children: [
                              Expanded(child: _buildStatCard('Bilet', '$ticketCount', Icons.confirmation_number_outlined)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard('Harcama', '₺${totalSpent.toStringAsFixed(0)}', Icons.payments_outlined)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard('Etkinlik', '$ticketCount', Icons.event_outlined)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Menü öğeleri
                      _buildMenuItem(Icons.confirmation_number_outlined, 'Biletlerim', 'Satın aldığın biletler', () => context.go('/tickets')),
                      if (_isOrganizer) ...[
                        const SizedBox(height: 10),
                        _buildMenuItem(Icons.add_circle_outline_rounded, 'Etkinlik Oluştur', 'Yeni etkinlik yayınla', () => context.go('/organizer')),
                      ],
                      const SizedBox(height: 10),
                      _buildMenuItem(Icons.history_rounded, 'İşlem Geçmişi', 'Tüm aktiviteler', () {}),
                      const SizedBox(height: 10),
                      _buildMenuItem(Icons.settings_outlined, 'Ayarlar', 'Hesap ayarları', () {}),
                      const SizedBox(height: 24),
                      // Çıkış yap
                      GestureDetector(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) context.go('/login');
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Çıkış Yap', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.purpleLight),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.purpleLight),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
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
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/buy/:id',
      builder: (context, state) => BuyTicketScreen(eventId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/organizer',
      builder: (context, state) => const OrganizerScreen(),
    ),
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

// ── SEED ──
Future<void> seedEvents() async {
  final firestore = FirebaseFirestore.instance;

  final existing = await firestore.collection('events').limit(1).get();
  if (existing.docs.isNotEmpty) {
    print('✅ Etkinlikler zaten mevcut, seed atlandı.');
    return;
  }

  final events = [
    {'title': 'Guns N\'Roses', 'category': 'Rock', 'date': '2 Haziran 2025', 'time': '20:00', 'venue': 'BJK Tüpraş Stadyumu', 'city': 'İstanbul', 'price': 1000, 'imageUrl': 'https://picsum.photos/seed/gnr/400/200', 'description': '32 yıl sonra İstanbul\'da!', 'isFeatured': true},
    {'title': 'Kanye West', 'category': 'Hip-Hop', 'date': '14 Haziran 2025', 'time': '21:00', 'venue': 'Ülker Arena', 'city': 'İstanbul', 'price': 1500, 'imageUrl': 'https://picsum.photos/seed/kanye/400/200', 'description': 'Donda World Tour İstanbul', 'isFeatured': true},
    {'title': 'Gorillaz', 'category': 'Alternative', 'date': '5 Temmuz 2025', 'time': '20:30', 'venue': 'KüçükÇiftlik Park', 'city': 'İstanbul', 'price': 850, 'imageUrl': 'https://picsum.photos/seed/gorillaz/400/200', 'description': 'Cracker Island Tour', 'isFeatured': true},
    {'title': 'Till Lindemann', 'category': 'Metal', 'date': '6 Aralık 2025', 'time': '20:00', 'venue': 'Volkswagen Arena', 'city': 'İstanbul', 'price': 900, 'imageUrl': 'https://picsum.photos/seed/lind/400/200', 'description': 'Meine Welt Avrupa Turnesi', 'isFeatured': true},
    {'title': 'Coldplay', 'category': 'Pop', 'date': '28 Haziran 2025', 'time': '20:00', 'venue': 'Ülker Arena', 'city': 'İstanbul', 'price': 1300, 'imageUrl': 'https://picsum.photos/seed/coldplay/400/200', 'description': 'Music of the Spheres World Tour', 'isFeatured': true},
    {'title': 'Radiohead', 'category': 'Rock', 'date': '18 Ağustos 2025', 'time': '20:00', 'venue': 'Parkorman', 'city': 'İstanbul', 'price': 1200, 'imageUrl': 'https://picsum.photos/seed/radiohead/400/200', 'description': 'The Bends 30th Anniversary Tour', 'isFeatured': true},
    {'title': 'Arctic Monkeys', 'category': 'Rock', 'date': '3 Eylül 2025', 'time': '20:30', 'venue': 'Volkswagen Arena', 'city': 'İstanbul', 'price': 950, 'imageUrl': 'https://picsum.photos/seed/arctic/400/200', 'description': 'The Car World Tour', 'isFeatured': true},
    {'title': 'Billie Eilish', 'category': 'Pop', 'date': '25 Haziran 2025', 'time': '20:00', 'venue': 'Ülker Arena', 'city': 'İstanbul', 'price': 1100, 'imageUrl': 'https://picsum.photos/seed/billie/400/200', 'description': 'Hit Me Hard and Soft Tour', 'isFeatured': true},
    {'title': 'The Weeknd', 'category': 'R&B', 'date': '10 Temmuz 2025', 'time': '21:00', 'venue': 'Ülker Arena', 'city': 'İstanbul', 'price': 1300, 'imageUrl': 'https://picsum.photos/seed/weeknd/400/200', 'description': 'After Hours til Dawn Tour', 'isFeatured': true},
    {'title': 'Massive Attack', 'category': 'Electronic', 'date': '15 Eylül 2025', 'time': '21:30', 'venue': 'KüçükÇiftlik Park', 'city': 'İstanbul', 'price': 700, 'imageUrl': 'https://picsum.photos/seed/massive/400/200', 'description': 'Mezzanine 25th Anniversary', 'isFeatured': false},
    {'title': 'Portishead', 'category': 'Trip-Hop', 'date': '20 Eylül 2025', 'time': '21:00', 'venue': 'Zorlu PSM', 'city': 'İstanbul', 'price': 800, 'imageUrl': 'https://picsum.photos/seed/portishead/400/200', 'description': 'Nadir görülen bir gece', 'isFeatured': false},
    {'title': 'Tame Impala', 'category': 'Psychedelic', 'date': '2 Ekim 2025', 'time': '20:30', 'venue': 'KüçükÇiftlik Park', 'city': 'İstanbul', 'price': 850, 'imageUrl': 'https://picsum.photos/seed/tame/400/200', 'description': 'Currents 10th Anniversary', 'isFeatured': true},
    {'title': 'Tyler the Creator', 'category': 'Hip-Hop', 'date': '30 Haziran 2025', 'time': '21:00', 'venue': 'Volkswagen Arena', 'city': 'İstanbul', 'price': 950, 'imageUrl': 'https://picsum.photos/seed/tyler/400/200', 'description': 'Chromakopia World Tour', 'isFeatured': true},
    {'title': 'FKA Twigs', 'category': 'Alternative', 'date': '17 Ekim 2025', 'time': '20:00', 'venue': 'Zorlu PSM', 'city': 'İstanbul', 'price': 600, 'imageUrl': 'https://picsum.photos/seed/fka/400/200', 'description': 'Eargasm gecesi', 'isFeatured': false},
    {'title': 'Kendrick Lamar', 'category': 'Hip-Hop', 'date': '5 Kasım 2025', 'time': '21:00', 'venue': 'Ülker Arena', 'city': 'İstanbul', 'price': 1400, 'imageUrl': 'https://picsum.photos/seed/kendrick/400/200', 'description': 'Grand National Tour', 'isFeatured': true},
    {'title': 'Kraftwerk', 'category': 'Electronic', 'date': '6 Aralık 2025', 'time': '20:00', 'venue': 'Volkswagen Arena', 'city': 'İstanbul', 'price': 900, 'imageUrl': 'https://picsum.photos/seed/kraft/400/200', 'description': '3D Concert Experience', 'isFeatured': false},
    {'title': 'Mor ve Ötesi', 'category': 'Rock', 'date': '20 Haziran 2025', 'time': '21:00', 'venue': 'Harbiye Açıkhava', 'city': 'İstanbul', 'price': 400, 'imageUrl': 'https://picsum.photos/seed/morveotesi/400/200', 'description': 'Duvara Yazılan ve daha fazlası', 'isFeatured': false},
    {'title': 'Tarkan', 'category': 'Pop', 'date': '27 Haziran 2025', 'time': '21:00', 'venue': 'Harbiye Açıkhava', 'city': 'İstanbul', 'price': 500, 'imageUrl': 'https://picsum.photos/seed/tarkan/400/200', 'description': 'Yaz gecesi efsanesi', 'isFeatured': false},
    {'title': 'Limp Bizkit', 'category': 'Rock', 'date': '19 Temmuz 2025', 'time': '20:00', 'venue': 'Volkswagen Arena', 'city': 'İstanbul', 'price': 850, 'imageUrl': 'https://picsum.photos/seed/limpbizkit/400/200', 'description': 'Nookie\'yi canlı duyma vakti', 'isFeatured': true},
    {'title': 'The Neighbourhood', 'category': 'Alternative', 'date': '9 Ağustos 2025', 'time': '20:30', 'venue': 'KüçükÇiftlik Park', 'city': 'İstanbul', 'price': 650, 'imageUrl': 'https://picsum.photos/seed/nbhd/400/200', 'description': 'Sweater Weather ve daha fazlası', 'isFeatured': false},
    {'title': 'Paramore', 'category': 'Rock', 'date': '23 Ağustos 2025', 'time': '20:00', 'venue': 'KüçükÇiftlik Park', 'city': 'İstanbul', 'price': 750, 'imageUrl': 'https://picsum.photos/seed/paramore/400/200', 'description': 'This Is Why Tour', 'isFeatured': true},
    {'title': 'Travis Scott', 'category': 'Hip-Hop', 'date': '4 Ekim 2025', 'time': '22:00', 'venue': 'Ülker Arena', 'city': 'İstanbul', 'price': 1200, 'imageUrl': 'https://picsum.photos/seed/travis/400/200', 'description': 'Utopia Circus Maximus Tour', 'isFeatured': true},
    {'title': 'Hans Zimmer', 'category': 'Klasik', 'date': '11 Ekim 2025', 'time': '19:00', 'venue': 'Volkswagen Arena', 'city': 'İstanbul', 'price': 1100, 'imageUrl': 'https://picsum.photos/seed/hanszimmer/400/200', 'description': 'The World of Hans Zimmer — sinema müziğinin efsanesi', 'isFeatured': true},
    {'title': 'Justin Timberlake', 'category': 'Pop', 'date': '18 Ekim 2025', 'time': '20:30', 'venue': 'Ülker Arena', 'city': 'İstanbul', 'price': 1000, 'imageUrl': 'https://picsum.photos/seed/jt/400/200', 'description': 'Forget Tomorrow World Tour', 'isFeatured': false},
    {'title': 'YEBBA', 'category': 'R&B', 'date': '1 Kasım 2025', 'time': '20:00', 'venue': 'Zorlu PSM', 'city': 'İstanbul', 'price': 550, 'imageUrl': 'https://picsum.photos/seed/yebba/400/200', 'description': 'Soul sesinin büyüsü', 'isFeatured': false},
    {'title': 'Miguel', 'category': 'R&B', 'date': '8 Kasım 2025', 'time': '20:30', 'venue': 'Zorlu PSM', 'city': 'İstanbul', 'price': 600, 'imageUrl': 'https://picsum.photos/seed/miguel/400/200', 'description': 'Wildheart Tour', 'isFeatured': false},
    {'title': 'Kaytranada', 'category': 'EDM', 'date': '15 Kasım 2025', 'time': '22:00', 'venue': 'KüçükÇiftlik Park', 'city': 'İstanbul', 'price': 700, 'imageUrl': 'https://picsum.photos/seed/kaytra/400/200', 'description': 'Dans etmeden çıkamazsın', 'isFeatured': false},
  ];

  for (final event in events) {
    await firestore.collection('events').add(event);
  }
  print('✅ ${events.length} etkinlik eklendi!');
}

// ── MAIN ──
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

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
      title: 'Biletick',
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

// ── EVENT DETAIL SCREEN ──
class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('events').doc(eventId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.purple));
          }
          if (!snapshot.hasData) return const Center(child: Text('Etkinlik bulunamadı', style: TextStyle(color: Colors.white)));

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final imageUrl = data['imageUrl'] as String? ?? '';

          return Stack(
            children: [
              // Hero: kart gradyentinden büyüyerek geçiş
              Hero(
                tag: 'hero-event-$eventId',
                child: SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            decoration: BoxDecoration(gradient: AppColors.gradientForEvent(eventId)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(gradient: AppColors.gradientForEvent(eventId)),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(gradient: AppColors.gradientForEvent(eventId)),
                        ),
                ),
              ),
              // Scrim: içeriğe geçiş
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.bgPrimary],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () => context.go('/discover'),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Kategori badge
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(data['category'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Başlık
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          data['title'] ?? '',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.8, height: 1.1),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(data['venue'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                      ),
                      const SizedBox(height: 24),
                      // Info kartları
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildInfoChip(Icons.calendar_today_rounded, data['date'] ?? ''),
                            const SizedBox(width: 8),
                            _buildInfoChip(Icons.access_time_rounded, data['time'] ?? ''),
                            const SizedBox(width: 8),
                            _buildInfoChip(Icons.location_city_rounded, data['city'] ?? ''),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Açıklama
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hakkında', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              Text(data['description'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bilet tipleri
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BİLET SEÇ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.1)),
                            const SizedBox(height: 10),
                            _buildTicketOption('VIP Alan', 'Ön sıra · Ücretsiz içecek', (data['price'] as num) * 2),
                            const SizedBox(height: 8),
                            _buildTicketOption('Standart', '148 bilet mevcut', (data['price'] as num).toDouble()),
                            const SizedBox(height: 8),
                            _buildTicketOption('Öğrenci', 'Kimlik gerekli', (data['price'] as num) * 0.65),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Satın al butonu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => context.go('/buy/$eventId'),
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleLight, AppColors.pink]),
                              boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Center(
                              child: Text('Bilet Satın Al →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  Widget _buildInfoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.purpleLight),
            const SizedBox(width: 5),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketOption(String name, String subtitle, num price) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
          Text('₺${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.purpleLight)),
        ],
      ),
    );
  }
}

// ── BUY TICKET SCREEN ──
class BuyTicketScreen extends StatefulWidget {
  final String eventId;
  const BuyTicketScreen({super.key, required this.eventId});

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  String _selectedTicketType = 'Standart';
  int _quantity = 1;
  bool _isLoading = false;

  final Map<String, double> _ticketMultipliers = {
    'VIP Alan': 2.0,
    'Standart': 1.0,
    'Öğrenci': 0.65,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('events').doc(widget.eventId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.purple));
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final basePrice = (data['price'] as num).toDouble();
          final selectedPrice = basePrice * _ticketMultipliers[_selectedTicketType]!;
          final total = selectedPrice * _quantity;

          return Stack(
            children: [
              Positioned(top: -60, right: -40, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.4), Colors.transparent])))),
              Positioned(bottom: 100, left: -40, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.pink.withOpacity(0.3), Colors.transparent])))),
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/event/${widget.eventId}'),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
                              child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bilet Seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3)),
                              Text(data['title'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Etkinlik özeti
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.15), AppColors.pink.withOpacity(0.1)]),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
                                    ),
                                    child: Center(child: Text((data['title'] as String)[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                        Text('${data['date']} · ${data['time']}', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                                        Text(data['venue'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text('BİLET TİPİ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.1)),
                            const SizedBox(height: 10),
                            ..._ticketMultipliers.entries.map((entry) {
                              final isSelected = _selectedTicketType == entry.key;
                              final price = basePrice * entry.value;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTicketType = entry.key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.purple.withOpacity(0.12) : AppColors.bgCard,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: isSelected ? AppColors.purple : AppColors.borderSubtle, width: isSelected ? 1.5 : 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20, height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: isSelected ? AppColors.purple : AppColors.textTertiary, width: 1.5),
                                          color: isSelected ? AppColors.purple.withOpacity(0.2) : Colors.transparent,
                                        ),
                                        child: isSelected ? const Icon(Icons.check, size: 12, color: AppColors.purpleLight) : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(entry.key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)),
                                      ),
                                      Text('₺${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isSelected ? AppColors.purpleLight : AppColors.textTertiary)),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                            const Text('ADET', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.1)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderSubtle)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Bilet adedi', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () { if (_quantity > 1) setState(() => _quantity--); },
                                        child: Container(
                                          width: 32, height: 32,
                                          decoration: BoxDecoration(color: AppColors.bgPrimary, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderLight)),
                                          child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                      ),
                                      GestureDetector(
                                        onTap: () { if (_quantity < 10) setState(() => _quantity++); },
                                        child: Container(
                                          width: 32, height: 32,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
                                          ),
                                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Toplam
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Bilet fiyatı', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                                      Text('₺${selectedPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Adet', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                                      Text('x$_quantity', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Divider(color: AppColors.borderSubtle),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Toplam', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      Text('₺${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.purpleLight)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Satın al butonu
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary.withOpacity(0.95),
                    border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
                      : GestureDetector(
                          onTap: () => _purchaseTicket(data, selectedPrice, total),
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleLight, AppColors.pink]),
                              boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: Center(
                              child: Text('₺${total.toStringAsFixed(0)} · Satın Al', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _purchaseTicket(Map<String, dynamic> eventData, double price, double total) async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final eventTitle = eventData['title']?.toString() ?? '';
      final eventDate = eventData['date']?.toString() ?? '';
      final eventTime = eventData['time']?.toString() ?? '';
      final venue = eventData['venue']?.toString() ?? '';

      final ticketRef = await FirebaseFirestore.instance.collection('tickets').add({
        'userId': userId,
        'eventId': widget.eventId,
        'eventTitle': eventTitle,
        'eventDate': eventDate,
        'eventTime': eventTime,
        'venue': venue,
        'ticketType': _selectedTicketType,
        'quantity': _quantity,
        'pricePerTicket': price,
        'totalPrice': total,
        'purchasedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await FirebaseFirestore.instance.collection('logs').add({
        'userId': userId,
        'action': 'ticket_purchased',
        'ticketId': ticketRef.id,
        'eventTitle': eventTitle,
        'ticketType': _selectedTicketType,
        'quantity': _quantity,
        'totalPrice': total,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Biletiniz satın alındı!'),
            backgroundColor: AppColors.purple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/tickets');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── ORGANIZER SCREEN ──
class OrganizerScreen extends StatefulWidget {
  const OrganizerScreen({super.key});
  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String _selectedCategory = 'Konser';
  bool _isFeatured = false;
  bool _isLoading = false;

  final List<String> _categories = ['Rock', 'Pop', 'Hip-Hop', 'Metal', 'EDM', 'Alternative', 'Electronic', 'R&B', 'Klasik', 'Indie', 'Psychedelic', 'Konser', 'Festival'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned(top: -60, right: -40, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.4), Colors.transparent])))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/discover'),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
                          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Etkinlik Oluştur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3)),
                          Text('Yeni etkinlik ekle', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(_titleController, 'Etkinlik Adı', Icons.event_rounded),
                        const SizedBox(height: 12),
                        _buildTextField(_descController, 'Açıklama', Icons.description_outlined, maxLines: 3),
                        const SizedBox(height: 12),
                        const Text('KATEGORİ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.1)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = cat == _selectedCategory;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: isSelected ? const LinearGradient(colors: [AppColors.purple, AppColors.pink]) : null,
                                    color: isSelected ? null : AppColors.bgCard,
                                    border: Border.all(color: isSelected ? Colors.transparent : AppColors.borderSubtle),
                                  ),
                                  child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textTertiary)),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_dateController, 'Tarih (ör: 15 Haziran 2025)', Icons.calendar_today_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(_timeController, 'Saat (ör: 20:00)', Icons.access_time_rounded)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(_venueController, 'Mekan', Icons.location_on_rounded),
                        const SizedBox(height: 12),
                        _buildTextField(_cityController, 'Şehir', Icons.location_city_rounded),
                        const SizedBox(height: 12),
                        _buildTextField(_priceController, 'Başlangıç Fiyatı (₺)', Icons.payments_outlined, keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderSubtle)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Öne Çıkar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  Text('Ana sayfada büyük kart olarak göster', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                ],
                              ),
                              Switch(
                                value: _isFeatured,
                                onChanged: (val) => setState(() => _isFeatured = val),
                                activeColor: AppColors.purpleLight,
                                activeTrackColor: AppColors.purple.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
                            : GestureDetector(
                                onTap: _createEvent,
                                child: Container(
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleLight, AppColors.pink]),
                                    boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                                  ),
                                  child: const Center(
                                    child: Text('Etkinliği Yayınla', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderSubtle)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
          prefixIcon: Padding(padding: const EdgeInsets.only(bottom: 0), child: Icon(icon, color: AppColors.textTertiary, size: 20)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _createEvent() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen zorunlu alanları doldurun'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'venue': _venueController.text.trim(),
        'city': _cityController.text.trim(),
        'price': int.tryParse(_priceController.text.trim()) ?? 0,
        'isFeatured': _isFeatured,
        'organizerId': user?.uid ?? '',
        'imageUrl': 'https://picsum.photos/seed/${_titleController.text}/400/200',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('logs').add({
        'userId': user?.uid ?? '',
        'action': 'event_created',
        'eventTitle': _titleController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Etkinlik yayınlandı!'),
            backgroundColor: AppColors.purple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/discover');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── LOGO WIDGET ──
class _BiletickLogo extends StatelessWidget {
  final double size;
  const _BiletickLogo({this.size = 88});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(size),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double size;
  const _LogoPainter(this.size);

  // [cx_norm, cy_norm, outerR_norm, innerR_norm, opacity]
  static const _stars = [
    [0.736, 0.250, 0.057, 0.023, 0.95], // büyük   sağ üst
    [0.257, 0.296, 0.046, 0.018, 0.70], // orta    sol üst
    [0.264, 0.729, 0.036, 0.014, 0.55], // orta    sol alt
    [0.729, 0.729, 0.036, 0.014, 0.60], // küçük   sağ alt
    [0.500, 0.186, 0.029, 0.011, 0.45], // tiny    üst orta
    [0.500, 0.829, 0.029, 0.011, 0.40], // tiny    alt orta
  ];

  static Shader _shader(double s, [double opacity = 1.0]) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF818CF8).withOpacity(opacity),
          Color(0xFFF472B6).withOpacity(opacity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, s, s));

  @override
  void paint(Canvas canvas, Size sz) {
    final s = sz.width;
    final center = Offset(s / 2, s / 2);
    final radius = s * 0.357; // 50/140

    // ── 1. Daire dolgu (opacity 0.15) ──
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = _shader(s, 0.15)
        ..style = PaintingStyle.fill,
    );

    // ── 2. Daire border (gradient stroke) ──
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = _shader(s)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.011, // ~1.5 px @ 140
    );

    // ── 3. Yıldızlar ──
    for (final star in _stars) {
      canvas.drawPath(
        _starPath(star[0] * s, star[1] * s, star[2] * s, star[3] * s),
        Paint()
          ..shader = _shader(s, star[4])
          ..style = PaintingStyle.fill,
      );
    }

    // ── 4. "ʙ" harfi — gradient, ortada ──
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: 'ʙ',
        style: TextStyle(
          fontSize: s * 0.64,
          fontWeight: FontWeight.w900,
          foreground: Paint()..shader = _shader(s),
          height: 1.0,
        ),
      ),
    )..layout();
    tp.paint(
      canvas,
      Offset(s / 2 - tp.width / 2, s / 2 - tp.height / 2 + s * 0.02),
    );
  }

  static Path _starPath(double cx, double cy, double outerR, double innerR) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = i * math.pi / 5 - math.pi / 2;
      i == 0
          ? path.moveTo(cx + r * math.cos(angle), cy + r * math.sin(angle))
          : path.lineTo(cx + r * math.cos(angle), cy + r * math.sin(angle));
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── SPLASH SCREEN ──
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    context.go(user != null ? '/discover' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned(
            top: -80, left: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.45), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -60, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.pink.withOpacity(0.35), Colors.transparent]),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _BiletickLogo(size: 110),
                const SizedBox(height: 20),
                const Text(
                  'Biletick',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Etkinlikleri keşfet, biletini al.',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── LOGIN SCREEN ──
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Gradient arka plan
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.purple.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.pink.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          // İçerik
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  const Center(child: _BiletickLogo(size: 88)),
                  const SizedBox(height: 24),
                  // Başlık
                  const Text(
                    'Tekrar\nhoş geldin.',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Etkinlikleri keşfetmek için giriş yap',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    hint: 'E-posta',
                    icon: Icons.mail_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  // Şifre field
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Şifre',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  // Giriş yap butonu
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
                      : _buildGradientButton(
                          text: 'Giriş Yap',
                          onTap: _login,
                        ),
                  const SizedBox(height: 16),
                  // Google butonu
                  _buildGoogleButton(),
                  const SizedBox(height: 24),
                  // Kayıt ol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hesabın yok mu? ',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'Kayıt ol',
                          style: TextStyle(
                            color: AppColors.purpleLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.purple, AppColors.purpleLight, AppColors.pink],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _googleLogin,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.blue],
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Google ile devam et',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    // Firebase auth gelecek
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) context.go('/discover');
  }

  Future<void> _googleLogin() async {
    // Google sign in gelecek
    if (mounted) context.go('/discover');
  }
}

// ── REGISTER SCREEN ──
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.pink.withOpacity(0.5), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.purple.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hesap\noluştur.',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Etkinlik dünyasına katıl',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'HESAP TÜRÜ',
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.08),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildRoleCard('user', 'Katılımcı', Icons.person_outline_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildRoleCard('organizer', 'Organizatör', Icons.event_outlined)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _nameController, hint: 'Ad Soyad', icon: Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _emailController, hint: 'E-posta', icon: Icons.mail_outline_rounded),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _passwordController, hint: 'Şifre', icon: Icons.lock_outline_rounded, isPassword: true),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.purple))
                      : _buildGradientButton(text: 'Kayıt Ol', onTap: _register),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Zaten hesabın var mı? ', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text('Giriş yap', style: TextStyle(color: AppColors.purpleLight, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple.withOpacity(0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.purple : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.purpleLight : AppColors.textTertiary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.purpleLight : AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textTertiary, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [AppColors.purple, AppColors.purpleLight, AppColors.pink]),
          boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm alanları doldurun'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre en az 6 karakter olmalı'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await credential.user?.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) context.go('/discover');
    } on FirebaseAuthException catch (e) {
      String message = 'Bir hata oluştu';
      if (e.code == 'email-already-in-use') message = 'Bu email zaten kayıtlı';
      if (e.code == 'weak-password') message = 'Şifre çok zayıf';
      if (e.code == 'invalid-email') message = 'Geçersiz email';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}