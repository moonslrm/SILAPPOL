import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/jadwal_slot.dart';
import '../../models/lapangan.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../booking/booking_form_screen.dart';

class LapanganDetailScreen extends StatefulWidget {
  const LapanganDetailScreen({super.key});

  static const String routeName = '/lapangan-detail';

  @override
  State<LapanganDetailScreen> createState() => _LapanganDetailScreenState();
}

class _LapanganDetailScreenState extends State<LapanganDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  List<JadwalSlot> _slots = const <JadwalSlot>[];
  List<JadwalSlot> _selectedSlots = const <JadwalSlot>[];
  bool _isLoadingSlots = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lapangan = ModalRoute.of(context)?.settings.arguments as Lapangan?;
    if (lapangan != null) {
      _loadSlots(lapangan.id!);
    }
  }

  Future<void> _loadSlots(int lapanganId) async {
    setState(() {
      _isLoadingSlots = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final slots = await apiService.getSlotTersedia(lapanganId, _selectedDate);
      setState(() {
        _slots = slots;
        _selectedSlots = const <JadwalSlot>[];
      });
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  void _toggleSlot(JadwalSlot slot) {
    if (!slot.tersedia) {
      return;
    }

    setState(() {
      final selectedIndices = <int>[];
      for (final selectedSlot in _selectedSlots) {
        final index = _slots.indexWhere(
          (item) => item.jamMulai == selectedSlot.jamMulai,
        );
        if (index >= 0) {
          selectedIndices.add(index);
        }
      }

      final currentIndex = _slots.indexWhere(
        (item) => item.jamMulai == slot.jamMulai,
      );
      if (currentIndex < 0) {
        return;
      }

      final alreadySelected = selectedIndices.contains(currentIndex);
      if (alreadySelected) {
        _selectedSlots = _selectedSlots
            .where((item) => item.jamMulai != slot.jamMulai)
            .toList();
        return;
      }

      if (selectedIndices.isEmpty) {
        _selectedSlots = <JadwalSlot>[slot];
        return;
      }

      final minIndex = selectedIndices.reduce((a, b) => a < b ? a : b);
      final maxIndex = selectedIndices.reduce((a, b) => a > b ? a : b);
      final isAdjacent =
          currentIndex == minIndex - 1 || currentIndex == maxIndex + 1;

      if (!isAdjacent) {
        _selectedSlots = <JadwalSlot>[slot];
        return;
      }

      _selectedSlots = <JadwalSlot>[..._selectedSlots, slot];
      _selectedSlots.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
      _selectedSlots = _selectedSlots.where((item) {
        final itemIndex = _slots.indexWhere(
          (slotItem) => slotItem.jamMulai == item.jamMulai,
        );
        return itemIndex >= minIndex &&
            itemIndex <= maxIndex + (currentIndex > maxIndex ? 1 : 0);
      }).toList();

      if (currentIndex < minIndex) {
        _selectedSlots = [
          ..._selectedSlots.where((item) => item.jamMulai != slot.jamMulai),
          slot,
        ]..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
      }
    });
  }

  bool _isSelected(JadwalSlot slot) {
    return _selectedSlots.any((item) => item.jamMulai == slot.jamMulai);
  }

  @override
  Widget build(BuildContext context) {
    final lapangan = ModalRoute.of(context)?.settings.arguments as Lapangan?;
    final authProvider = context.watch<AuthProvider>();

    if (lapangan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Lapangan')),
        body: const Center(child: Text('Data lapangan tidak tersedia.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(lapangan.namaLapangan)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: lapangan.fotoUrl != null && lapangan.fotoUrl!.isNotEmpty
                ? Image.network(
                    lapangan.fotoUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 220,
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.sports_soccer, size: 36),
                      ),
                    ),
                  )
                : Container(
                    height: 220,
                    color: const Color(0xFFE2E8F0),
                    child: const Center(
                      child: Icon(Icons.sports_soccer, size: 36),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            lapangan.namaLapangan,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            lapangan.jenisLapangan,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Text(lapangan.deskripsi ?? 'Tidak ada deskripsi.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.place_outlined,
                label: lapangan.lokasi ?? 'Lokasi belum tersedia',
              ),
              _InfoChip(
                icon: Icons.attach_money,
                label: 'Rp${lapangan.hargaPerJam.toInt()}/jam',
              ),
              _InfoChip(
                icon: Icons.groups_outlined,
                label: '${lapangan.kapasitas ?? 0} orang',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      await _loadSlots(lapangan.id!);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Pilih slot jam',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_isLoadingSlots)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: Colors.red))
          else if (_slots.isEmpty)
            const Text('Tidak ada slot tersedia untuk tanggal ini.')
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _slots.map((slot) {
                final isSelected = _isSelected(slot);
                return ChoiceChip(
                  label: Text('${slot.jamMulai} - ${slot.jamSelesai}'),
                  selected: isSelected,
                  onSelected: slot.tersedia ? (_) => _toggleSlot(slot) : null,
                  disabledColor: Colors.grey.shade300,
                  selectedColor: const Color(
                    0xFF0F766E,
                  ).withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: slot.tersedia ? null : Colors.grey.shade600,
                  ),
                  avatar: slot.tersedia
                      ? Icon(
                          isSelected ? Icons.check_circle : Icons.schedule,
                          size: 16,
                          color: isSelected ? const Color(0xFF0F766E) : null,
                        )
                      : const Icon(Icons.lock_outline, size: 16),
                  backgroundColor: slot.tersedia ? null : Colors.grey.shade200,
                  selectedShadowColor: const Color(0xFF0F766E),
                  checkmarkColor: const Color(0xFF0F766E),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          if (authProvider.isAuthenticated && _selectedSlots.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  BookingFormScreen.routeName,
                  arguments: BookingFormArguments(
                    lapangan: lapangan,
                    selectedDate: _selectedDate,
                    selectedSlots: _selectedSlots,
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Lanjut Booking'),
            ),
          if (!authProvider.isAuthenticated && _selectedSlots.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              icon: const Icon(Icons.login),
              label: const Text('Login untuk lanjut booking'),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F766E)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
