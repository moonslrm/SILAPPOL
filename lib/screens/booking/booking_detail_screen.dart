import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/booking_provider.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.booking});

  static const String routeName = '/booking-detail';

  final Booking booking;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final canCancel = _canCancelBooking(widget.booking);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Booking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.booking.lapanganNama ??
                              'Booking #${widget.booking.id ?? '-'}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _StatusBadge(status: widget.booking.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Tanggal',
                    value: dateFormat.format(widget.booking.tanggalSewa),
                  ),
                  _InfoRow(
                    label: 'Jam',
                    value:
                        '${widget.booking.jamMulai} - ${widget.booking.jamSelesai}',
                  ),
                  _InfoRow(
                    label: 'Jumlah peserta',
                    value: widget.booking.jumlahPeserta?.toString() ?? '-',
                  ),
                  _InfoRow(
                    label: 'Catatan',
                    value: widget.booking.catatan ?? '-',
                  ),
                  _InfoRow(
                    label: 'Total harga',
                    value: 'Rp${widget.booking.totalHarga.toInt()}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (canCancel)
            FilledButton.icon(
              onPressed: _isCancelling ? null : _cancelBooking,
              icon: _isCancelling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cancel_outlined),
              label: Text(
                _isCancelling ? 'Membatalkan...' : 'Batalkan Booking',
              ),
            ),
          if (!canCancel)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.booking.status == BookingStatus.pending
                    ? 'Pembatalan hanya diperbolehkan maksimal H-1 dari jadwal.'
                    : 'Booking tidak dapat dibatalkan pada status saat ini.',
              ),
            ),
        ],
      ),
    );
  }

  bool _canCancelBooking(Booking booking) {
    if (booking.status != BookingStatus.pending) {
      return false;
    }

    final now = DateTime.now();
    final bookingTime = DateTime(
      booking.tanggalSewa.year,
      booking.tanggalSewa.month,
      booking.tanggalSewa.day,
      int.parse(booking.jamMulai.split(':').first),
      int.parse(booking.jamMulai.split(':').last),
    );

    return bookingTime.isAfter(now.add(const Duration(hours: 1)));
  }

  Future<void> _cancelBooking() async {
    setState(() => _isCancelling = true);

    try {
      await context.read<BookingProvider>().cancelBooking(widget.booking.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking berhasil dibatalkan.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
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
            width: 110,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BookingStatus.pending => Colors.orange,
      BookingStatus.confirmed => Colors.green,
      BookingStatus.completed => Colors.blue,
      BookingStatus.cancelled => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
