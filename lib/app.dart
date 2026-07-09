import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/lapangan_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/admin/admin_lapangan_list_screen.dart';
import 'screens/booking/booking_form_screen.dart';
import 'screens/booking/booking_history_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/lapangan/lapangan_detail_screen.dart';
import 'screens/main/app_shell.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/lapangan_service.dart';

class SilappolApp extends StatelessWidget {
  const SilappolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService(), lazy: false),
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(authService: AuthService())..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => LapanganProvider(lapanganService: LapanganService()),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(bookingService: BookingService()),
        ),
      ],
      child: MaterialApp(
        title: 'SILAPPOL',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
          scaffoldBackgroundColor: const Color(0xFFF6F8FB),
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          AppShell.routeName: (_) => const AppShell(),
          BookingHistoryScreen.routeName: (_) => const BookingHistoryScreen(),
          LapanganDetailScreen.routeName: (_) => const LapanganDetailScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          AdminPanelScreen.routeName: (_) => const AdminPanelScreen(),
          AdminLapanganListScreen.routeName: (_) =>
              const AdminLapanganListScreen(),
          BookingFormScreen.routeName: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as BookingFormArguments;
            return BookingFormScreen(
              lapangan: args.lapangan,
              selectedDate: args.selectedDate,
              selectedSlots: args.selectedSlots,
            );
          },
        },
      ),
    );
  }
}
