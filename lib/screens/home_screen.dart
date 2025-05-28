// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openweatherapi/provider/theme_provider.dart';
import 'package:openweatherapi/services/api_service.dart';

class WeatherAppHomeScreen extends ConsumerStatefulWidget {
  const WeatherAppHomeScreen({super.key});

  @override
  ConsumerState<WeatherAppHomeScreen> createState() =>
      _WeatherAppHomeScreenState();
}

class _WeatherAppHomeScreenState extends ConsumerState<WeatherAppHomeScreen> {
  final _weatherService = WeatherApiService();
  String city = "Tambaram"; //initially
  String country = "";
  Map<String, dynamic> currentValue = {};
  List<dynamic> hourly = [];
  List<dynamic> pastweek = [];
  List<dynamic> next7days = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final forecast = await _weatherService.getHourlyForecast(city);
      final past = await _weatherService.getPastSevenDaysWeather(city);

      setState(() {
        currentValue = forecast['current'] ?? {};
        hourly = forecast['forecast']?['forcastday']?[0]?['hour'] ?? [];

        // for next 7 day forecast
        next7days = forecast['forecast']?['forcastday'] ?? [];

        pastweek = past;
        city = forecast['location']?['name'] ?? city;
        country = forecast['location']?['country'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        pastweek = [];
        next7days = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "City not found or invalid. please enter a valid city name.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    String iconPath = currentValue['condition']?['icon'] ?? '';
    String imageUrl = iconPath.isNotEmpty ? "https:$iconPath" : "";

    Widget imageWidgets =
        imageUrl.isNotEmpty
            ? Image.network(
              imageUrl,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
            : SizedBox();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          SizedBox(width: 25),
          SizedBox(
            width: 300,
            height: 50,
            child: TextField(
              style: TextStyle(
                color:Theme.of(context).colorScheme.secondary,
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please Enter a city name")),
                  );
                  return;
                }
                city = value.trim();
                _fetchWeather();
              },
              decoration: InputDecoration(
                labelText: "Search City",
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.surface,
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: notifier.toggleTheme,
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.black : Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 25),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else ...[
            if (currentValue.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "$city${country.isNotEmpty ? ',$country' : ''}",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "${currentValue['temp_c']}°C",
                    style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${currentValue['condition']['text']}",
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  imageWidgets,
                  Padding(
                  padding: EdgeInsets.all(15),
                  child:Container(
                  height:100,
                  width: double.maxFinite,
                  decoration:BoxDecoration(
                    color:Theme.of(context).primaryColor,
                    boxShadow:[
                      BoxShadow(
                        color:Theme.of(context).colorScheme.primary,
                        offset:Offset(1, 1),
                        blurRadius:10,
                        spreadRadius:1,
                      ),
                    ],
                    borderRadius:BorderRadius.circular(30),
                  ),
                  child:Row(
                    mainAxisAlignment:MainAxisAlignment.spaceAround,
                    
                    children: [
                      // for humidity
                      Column(
                      children: [
                         Image.network("https://cdn-icons-png.flaticon.com/512/6393/6393411.png",
                    width:30,
                    height:30
                    ),
                    Text("${currentValue['humidity']}%",
                     style:TextStyle(
                      color:Theme.of(context).colorScheme.secondary,
                      fontWeight:FontWeight.bold,
                     ),
                    ),
                    Text(
                    "Humidity",
                    style:TextStyle(
                      color:Theme.of(context).colorScheme.secondary,
                    ) ,
                     ),
                      ],
                    ),
                    // for Wind
                     Column(
                      children: [
                         Image.network("https://cdn.iconscout.com/icon/free/png-256/free-wind-icon-download-in-svg-png-gif-file-formats--air-turbine-weather-windy-flat-pack-icons-38919.png?f=webp&w=256",
                    width:30,
                    height:30
                    ),
                    Text("${currentValue['wind_kph']} kph ",
                     style:TextStyle(
                      color:Theme.of(context).colorScheme.secondary,
                      fontWeight:FontWeight.bold,
                     ),
                    ),
                    Text(
                    "Wind",
                    style:TextStyle(
                      color:Theme.of(context).colorScheme.secondary,
                    ) ,
                     ),
                      ],
                    ),
                    ],
                  ),
                  ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
