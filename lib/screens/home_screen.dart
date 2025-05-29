// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openweatherapi/provider/theme_provider.dart';
import 'package:openweatherapi/screens/weekly_forecast.dart';
import 'package:openweatherapi/services/api_service.dart';


class WeatherAppHomeScreen extends ConsumerStatefulWidget {
  const WeatherAppHomeScreen({super.key});

  @override
  ConsumerState<WeatherAppHomeScreen> createState() =>
      _WeatherAppHomeScreenState();
}

class _WeatherAppHomeScreenState extends ConsumerState<WeatherAppHomeScreen> {
  final _weatherService = WeatherApiService();
  String city = 'Tambaram';
  String country = '';
  Map<String, dynamic> currentValue = {};
  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7Days = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => isLoading = true);

    try {
      final forecast = await _weatherService.getHourlyForecast(city);
      final past = await _weatherService.getPastSevenDaysWeather(city);
      setState(() {
        currentValue = forecast['current'] ?? {};
        hourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];

        // NEW: store next 7 days forecast
        next7Days = forecast['forecast']?['forecastday'] ?? [];

        pastWeek = past;
        city = forecast['location']?['name'] ?? city;
        country = forecast['location']?['country'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        pastWeek = [];
        next7Days = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'City not found or invalid. Please enter a valid city name.',
          ),
        ),
      );
    }
  }

  // 1 am  formate
  String formatTime(String timeString) {
    // hour['time'].toString().split(' ')[1],
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time); // e.g., 1 AM, 5 PM
  }

  @override
  Widget build(BuildContext context) {
    String iconPath = currentValue['condition']?['icon'] ?? '';
    String imageUrl = iconPath.isNotEmpty ? 'https:$iconPath' : '';

    Widget imageWidget =
        imageUrl.isNotEmpty
            ? Image.network(
              imageUrl,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            )
            : SizedBox(); // or a placeholder image
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          SizedBox(width: 25),
          SizedBox(
            width: 270,
            height: 50,
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ), // Text color when typing
              // controller: emailController,
              onSubmitted: (value) {
                if (value.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a city name')),
                  );
                  return;
                }

                city = value.trim();
                _fetchWeather();
              },
              decoration: InputDecoration(
                labelText: 'Search City',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.surface,
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(15),
                // ),
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
            const Center(child: CircularProgressIndicator())
          else ...[
            if (currentValue.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$city${country.isNotEmpty ? ', $country' : ''}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:25,
                      color: Theme.of(context).colorScheme.secondary,

                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${currentValue['temp_c']}°C',
                    style: TextStyle(
                      fontSize:30,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${currentValue['condition']['text']}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary , fontSize:18),
                  ),
                  imageWidget,
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 100,

                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.white,width: 0.5),
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary,
                            offset: Offset(1, 1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                "https://cdn-icons-png.flaticon.com/512/3262/3262966.png",
                                height: 30,
                                width: 30,
                              ),
                              Text(
                                '${currentValue['humidity']}%',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Humidity',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                "https://cdn-icons-png.flaticon.com/512/5918/5918654.png",
                                height: 30,
                                width: 30,
                              ),
                              Text(
                                '${currentValue['wind_kph']} kph',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Wind',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                "https://cdn-icons-png.flaticon.com/512/6281/6281340.png",
                                height: 30,
                                width: 30,
                              ),
                              Text(
                                '${hourly.isNotEmpty ? hourly.map((h) => h['temp_c']).reduce((a, b) => a > b ? a : b) : 'N/A'}°C',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Max Temp',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                   ),
                   ),
                  const SizedBox(height:20),
                  Container(
                    height:250,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height:10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today Forecast",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => WeeklyForecast(
                                            pastWeek: pastWeek,
                                            currentValue: currentValue,
                                            city: city,
                                            next7Days: next7Days,
                                          ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Weekly Forecast",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:  Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Theme.of(context).colorScheme.secondary),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: hourly.length,
                            itemBuilder: (context, index) {
                              final hour = hourly[index];
                              final now = DateTime.now();
                              final hourTime = DateTime.parse(hour['time']);
                              final isCurrentHour =
                                  now.hour == hourTime.hour &&
                                  now.day == hourTime.day;

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 70,
                                  // margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isCurrentHour
                                            ? Colors.orangeAccent
                                            : Colors.black38,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isCurrentHour
                                            ? "Now"
                                            : formatTime(hour['time']),
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Image.network(
                                        'https:${hour['condition']?['icon']}',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        // color: Colors.white, // 2025-05-25 01:00
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '${hour['temp_c']}°C',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
