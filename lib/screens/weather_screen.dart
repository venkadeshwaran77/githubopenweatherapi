import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openweatherapi/model/weather_model.dart';
import 'package:openweatherapi/services/services.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  late WeatherData weatherInfo;
  bool isLoading = false;
  myWeather() {
    isLoading = false;
    WeatherService().fetchWeather().then((value) {
      setState(() {
        weatherInfo = value;
        isLoading = true;
      });
    });
  }

  @override
  void initState() {
    weatherInfo = WeatherData(
      name: '',
      temperature: Temperature(current: 0.0),
      humidity: 0,
      wind: Wind(speed: 0.0),
      maxTemperature: 0,
      minTemperature: 0,
      pressure: 0,
      seaLevel: 0,
      weather: [],
    );
    myWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      "EEEE ,d MMMM yyyy",
    ).format(DateTime.now());
    String formattedTime = DateFormat("hh:mm a").format(DateTime.now());
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF676BD0),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child:isLoading 
                  ? WeatherDetail(
                    weather: weatherInfo,
                    formattedDate: formattedDate,
                    formattedTime: formattedTime,
                  ): CircularProgressIndicator(color:Colors.white),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final WeatherData weather;
  final String formattedDate;
  final String formattedTime;
  const WeatherDetail({
    super.key,
    required this.weather,
    required this.formattedDate,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // for current address name
        Text(
          weather.name,
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // for current temperature of my location
        Text(
          "${weather.temperature.current.toStringAsFixed(2)}°C",
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        //fpr weather condition
        if (weather.weather.isNotEmpty)
          Text(
            weather.weather[0].main,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        SizedBox(height: 30),
        //for current date and time
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 30),
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/cloudy.png")),
          ),
        ),
        SizedBox(height: 30),
        //for more weather detail
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wind_power, color: Colors.white),
                        SizedBox(height: 5),
                        WeatherInfoCard(
                          title: "Wind",
                          value: "${weather.wind.speed} km/h",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sunny, color: Colors.white),
                        SizedBox(height: 5),
                        WeatherInfoCard(
                          title: "max",
                          value:
                              "${weather.maxTemperature.toStringAsFixed(2)}°C",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sunny_snowing, color: Colors.white),
                        SizedBox(height: 5),
                        WeatherInfoCard(
                          title: "Min",
                          value:
                              "${weather.minTemperature.toStringAsFixed(2)}°C",
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop, color: Colors.amber),
                        SizedBox(height: 5),
                        WeatherInfoCard(
                          title: "Humidity",
                          value: "${weather.humidity}%",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.air, color: Colors.amber),
                        SizedBox(height: 5),
                        WeatherInfoCard(
                          title: "pressure",
                          value: "${weather.pressure} hPa",
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.leaderboard, color: Colors.amber),
                        SizedBox(height: 5),
                        WeatherInfoCard(
                          title: "Sea-Level",
                          value: "${weather.seaLevel}m",
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column WeatherInfoCard({required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
