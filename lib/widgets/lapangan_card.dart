import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/lapangan.dart';

class LapanganCard extends StatelessWidget {
  const LapanganCard({super.key, required this.lapangan, this.onTap});

  final Lapangan lapangan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lapangan.namaLapangan,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lapangan.jenisLapangan,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: lapangan.statusAktif
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      lapangan.statusAktif ? 'Aktif' : 'Nonaktif',
                      style: textTheme.labelMedium?.copyWith(
                        color: lapangan.statusAktif
                            ? const Color(0xFF047857)
                            : const Color(0xFFB91C1C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                lapangan.deskripsi ?? 'Deskripsi lapangan belum tersedia.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: lapangan.lokasi ?? 'Lokasi belum ditentukan',
                  ),
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: currency.format(lapangan.hargaPerJam),
                  ),
                  if (lapangan.kapasitas != null)
                    _InfoChip(
                      icon: Icons.groups_outlined,
                      label: '${lapangan.kapasitas} pemain',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      padding: EdgeInsets.zero,
      side: BorderSide.none,
      backgroundColor: const Color(0xFFF1F5F9),
    );
  }
}
