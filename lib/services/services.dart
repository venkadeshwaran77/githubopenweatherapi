import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openweatherapi/model/weather_model.dart';

class WeatherService {
  fetchWeather() async {
    final response = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=12.9516&lon=80.1462&appid=79569720cf73b13d6e6d71227418e30d",
      ),
    );
    try {
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        return WeatherData.fromJson(json);
      } else {
        throw Exception('Faild to load Weather data');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
// replace the api key with your api key they openWeathermap provide you
// for your current location provide the longitude and latitude of your current location 