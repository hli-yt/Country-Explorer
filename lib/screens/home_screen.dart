import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/country.dart';
import 'package:flutter_application_1/services/country_api_service.dart';
import 'package:flutter_application_1/screens/country_detail_screen.dart';
import 'package:flutter_application_1/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountryApiService _apiService = CountryApiService();
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final countries = await _apiService.fetchAllCountries();
      if (mounted) {
        // Sort countries alphabetically by name
        countries.sort((a, b) => a.name.compareTo(b.name));

        setState(() {
          _countries = countries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Explorer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCountries,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCountries,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCountries,
      child: ListView.builder(
        itemCount: _countries.length,
        itemBuilder: (context, index) {
          final country = _countries[index];
          return ListTile(
            leading: _buildFlagImage(country), // Changed to actual flag image
            title: Text(country.name),
            subtitle: Text(country.region),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CountryDetailScreen(country: country),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Method to build flag image for the list
  Widget _buildFlagImage(Country country) {
    // Check if we have a flag URL
    if (country.flagUrl != null && country.flagUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          country.flagUrl!,
          width: 50,
          height: 35,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to emoji if image fails to load
            return Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  country.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          },
        ),
      );
    } else {
      // No flag URL - show emoji
      return Container(
        width: 50,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(country.flagEmoji, style: const TextStyle(fontSize: 20)),
        ),
      );
    }
  }
}
