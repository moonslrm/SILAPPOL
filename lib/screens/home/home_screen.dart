import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lapangan.dart';
import '../../providers/booking_provider.dart';
import '../../providers/lapangan_provider.dart';
import '../auth/login_screen.dart';
import '../booking/booking_history_screen.dart';
import '../lapangan/lapangan_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedJenis = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lapanganProvider = context.watch<LapanganProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final filteredLapangan = lapanganProvider.lapangan.where((lapangan) {
      final matchesJenis =
          _selectedJenis == 'Semua' ||
          lapangan.jenisLapangan.toLowerCase() == _selectedJenis.toLowerCase();
      final search = _searchController.text.trim().toLowerCase();
      final matchesSearch =
          search.isEmpty ||
          lapangan.namaLapangan.toLowerCase().contains(search) ||
          lapangan.jenisLapangan.toLowerCase().contains(search);
      return matchesJenis && matchesSearch;
    }).toList();

    final jenisList = <String>{'Semua'};
    for (final lapangan in lapanganProvider.lapangan) {
      jenisList.add(lapangan.jenisLapangan);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SILAPPOL'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, LoginScreen.routeName),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, BookingHistoryScreen.routeName),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final lapanganProvider = context.read<LapanganProvider>();
          final bookingProvider = context.read<BookingProvider>();
          await Future.wait([
            lapanganProvider.loadLapangan(),
            bookingProvider.loadBookings(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking lapangan jadi lebih mudah',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lihat lapangan, cari slot, dan booking tanpa harus datang langsung.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _SummaryChip(
                        label: 'Lapangan',
                        value: lapanganProvider.lapangan.length.toString(),
                      ),
                      const SizedBox(width: 12),
                      _SummaryChip(
                        label: 'Booking',
                        value: bookingProvider.bookings.length.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama lapangan',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: jenisList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final jenis = jenisList.elementAt(index);
                  final isSelected = _selectedJenis == jenis;
                  return ChoiceChip(
                    label: Text(jenis),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedJenis = jenis);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (lapanganProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredLapangan.isEmpty)
              _EmptyState(
                title: 'Tidak ada lapangan cocok',
                subtitle: 'Coba ubah kata kunci atau filter jenis.',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredLapangan.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final lapangan = filteredLapangan[index];
                  return _LapanganGridCard(
                    lapangan: lapangan,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        LapanganDetailScreen.routeName,
                        arguments: lapangan,
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _LapanganGridCard extends StatelessWidget {
  const _LapanganGridCard({required this.lapangan, this.onTap});

  final Lapangan lapangan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = lapangan.fotoUrl ?? lapangan.foto;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 110,
                        color: const Color(0xFFE2E8F0),
                        child: const Center(child: Icon(Icons.sports_soccer)),
                      ),
                    )
                  : Container(
                      height: 110,
                      color: const Color(0xFFE2E8F0),
                      child: const Center(child: Icon(Icons.sports_soccer)),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lapangan.namaLapangan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lapangan.jenisLapangan,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                    const Spacer(),
                    Text(
                      'Rp${lapangan.hargaPerJam.toInt().toString()}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'per jam',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_soccer, size: 40, color: Color(0xFF0F766E)),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
