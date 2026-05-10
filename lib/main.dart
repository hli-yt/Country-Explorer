import 'package:flutter/material.dart';
import 'package:tracker/services/pin_vault.dart';
import 'package:tracker/services/prefs_service.dart';
import 'package:tracker/screens/pin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PrefsService().getIsDark(),
      builder: (context, snapshot) {
        final isDark = snapshot.data ?? false;

        return MaterialApp(
          title: 'MyMoney',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const InitialScreen(),
        );
      },
    );
  }
}

// This decides whether to show PIN screen or directly go to expenses
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PinVault().hasPin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no PIN exists yet → Setup mode
        if (snapshot.data == false) {
          return const PinScreen(isSetup: true);
        }

        // PIN exists → Verify mode
        return const PinScreen(isSetup: false);
      },
    );
  }
}
