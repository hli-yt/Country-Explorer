import 'package:flutter/material.dart';

import '../models/country.dart';
import '../services/country_api_service.dart';
import 'country_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CountryApiService _apiService = CountryApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Country> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchCountries(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.searchByName(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _searchResults = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Countries')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Type country name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchCountries('');
                  },
                ),
              ),
              onChanged: _searchCountries,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildSearchBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _searchCountries(_searchController.text),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(child: Text('No countries found'));
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text('Search for a country above'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final country = _searchResults[index];
        return ListTile(
          leading: Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 30),
          ),
          title: Text(country.name),
          subtitle: Text(country.region),
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
    );
  }
}
