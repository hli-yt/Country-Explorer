import 'package:flutter/material.dart';
import '../models/country.dart';

class CountryDetailScreen extends StatelessWidget {
  final Country country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag - Only the actual flag image, no emoji
            Center(child: _buildFlagImage()),
            const SizedBox(height: 20),

            // Basic Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Region', country.region),
                    _buildInfoRow('Capital', country.capital ?? 'N/A'),
                    _buildInfoRow(
                      'Population',
                      country.population != null
                          ? country.population!.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      'Area',
                      country.area != null
                          ? '${country.area!.toStringAsFixed(0)} km²'
                          : 'N/A',
                    ),
                    _buildInfoRow('Alpha Code', country.alpha3Code),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Currencies
            if (country.currencies.isNotEmpty)
              _buildSection(
                'Currencies',
                country.currencies.map((c) => Text('• $c')).toList(),
              ),

            const SizedBox(height: 10),

            // Languages
            if (country.languages.isNotEmpty)
              _buildSection(
                'Languages',
                country.languages.map((l) => Text('• $l')).toList(),
              ),

            const SizedBox(height: 10),

            // Timezones
            if (country.timezones.isNotEmpty)
              _buildSection(
                'Timezones',
                country.timezones.map((tz) => Text('• $tz')).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagImage() {
    // Check if we have a flag URL
    if (country.flagUrl != null && country.flagUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          country.flagUrl!,
          width: 200,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            // Show loading indicator while image loads
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a placeholder if image fails to load
            return Container(
              width: 200,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flag, size: 48, color: Colors.grey),
                    SizedBox(height: 4),
                    Text(
                      'Flag unavailable',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      // No flag URL available - show placeholder
      return Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag, size: 48, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                'Flag unavailable',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
}
