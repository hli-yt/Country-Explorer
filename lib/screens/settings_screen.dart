import 'package:flutter/material.dart';
import 'package:tracker/services/prefs_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PrefsService _prefs = PrefsService();

  String _currency = "ETB";
  bool _isDarkMode = false;

  final List<String> _currencies = ["ETB", "USD", "EUR"];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final currency = await _prefs.getCurrency();
    final isDark = await _prefs.getIsDark();

    setState(() {
      _currency = currency;
      _isDarkMode = isDark;
    });
  }

  Future<void> _saveCurrency(String newCurrency) async {
    await _prefs.setCurrency(newCurrency);
    setState(() => _currency = newCurrency);
  }

  Future<void> _toggleTheme(bool value) async {
    await _prefs.setIsDark(value);
    setState(() => _isDarkMode = value);

    // Show message - theme will apply after app restart
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Theme will change after restarting the app"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Currency Setting
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Currency",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: _currencies.map((c) {
                      return ButtonSegment<String>(value: c, label: Text(c));
                    }).toList(),
                    selected: {_currency},
                    onSelectionChanged: (Set<String> selection) {
                      _saveCurrency(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Theme Setting
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Appearance",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text("Dark Mode"),
                    subtitle: const Text("Restart app to apply"),
                    value: _isDarkMode,
                    onChanged: _toggleTheme,
                    secondary: const Icon(Icons.dark_mode),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "MyMoney v1.0\nAll data is stored locally on your device.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
