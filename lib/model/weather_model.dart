class WeatherData {
  final String name;
  final Temperature temperature;

  final int humidity;
  final Wind wind;
  final double maxTemperature;
  final double minTemperature;
  final int pressure;
  final int seaLevel;
  final List<WeatherInfo> weather;
  // i have already create a mode her according to my requirement you can also create mode according to your requirement.
  // if you need like my model all the source code are is in description. you can follow

  WeatherData({
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.maxTemperature,
    required this.minTemperature,
    required this.pressure,
    required this.seaLevel,
    required this.weather,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      name: json['name'],
      temperature: Temperature.fromJson(json['main']),
      humidity: json['main']['humidity'],
      wind: Wind.fromJson(json['wind']),
      maxTemperature: (json['main']['temp_max'] - 273.15),//kelvin to celsius
      minTemperature: (json['main']['temp_min'] - 273.15),//kelvin to celsius 
      pressure: json['main']['pressure'],
      seaLevel: json['main']['sea_level'] ?? 0,
      weather: List<WeatherInfo>.from(
        json['weather'].map((weather) => WeatherInfo.fromJson(weather)),
      ),
    );
  }
}

class WeatherInfo {
  final String main;
  WeatherInfo({required this.main});
  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(main: json['main']);
  }
}

class Temperature {
  final double current;
  Temperature({required this.current});
  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      current:( json['temp']-273.15),//kelvin to celsius
    );
    
  }
}

class Wind {
  final double speed;

  Wind({required this.speed});
  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(speed: json['speed']);
  }
}
