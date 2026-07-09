import 'package:flutter/material.dart';

import 'admin_lapangan_list_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  static const String routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                leading: const Icon(Icons.sports_tennis, size: 32),
                title: const Text('Kelola Lapangan'),
                subtitle: const Text(
                  'Tambah, edit, hapus, dan aktifkan lapangan.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AdminLapanganListScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
