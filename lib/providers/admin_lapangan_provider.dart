import 'package:flutter/material.dart';

import '../models/lapangan.dart';
import '../services/admin_lapangan_service.dart';

class AdminLapanganProvider extends ChangeNotifier {
  AdminLapanganProvider({required AdminLapanganService adminLapanganService})
    : _adminLapanganService = adminLapanganService;

  final AdminLapanganService _adminLapanganService;

  bool _isLoading = false;
  List<Lapangan> _lapangan = const <Lapangan>[];

  bool get isLoading => _isLoading;
  List<Lapangan> get lapangan => _lapangan;

  Future<void> loadLapangan() async {
    _setLoading(true);
    try {
      _lapangan = await _adminLapanganService.getLapangan();
    } catch (_) {
      _lapangan = const <Lapangan>[];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createLapangan({
    required String namaLapangan,
    required String jenisLapangan,
    String? deskripsi,
    String? lokasi,
    required double hargaPerJam,
    int? kapasitas,
    required bool statusAktif,
  }) async {
    _setLoading(true);
    try {
      final lapangan = await _adminLapanganService.createLapangan(
        namaLapangan: namaLapangan,
        jenisLapangan: jenisLapangan,
        deskripsi: deskripsi,
        lokasi: lokasi,
        hargaPerJam: hargaPerJam,
        kapasitas: kapasitas,
        statusAktif: statusAktif,
      );
      _lapangan = [lapangan, ..._lapangan];
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> updateLapangan({
    required int id,
    required String namaLapangan,
    required String jenisLapangan,
    String? deskripsi,
    String? lokasi,
    required double hargaPerJam,
    int? kapasitas,
    required bool statusAktif,
  }) async {
    _setLoading(true);
    try {
      final lapangan = await _adminLapanganService.updateLapangan(
        id: id,
        namaLapangan: namaLapangan,
        jenisLapangan: jenisLapangan,
        deskripsi: deskripsi,
        lokasi: lokasi,
        hargaPerJam: hargaPerJam,
        kapasitas: kapasitas,
        statusAktif: statusAktif,
      );
      _lapangan = _lapangan
          .map((item) => item.id == id ? lapangan : item)
          .toList(growable: false);
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> deleteLapangan(int id) async {
    _setLoading(true);
    try {
      await _adminLapanganService.deleteLapangan(id);
      _lapangan = _lapangan
          .where((item) => item.id != id)
          .toList(growable: false);
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> toggleStatus(int id) async {
    _setLoading(true);
    try {
      final lapangan = await _adminLapanganService.toggleStatus(id);
      _lapangan = _lapangan
          .map((item) => item.id == id ? lapangan : item)
          .toList(growable: false);
      return true;
    } catch (_) {
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
