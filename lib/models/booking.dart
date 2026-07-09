import 'lapangan.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

extension BookingStatusLabel on BookingStatus {
  String get value => switch (this) {
    BookingStatus.pending => 'pending',
    BookingStatus.confirmed => 'confirmed',
    BookingStatus.completed => 'completed',
    BookingStatus.cancelled => 'cancelled',
  };

  String get label => switch (this) {
    BookingStatus.pending => 'Pending',
    BookingStatus.confirmed => 'Terkonfirmasi',
    BookingStatus.completed => 'Selesai',
    BookingStatus.cancelled => 'Dibatalkan',
  };
}

BookingStatus bookingStatusFromString(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'confirmed':
      return BookingStatus.confirmed;
    case 'completed':
      return BookingStatus.completed;
    case 'cancelled':
    case 'canceled':
      return BookingStatus.cancelled;
    default:
      return BookingStatus.pending;
  }
}

class Booking {
  const Booking({
    this.id,
    this.userId,
    this.lapanganId,
    this.lapanganNama,
    this.lapangan,
    required this.tanggalSewa,
    required this.jamMulai,
    required this.jamSelesai,
    this.jumlahPeserta,
    this.catatan,
    this.status = BookingStatus.pending,
    required this.totalHarga,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final int? lapanganId;
  final String? lapanganNama;
  final Lapangan? lapangan;
  final DateTime tanggalSewa;
  final String jamMulai;
  final String jamSelesai;
  final int? jumlahPeserta;
  final String? catatan;
  final BookingStatus status;
  final double totalHarga;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Booking.fromJson(Map<String, dynamic> json) {
    final lapanganPayload = json['lapangan'];
    final lapangan = lapanganPayload is Map<String, dynamic>
        ? Lapangan.fromJson(lapanganPayload)
        : null;

    return Booking(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      lapanganId: json['lapangan_id'] as int?,
      lapanganNama:
          json['lapangan_nama'] as String? ??
          json['lapanganNama'] as String? ??
          lapangan?.namaLapangan,
      lapangan: lapangan,
      tanggalSewa: DateTime.parse(
        (json['tanggal_sewa'] ?? json['tanggalSewa']) as String,
      ),
      jamMulai: (json['jam_mulai'] ?? json['jamMulai'] ?? '') as String,
      jamSelesai: (json['jam_selesai'] ?? json['jamSelesai'] ?? '') as String,
      jumlahPeserta:
          json['jumlah_peserta'] as int? ?? json['jumlahPeserta'] as int?,
      catatan: json['catatan'] as String?,
      status: bookingStatusFromString(json['status'] as String?),
      totalHarga: (json['total_harga'] ?? json['totalHarga'] ?? 0).toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'lapangan_id': lapanganId,
      'lapangan_nama': lapanganNama,
      'lapangan': lapangan?.toJson(),
      'tanggal_sewa':
          '${tanggalSewa.year.toString().padLeft(4, '0')}-${tanggalSewa.month.toString().padLeft(2, '0')}-${tanggalSewa.day.toString().padLeft(2, '0')}',
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'jumlah_peserta': jumlahPeserta,
      'catatan': catatan,
      'status': status.value,
      'total_harga': totalHarga,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
