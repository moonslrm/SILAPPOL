class JadwalSlot {
  const JadwalSlot({
    required this.jamMulai,
    required this.jamSelesai,
    this.tersedia = true,
  });

  final String jamMulai;
  final String jamSelesai;
  final bool tersedia;

  factory JadwalSlot.fromJson(Map<String, dynamic> json) {
    return JadwalSlot(
      jamMulai: (json['jam_mulai'] ?? json['jamMulai'] ?? '') as String,
      jamSelesai: (json['jam_selesai'] ?? json['jamSelesai'] ?? '') as String,
      tersedia: _parseBool(json['tersedia'] ?? json['available'] ?? true),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'tersedia': tersedia,
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
