import '../models/jadwal_slot.dart';
import '../models/lapangan.dart';
import 'api_service.dart';

class LapanganService {
  LapanganService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<Lapangan>> getLapangan() async {
    return _apiService.getLapangan();
  }

  Future<Lapangan> getDetailLapangan(int id) async {
    return _apiService.getDetailLapangan(id);
  }

  Future<List<JadwalSlot>> getAvailableSlots({
    required int lapanganId,
    required DateTime tanggal,
  }) async {
    return _apiService.getSlotTersedia(lapanganId, tanggal);
  }
}
