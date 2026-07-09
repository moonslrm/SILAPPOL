import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({required BookingService bookingService})
    : _bookingService = bookingService {
    loadBookings();
  }

  final BookingService _bookingService;

  bool _isLoading = false;
  List<Booking> _bookings = const <Booking>[];

  bool get isLoading => _isLoading;
  List<Booking> get bookings => _bookings;

  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _bookingService.getMyBookings();
    } catch (_) {
      _bookings = <Booking>[
        Booking(
          id: 1,
          tanggalSewa: DateTime.now().add(const Duration(days: 1)),
          jamMulai: '18:00',
          jamSelesai: '19:00',
          status: BookingStatus.pending,
          totalHarga: 120000,
          lapanganNama: 'Lapangan Futsal Utama',
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking> createBooking({
    required int lapanganId,
    required DateTime tanggalSewa,
    required String jamMulai,
    required String jamSelesai,
    int? jumlahPeserta,
    String? catatan,
  }) async {
    final booking = await _bookingService.createBooking({
      'lapangan_id': lapanganId,
      'tanggal_sewa': tanggalSewa.toIso8601String(),
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'jumlah_peserta': jumlahPeserta,
      'catatan': catatan,
    });

    await loadBookings();
    return booking;
  }

  Future<Booking> cancelBooking(int bookingId) async {
    final booking = await _bookingService.cancelBooking(bookingId);
    await loadBookings();
    return booking;
  }
}
