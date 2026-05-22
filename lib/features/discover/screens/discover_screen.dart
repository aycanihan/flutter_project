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
    final title = (data['title'] as String?) ?? '';
    final firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';
    final gradient = AppColors.gradientForEvent(doc.id);

    return GestureDetector(
      onTap: () => context.go('/event/${doc.id}'),
      child: Hero(
        tag: 'hero-event-${doc.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 180,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: gradient,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Dekoratif büyük harf arka planda
                Positioned(
                  right: -10,
                  top: -20,
                  bottom: -20,
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 220,
                      fontWeight: FontWeight.w900,
                      color: Color(0x1AFFFFFF),
                      height: 1.0,
                    ),
                  ),
                ),
                // Alt scrim
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                      ),
                    ),
                  ),
                ),
                // İçerik
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Üst: kategori + fiyat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x30FFFFFF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x40FFFFFF)),
                            ),
                            child: Text(
                              data['category'] ?? '',
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x55000000),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '₺${data['price']}+',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      // Alt: büyük bold başlık + tarih/mekan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xBBFFFFFF)),
                              const SizedBox(width: 3),
                              Text(data['date'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xBBFFFFFF))),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_rounded, size: 11, color: Color(0xBBFFFFFF)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  data['venue'] ?? '',
                                  style: const TextStyle(fontSize: 11, color: Color(0xBBFFFFFF)),
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
    final title = (data['title'] as String?) ?? '';
    final firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';
    final gradient = AppColors.gradientForEvent(doc.id);

    return GestureDetector(
      onTap: () => context.go('/event/${doc.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // Sol: 60x60 gradient kutu — hero kaynağı
            Hero(
              tag: 'hero-event-${doc.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: gradient,
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Orta: bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data['venue'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x26A855F7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0x40A855F7)),
                        ),
                        child: Text(
                          data['category'] ?? '',
                          style: const TextStyle(fontSize: 10, color: AppColors.purpleLight, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.access_time_rounded, size: 10, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        data['date'] ?? '',
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Sağ: fiyat + ok
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₺${data['price']}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.purpleLight),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0x207C3AED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.purpleLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
