import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedCategory = 'Tümü';
  final List<String> _categories = [
    'Tümü', 'Rock', 'Pop', 'Hip-Hop', 'Metal', 'EDM',
    'Alternative', 'Electronic', 'R&B', 'Klasik', 'Indie',
    'Psychedelic', 'Trip-Hop',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned(
            top: -80, left: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.5), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            top: 40, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.pink.withOpacity(0.4), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Merhaba 👋',
                            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'Kullanıcı',
                            style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary, letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppColors.purple, AppColors.pink]),
                        ),
                        child: Center(
                          child: Text(
                            (FirebaseAuth.instance.currentUser?.displayName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Arama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const TextField(
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Etkinlik, sanatçı, mekan ara...',
                        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Kategoriler
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            gradient: isSelected
                                ? const LinearGradient(colors: [AppColors.purple, AppColors.pink])
                                : null,
                            color: isSelected ? null : AppColors.bgCard,
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppColors.borderSubtle,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Etkinlik listesi
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _selectedCategory == 'Tümü'
                        ? FirebaseFirestore.instance
                            .collection('events')
                            .orderBy('isFeatured', descending: true)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('events')
                            .where('category', isEqualTo: _selectedCategory)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.purple));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Etkinlik bulunamadı', style: TextStyle(color: AppColors.textTertiary)),
                        );
                      }
                      final events = snapshot.data!.docs;
                      final featured = events.where((e) => (e.data() as Map)['isFeatured'] == true).toList();
                      final regular = events.where((e) => (e.data() as Map)['isFeatured'] != true).toList();

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        children: [
                          if (featured.isNotEmpty) ...[
                            const Text(
                              'ÖNE ÇIKAN',
                              style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                            ),
                            const SizedBox(height: 10),
                            ...featured.map((e) => _FeaturedCard(doc: e)),
                            const SizedBox(height: 20),
                          ],
                          if (regular.isNotEmpty) ...[
                            const Text(
                              'YAKINDA',
                              style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                            ),
                            const SizedBox(height: 10),
                            ...regular.map((e) => _RegularCard(doc: e)),
                          ],
                        ],
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
  }
}

class _FeaturedCard extends StatelessWidget {
  final DocumentSnapshot doc;
  const _FeaturedCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () => context.go('/event/${doc.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.purple.withOpacity(0.8), AppColors.pink.withOpacity(0.8)],
          ),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          data['category'] ?? '',
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '₺${data['price']}+',
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(data['date'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data['venue'] ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
}

class _RegularCard extends StatelessWidget {
  final DocumentSnapshot doc;
  const _RegularCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () => context.go('/event/${doc.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [AppColors.purple.withOpacity(0.6), AppColors.pink.withOpacity(0.6)],
                ),
              ),
              child: Center(
                child: Text(
                  (data['title'] as String? ?? '?')[0],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${data['date']} · ${data['venue']}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data['category'] ?? '',
                      style: const TextStyle(fontSize: 10, color: AppColors.purpleLight, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${data['price']}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.purpleLight),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
