class Country {
  final String name;
  final String flagEmoji;
  final String? flagUrl;
  final String region;
  final String? capital;
  final int? population;
  final double? area;
  final List<String> currencies;
  final List<String> languages;
  final List<String> timezones;
  final String alpha3Code;

  Country({
    required this.name,
    required this.flagEmoji,
    this.flagUrl,
    required this.region,
    this.capital,
    this.population,
    this.area,
    required this.currencies,
    required this.languages,
    required this.timezones,
    required this.alpha3Code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Handle name
    final nameMap = json['name'] as Map<String, dynamic>? ?? {};
    final commonName = nameMap['common'] as String? ?? 'Unknown';

    // Handle flag
    final flags = json['flags'] as Map<String, dynamic>? ?? {};
    final flagEmoji = flags['emoji'] as String? ?? '🏳️';
    final flagUrl = flags['png'] as String?;

    // Handle capital
    final capitalList = json['capital'] as List<dynamic>?;
    final capital = capitalList?.isNotEmpty == true
        ? capitalList!.first as String
        : null;

    // Currencies
    final currenciesMap = json['currencies'] as Map<String, dynamic>? ?? {};
    final currencies = currenciesMap.keys.toList();

    // Languages
    final languagesMap = json['languages'] as Map<String, dynamic>? ?? {};
    final languages = languagesMap.values.cast<String>().toList();

    // Timezones
    final timezonesList = json['timezones'] as List<dynamic>? ?? [];
    final timezones = timezonesList.cast<String>();

    return Country(
      name: commonName,
      flagEmoji: flagEmoji,
      flagUrl: flagUrl,
      region: json['region'] as String? ?? 'Unknown',
      capital: capital,
      population: json['population'] as int?,
      area: (json['area'] as num?)?.toDouble(),
      currencies: currencies,
      languages: languages,
      timezones: timezones,
      alpha3Code: json['cca3'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'flagEmoji': flagEmoji,
      'flagUrl': flagUrl,
      'region': region,
      'capital': capital,
      'population': population,
      'area': area,
      'currencies': currencies,
      'languages': languages,
      'timezones': timezones,
      'alpha3Code': alpha3Code,
    };
  }

  Country copyWith({
    String? name,
    String? flagEmoji,
    String? region,
    String? capital,
    int? population,
    double? area,
    List<String>? currencies,
    List<String>? languages,
    List<String>? timezones,
    String? alpha3Code,
  }) {
    return Country(
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      flagUrl: flagUrl ?? flagUrl,
      region: region ?? this.region,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      area: area ?? this.area,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }
}
