import 'package:flutter/material.dart';
import 'package:tracker/services/pin_vault.dart';
import 'package:tracker/services/expenses_db.dart';
import 'package:tracker/screens/expenses_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup; // true = first time setup, false = normal login

  const PinScreen({super.key, required this.isSetup});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final PinVault _pinVault = PinVault();
  String _title = '';
  String _buttonText = '';

  @override
  void initState() {
    super.initState();
    _title = widget.isSetup ? "Set up 4-digit PIN" : "Enter your PIN";
    _buttonText = widget.isSetup ? "Save PIN" : "Unlock";
  }

  Future<void> _submitPin() async {
    String pin = _pinController.text.trim();

    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showMessage("Please enter a valid 4-digit PIN");
      return;
    }

    if (widget.isSetup) {
      // First time setup
      await _pinVault.savePin(pin);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExpensesScreen()),
        );
      }
    } else {
      // Normal login
      bool isCorrect = await _pinVault.verifyPin(pin);
      if (isCorrect) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ExpensesScreen()),
          );
        }
      } else {
        _showMessage("Incorrect PIN");
        _pinController.clear();
      }
    }
  }

  Future<void> _resetPin() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset PIN?"),
        content: const Text(
          "This will delete your PIN and ALL expenses.\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _pinVault.reset();
      await ExpensesDb.instance.deleteAll(); // We'll add this method

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PinScreen(isSetup: true)),
        );
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyMoney"),
        actions: [
          if (!widget.isSetup)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Reset PIN",
              onPressed: _resetPin,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 32),
            Text(
              _title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, letterSpacing: 8),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "••••",
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitPin,
                child: Text(_buttonText, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
