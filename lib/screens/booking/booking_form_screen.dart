import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lapangan.dart';
import '../../models/jadwal_slot.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../auth/login_screen.dart';
import '../main/app_shell.dart';

class BookingFormArguments {
  const BookingFormArguments({
    required this.lapangan,
    required this.selectedDate,
    required this.selectedSlots,
  });

  final Lapangan lapangan;
  final DateTime selectedDate;
  final List<JadwalSlot> selectedSlots;
}

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    required this.lapangan,
    required this.selectedDate,
    required this.selectedSlots,
  });

  static const String routeName = '/booking-form';

  final Lapangan lapangan;
  final DateTime selectedDate;
  final List<JadwalSlot> selectedSlots;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final TextEditingController _jumlahPesertaController = TextEditingController(
    text: '2',
  );
  final TextEditingController _catatanController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _jumlahPesertaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final totalHarga =
        widget.lapangan.hargaPerJam * widget.selectedSlots.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Booking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Pemesanan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Lapangan',
                    value: widget.lapangan.namaLapangan,
                  ),
                  _InfoRow(
                    label: 'Tanggal',
                    value: _formatDate(widget.selectedDate),
                  ),
                  _InfoRow(
                    label: 'Slot',
                    value: _slotSummary(widget.selectedSlots),
                  ),
                  _InfoRow(label: 'Harga', value: 'Rp${totalHarga.toInt()}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jumlahPesertaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah peserta',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _catatanController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Catatan tambahan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (!authProvider.isAuthenticated)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Silakan login terlebih dahulu untuk mengirim booking.',
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitBooking,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(_isSubmitting ? 'Mengirim...' : 'Konfirmasi Booking'),
          ),
        ),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (!context.read<AuthProvider>().isAuthenticated) {
      Navigator.pushNamed(context, LoginScreen.routeName);
      return;
    }

    if (widget.selectedSlots.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih minimal satu slot.')));
      return;
    }

    if (widget.lapangan.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data lapangan tidak valid.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final booking = await context.read<BookingProvider>().createBooking(
        lapanganId: widget.lapangan.id!,
        tanggalSewa: widget.selectedDate,
        jamMulai: widget.selectedSlots.first.jamMulai,
        jamSelesai: widget.selectedSlots.last.jamSelesai,
        jumlahPeserta: int.tryParse(_jumlahPesertaController.text),
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );

      if (!mounted) return;
      await _showSuccessDialog(booking);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppShell.routeName, (route) => false);
    } catch (error) {
      if (!mounted) return;
      final message = _formatErrorMessage(error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showSuccessDialog(Booking booking) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Booking Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lapangan: ${widget.lapangan.namaLapangan}'),
            const SizedBox(height: 6),
            Text('Tanggal: ${_formatDate(widget.selectedDate)}'),
            const SizedBox(height: 6),
            Text('Jam: ${_slotSummary(widget.selectedSlots)}'),
            const SizedBox(height: 6),
            Text('Status: ${booking.status.label}'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Lihat Riwayat'),
          ),
        ],
      ),
    );
  }

  String _formatErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('ApiException')) {
      final parts = message.split(':');
      if (parts.length > 1) {
        return parts.sublist(1).join(':').trim();
      }
    }

    if (message.contains('slot') ||
        message.contains('terisi') ||
        message.contains('booking')) {
      return 'Slot ini sudah tidak tersedia. Silakan pilih jam lain.';
    }

    return message.contains('Exception:')
        ? message.replaceFirst('Exception: ', '')
        : 'Booking gagal. Silakan coba lagi.';
  }

  String _slotSummary(List<JadwalSlot> slots) {
    if (slots.isEmpty) {
      return '-';
    }

    return slots
        .map((slot) => '${slot.jamMulai}–${slot.jamSelesai}')
        .join(', ');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
