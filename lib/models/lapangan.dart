class Lapangan {
  const Lapangan({
    this.id,
    required this.namaLapangan,
    required this.jenisLapangan,
    this.deskripsi,
    this.fotoUrl,
    this.foto,
    this.lokasi,
    required this.hargaPerJam,
    this.kapasitas,
    this.statusAktif = true,
    this.fasilitas = const <String>[],
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String namaLapangan;
  final String jenisLapangan;
  final String? deskripsi;
  final String? fotoUrl;
  final String? foto;
  final String? lokasi;
  final double hargaPerJam;
  final int? kapasitas;
  final bool statusAktif;
  final List<String> fasilitas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    final fasilitasData = json['fasilitas'];
    final hargaValue = json['harga_per_jam'] ?? json['hargaPerJam'] ?? 0;

    return Lapangan(
      id: json['id'] as int?,
      namaLapangan:
          (json['nama_lapangan'] ?? json['namaLapangan'] ?? '') as String,
      jenisLapangan:
          (json['jenis_lapangan'] ?? json['jenisLapangan'] ?? '') as String,
      deskripsi: json['deskripsi'] as String?,
      fotoUrl: json['foto_url'] as String? ?? json['fotoUrl'] as String?,
      foto: json['foto'] as String?,
      lokasi: json['lokasi'] as String?,
      hargaPerJam: hargaValue is num
          ? hargaValue.toDouble()
          : double.tryParse(hargaValue.toString()) ?? 0,
      kapasitas: json['kapasitas'] as int?,
      statusAktif: _parseBool(
        json['status_aktif'] ?? json['statusAktif'] ?? true,
      ),
      fasilitas: fasilitasData is List
          ? fasilitasData.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nama_lapangan': namaLapangan,
      'jenis_lapangan': jenisLapangan,
      'deskripsi': deskripsi,
      'foto': foto ?? fotoUrl,
      'foto_url': fotoUrl,
      'lokasi': lokasi,
      'harga_per_jam': hargaPerJam,
      'kapasitas': kapasitas,
      'status_aktif': statusAktif,
      'fasilitas': fasilitas,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  final normalized = value?.toString().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}
