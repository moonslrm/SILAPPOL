import 'package:flutter/foundation.dart';

import '../models/lapangan.dart';
import '../services/lapangan_service.dart';

class LapanganProvider extends ChangeNotifier {
  LapanganProvider({required LapanganService lapanganService})
    : _lapanganService = lapanganService {
    loadLapangan();
  }

  final LapanganService _lapanganService;

  bool _isLoading = false;
  List<Lapangan> _lapangan = const <Lapangan>[];

  bool get isLoading => _isLoading;
  List<Lapangan> get lapangan => _lapangan;

  Future<void> loadLapangan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _lapanganService.getLapangan();
      _lapangan = items.isNotEmpty ? items : _demoLapangan;
    } catch (_) {
      _lapangan = _demoLapangan;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const List<Lapangan> _demoLapangan = <Lapangan>[
    Lapangan(
      id: 1,
      namaLapangan: 'Lapangan Futsal Utama',
      jenisLapangan: 'Futsal',
      deskripsi:
          'Lapangan indoor dengan pencahayaan penuh dan permukaan sintetis.',
      lokasi: 'Gedung Olahraga Poliban',
      hargaPerJam: 120000,
      kapasitas: 14,
      statusAktif: true,
      fasilitas: <String>['Lampu malam', 'Tribun kecil', 'Parkir'],
    ),
    Lapangan(
      id: 2,
      namaLapangan: 'Lapangan Basket',
      jenisLapangan: 'Basket',
      deskripsi: 'Cocok untuk latihan tim dan pertandingan kampus.',
      lokasi: 'Area Sport Center',
      hargaPerJam: 100000,
      kapasitas: 10,
      statusAktif: true,
      fasilitas: <String>['Ring standar', 'Marka resmi'],
    ),
    Lapangan(
      id: 3,
      namaLapangan: 'Lapangan Badminton',
      jenisLapangan: 'Badminton',
      deskripsi: 'Tersedia beberapa court dengan jadwal fleksibel.',
      lokasi: 'Hall Indoor',
      hargaPerJam: 75000,
      kapasitas: 4,
      statusAktif: true,
      fasilitas: <String>['Net', 'Lampu terang'],
    ),
  ];
}
