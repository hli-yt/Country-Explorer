import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  final String _baseUrl = 'restcountries.com';
  final Duration _timeout = const Duration(seconds: 10);

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to load data. Status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<Country>> fetchAllCountries() async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/all', {
        'fields':
            'name,flags,region,population,capital,area,currencies,languages,timezones,cca3',
      });

      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      _checkResponse(response);

      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Country.fromJson(json)).toList();
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Unexpected data format received from server.');
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<List<Country>> searchByName(String name) async {
    if (name.trim().isEmpty) return [];

    try {
      final uri = Uri.https(
        _baseUrl,
        '/v3.1/name/${Uri.encodeComponent(name)}',
      );

      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      _checkResponse(response);

      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Country.fromJson(json)).toList();
    } on SocketException {
      throw ApiException('No internet connection.');
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } on FormatException {
      throw ApiException('Unexpected data format received.');
    } catch (e) {
      throw ApiException('Failed to search countries: ${e.toString()}');
    }
  }

  Future<Country> fetchByCode(String code) async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/alpha/$code');

      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      _checkResponse(response);

      final List<dynamic> jsonList = json.decode(response.body);
      return Country.fromJson(jsonList.first);
    } on SocketException {
      throw ApiException('No internet connection.');
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } on FormatException {
      throw ApiException('Unexpected data format received.');
    } catch (e) {
      throw ApiException('Failed to fetch country details.');
    }
  }
}
