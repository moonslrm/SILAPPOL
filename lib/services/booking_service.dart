import '../models/booking.dart';
import 'api_service.dart';

class BookingService {
  BookingService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<Booking>> getMyBookings() async {
    return _apiService.getBookingSaya();
  }

  Future<Booking> createBooking(Map<String, dynamic> body) async {
    return _apiService.createBooking(
      lapanganId: body['lapangan_id'] as int,
      tanggalSewa: DateTime.parse(body['tanggal_sewa'].toString()),
      jamMulai: body['jam_mulai'].toString(),
      jamSelesai: body['jam_selesai'].toString(),
      jumlahPeserta: body['jumlah_peserta'] as int?,
      catatan: body['catatan'] as String?,
    );
  }

  Future<Booking> cancelBooking(int bookingId) async {
    return _apiService.cancelBooking(bookingId);
  }
}
