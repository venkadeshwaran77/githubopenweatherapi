// ignore_for_file: unused_field

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String apiKey = "2c04b222ee7842f39f9183145252705"; //used your api Key

class WeatherApiService {
  final String _baseUrl = "https://www.weatherapi.com/v1";
  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      "$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7",
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Failed to fetch data: ${res.body}");
    }
    final data = json.decode(res.body);
    //check if Api returned an error (invalid location)
    if (data.containsKey('error')) {
      throw Exception(data['error']['message'] ?? 'Invalid location');
    }
    return data;
  }

  //for previous 7 day forecast
  Future<List<Map<String, dynamic>>> getLastSevenDaysWeather(
    String location,
  ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final data = today.subtract(Duration(days: i));
      final formattedDate =
          "${data.year}-${data.month.toString().padLeft(2, "0")}-${data.day.toString().padLeft(2, "0")}";
      final url = Uri.parse(
        "$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate",
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        //check if API returned an error (invalid location)
        if (data.containsKey('error')) {
          throw Exception(data['error']['message'] ?? 'Invalid location');
        }
        if (data['forecast']?['forecastday'] != null) {
          pastWeather.add(data);
        }
      } else {
        debugPrint('failed to fetch past data for $formattedDate:${res.body}');
      }
    }
    return pastWeather;
  }
}
