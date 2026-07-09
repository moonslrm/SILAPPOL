import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lapangan.dart';
import '../../providers/admin_lapangan_provider.dart';
import '../../services/admin_lapangan_service.dart';
import 'admin_lapangan_form_screen.dart';

class AdminLapanganListScreen extends StatelessWidget {
  const AdminLapanganListScreen({super.key});

  static const String routeName = '/admin/lapangan';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminLapanganProvider>(
      create: (_) =>
          AdminLapanganProvider(adminLapanganService: AdminLapanganService())
            ..loadLapangan(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Daftar Lapangan')),
        body: const _AdminLapanganListContent(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final provider = context.read<AdminLapanganProvider>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  value: provider,
                  child: const AdminLapanganFormScreen(),
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AdminLapanganListContent extends StatelessWidget {
  const _AdminLapanganListContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminLapanganProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.lapangan.isEmpty) {
      return const Center(child: Text('Belum ada lapangan tersedia.'));
    }

    return RefreshIndicator(
      onRefresh: provider.loadLapangan,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: provider.lapangan.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lapangan = provider.lapangan[index];
          return _LapanganCard(lapangan: lapangan);
        },
      ),
    );
  }
}

class _LapanganCard extends StatelessWidget {
  const _LapanganCard({required this.lapangan});

  final Lapangan lapangan;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminLapanganProvider>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    lapangan.namaLapangan,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(
                  label: Text(lapangan.statusAktif ? 'Aktif' : 'Nonaktif'),
                  backgroundColor: lapangan.statusAktif
                      ? Colors.green[100]
                      : Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(lapangan.jenisLapangan),
            const SizedBox(height: 8),
            Text('Harga per jam: Rp${lapangan.hargaPerJam.toInt()}'),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    final provider = context.read<AdminLapanganProvider>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                          value: provider,
                          child: const AdminLapanganFormScreen(),
                        ),
                        settings: RouteSettings(arguments: lapangan),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus lapangan'),
                        content: const Text(
                          'Yakin ingin menghapus lapangan ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    final success = await provider.deleteLapangan(lapangan.id!);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menghapus lapangan.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    final success = await provider.toggleStatus(lapangan.id!);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal mengubah status.')),
                      );
                    }
                  },
                  child: Text(
                    lapangan.statusAktif ? 'Nonaktifkan' : 'Aktifkan',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
