import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lapangan.dart';
import '../../providers/admin_lapangan_provider.dart';

class AdminLapanganFormScreen extends StatefulWidget {
  const AdminLapanganFormScreen({super.key});

  static const String routeName = '/admin/lapangan/form';

  @override
  State<AdminLapanganFormScreen> createState() =>
      _AdminLapanganFormScreenState();
}

class _AdminLapanganFormScreenState extends State<AdminLapanganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jenisController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kapasitasController = TextEditingController();
  bool _statusAktif = true;
  Lapangan? _lapangan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lapangan != null) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Lapangan) {
      _lapangan = args;
      _nameController.text = _lapangan!.namaLapangan;
      _jenisController.text = _lapangan!.jenisLapangan;
      _deskripsiController.text = _lapangan!.deskripsi ?? '';
      _lokasiController.text = _lapangan!.lokasi ?? '';
      _hargaController.text = _lapangan!.hargaPerJam.toStringAsFixed(0);
      _kapasitasController.text = _lapangan!.kapasitas?.toString() ?? '';
      _statusAktif = _lapangan!.statusAktif;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jenisController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _hargaController.dispose();
    _kapasitasController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AdminLapanganProvider>();
    final namaLapangan = _nameController.text.trim();
    final jenisLapangan = _jenisController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final lokasi = _lokasiController.text.trim();
    final hargaPerJam = double.tryParse(_hargaController.text.trim()) ?? 0;
    final kapasitas = int.tryParse(_kapasitasController.text.trim());

    final success = _lapangan != null
        ? await provider.updateLapangan(
            id: _lapangan!.id!,
            namaLapangan: namaLapangan,
            jenisLapangan: jenisLapangan,
            deskripsi: deskripsi.isEmpty ? null : deskripsi,
            lokasi: lokasi.isEmpty ? null : lokasi,
            hargaPerJam: hargaPerJam,
            kapasitas: kapasitas,
            statusAktif: _statusAktif,
          )
        : await provider.createLapangan(
            namaLapangan: namaLapangan,
            jenisLapangan: jenisLapangan,
            deskripsi: deskripsi.isEmpty ? null : deskripsi,
            lokasi: lokasi.isEmpty ? null : lokasi,
            hargaPerJam: hargaPerJam,
            kapasitas: kapasitas,
            statusAktif: _statusAktif,
          );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _lapangan != null
              ? 'Gagal memperbarui lapangan.'
              : 'Gagal menambahkan lapangan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _lapangan != null;
    final provider = context.watch<AdminLapanganProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Lapangan' : 'Tambah Lapangan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lapangan'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lapangan wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jenisController,
                decoration: const InputDecoration(labelText: 'Jenis Lapangan'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jenis lapangan wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                decoration: const InputDecoration(labelText: 'Harga per jam'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga per jam wajib diisi.';
                  }

                  if (double.tryParse(value.trim()) == null) {
                    return 'Harga per jam harus berupa angka.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kapasitasController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                decoration: const InputDecoration(labelText: 'Kapasitas'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _statusAktif,
                title: const Text('Status Aktif'),
                onChanged: (value) => setState(() => _statusAktif = value),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: provider.isLoading ? null : () => _submit(context),
                child: Text(
                  provider.isLoading
                      ? 'Memproses...'
                      : isEditing
                      ? 'Update Lapangan'
                      : 'Tambah Lapangan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
