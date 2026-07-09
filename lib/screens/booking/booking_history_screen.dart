import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import 'booking_detail_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  static const String routeName = '/booking-history';

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  BookingStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    final filteredBookings = bookingProvider.bookings.where((booking) {
      if (_selectedFilter == null) {
        return true;
      }
      return booking.status == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Saya')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua',
                  status: null,
                  isSelected: _selectedFilter == null,
                  onSelected: () => setState(() => _selectedFilter = null),
                ),
                _FilterChip(
                  label: 'Pending',
                  status: BookingStatus.pending,
                  isSelected: _selectedFilter == BookingStatus.pending,
                  onSelected: () =>
                      setState(() => _selectedFilter = BookingStatus.pending),
                ),
                _FilterChip(
                  label: 'Terkonfirmasi',
                  status: BookingStatus.confirmed,
                  isSelected: _selectedFilter == BookingStatus.confirmed,
                  onSelected: () =>
                      setState(() => _selectedFilter = BookingStatus.confirmed),
                ),
                _FilterChip(
                  label: 'Selesai',
                  status: BookingStatus.completed,
                  isSelected: _selectedFilter == BookingStatus.completed,
                  onSelected: () =>
                      setState(() => _selectedFilter = BookingStatus.completed),
                ),
                _FilterChip(
                  label: 'Dibatalkan',
                  status: BookingStatus.cancelled,
                  isSelected: _selectedFilter == BookingStatus.cancelled,
                  onSelected: () =>
                      setState(() => _selectedFilter = BookingStatus.cancelled),
                ),
              ],
            ),
          ),
          Expanded(
            child: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBookings.isEmpty
                ? const Center(
                    child: Text('Belum ada booking pada filter ini.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BookingDetailScreen(booking: booking),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.lapanganNama ??
                                            'Booking #${booking.id ?? '-'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${dateFormat.format(booking.tanggalSewa)} • ${booking.jamMulai} - ${booking.jamSelesai}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _StatusBadge(status: booking.status),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemCount: filteredBookings.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.status,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final BookingStatus? status;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
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
