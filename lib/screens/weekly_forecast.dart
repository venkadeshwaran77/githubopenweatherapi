// ignore_for_file: unnecessary_to_list_in_spreads, must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class WeeklyForecast extends StatefulWidget {
   final Map<String, dynamic> currentValue;
   final String city;
  final List<dynamic> pastWeek;
  List<dynamic> next7Days;
  WeeklyForecast({
    super.key,
    required this.pastWeek,
    required this.currentValue,
    required this.city,
    required this.next7Days,
  });

  @override
  State<WeeklyForecast> createState() => _WeeklyForecastState();
}

class _WeeklyForecastState extends State<WeeklyForecast> {
  String formatApiDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM, EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.city,
                      style:  TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${widget.currentValue['temp_c']}°C',
                      style:  TextStyle(
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.currentValue['condition']['text']}',
                      style: TextStyle(color: Colors.white70, fontSize: 20),
                    ),
                    Image.network(
                      'https:${widget.currentValue['condition']?['icon'] ?? ''}',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),

              // Next 7 Days Forecast
              const SizedBox(height: 20),
               Text(
                'Next 7 Days Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.next7Days.map((day) {
                final date = day['date'] ?? '';
                final condition = day['day']?['condition']?['text'] ?? '';
                final icon = day['day']?['condition']?['icon'] ?? '';
                final maxTemp = day['day']?['maxtemp_c'] ?? '';
                final minTemp = day['day']?['mintemp_c'] ?? '';

                return ListTile(
                  leading: Image.network('https:$icon', width: 40),
                  title: Text(
                    formatApiDate(date),
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  subtitle: Text(
                    '$condition • $minTemp°C - $maxTemp°C',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
               Text(
                'Previous 7 Days Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.pastWeek.map((entry) {
                final forecastDay = entry['forecast']?['forecastday'];
                if (forecastDay == null || forecastDay.isEmpty) {
                  return const SizedBox.shrink();
                }
                final forecast = forecastDay[0];
                final date = forecast['date'] ?? 'N/A';
                final maxTemp = forecast['day']?['maxtemp_c'] ?? '';
                final minTemp = forecast['day']?['mintemp_c'] ?? '';
                final conditionMap = forecast['day']?['condition'] ?? {};
                final icon = 'https:${conditionMap['icon'] ?? ''}';
                final condition = conditionMap['text'] ?? '';

                return ListTile(
                  leading: Image.network(icon, width: 40),
                  title: Text(
                    formatApiDate(date),
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  subtitle: Text(
                    '$condition • $minTemp°C - $maxTemp°C',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
