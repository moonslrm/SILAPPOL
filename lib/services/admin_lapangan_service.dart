import '../models/lapangan.dart';
import 'api_service.dart';

class AdminLapanganService {
  AdminLapanganService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<Lapangan>> getLapangan() async {
    return _apiService.getAdminLapangan();
  }

  Future<Lapangan> createLapangan({
    required String namaLapangan,
    required String jenisLapangan,
    String? deskripsi,
    String? lokasi,
    required double hargaPerJam,
    int? kapasitas,
    required bool statusAktif,
  }) async {
    return _apiService.createAdminLapangan(
      namaLapangan: namaLapangan,
      jenisLapangan: jenisLapangan,
      deskripsi: deskripsi,
      lokasi: lokasi,
      hargaPerJam: hargaPerJam,
      kapasitas: kapasitas,
      statusAktif: statusAktif,
    );
  }

  Future<Lapangan> updateLapangan({
    required int id,
    required String namaLapangan,
    required String jenisLapangan,
    String? deskripsi,
    String? lokasi,
    required double hargaPerJam,
    int? kapasitas,
    required bool statusAktif,
  }) async {
    return _apiService.updateAdminLapangan(
      id: id,
      namaLapangan: namaLapangan,
      jenisLapangan: jenisLapangan,
      deskripsi: deskripsi,
      lokasi: lokasi,
      hargaPerJam: hargaPerJam,
      kapasitas: kapasitas,
      statusAktif: statusAktif,
    );
  }

  Future<void> deleteLapangan(int id) async {
    await _apiService.deleteAdminLapangan(id);
  }

  Future<Lapangan> toggleStatus(int id) async {
    return _apiService.toggleAdminLapanganStatus(id);
  }
}
