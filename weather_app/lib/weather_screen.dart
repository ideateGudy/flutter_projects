import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/api_key.dart';
import 'package:weather_app/hourly_forcast_card.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Map<String, dynamic>? weatherData;
  Map<String, dynamic>? forecastData;
  bool isLoading = true;
  String city = "ugbolu";

  // NEW: Controller for the text field
  final TextEditingController _cityController = TextEditingController();
  // NEW: State to track if the input field is visible
  bool _isSearching = false;

  Future<void> getWeatherForecast() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.weatherapi.com/v1/forecast.json?q=$city&days=1&key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Store forecast data separately
          forecastData = Map<String, dynamic>.from(jsonDecode(response.body));
          isLoading = false;
        });
      } else {
        final errorJson = jsonDecode(response.body);
        final errorMessage = errorJson['error']['message'] ?? 'Unknown error';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load forecast: $errorMessage')),
          );
        }

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Network Error: $e')));
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getWeatherForecast();
  }

  @override
  void dispose() {
    _cityController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  // Helper method to extract 6 hourly cards (Now + 5 at 3-hour intervals)
  List<Widget> buildHourlyForecastCards() {
    // Safely get the hour list from forecastData
    final hourList =
        forecastData?['forecast']?['forecastday']?[0]?['hour']
            as List<dynamic>?;

    if (hourList == null || forecastData == null) return [];

    final current = forecastData!['current'];
    final location = forecastData!['location'];

    // Parse the current hour safely from current data
    final String currentLocalTimeStr = location['localtime'];
    final DateTime currentDateTime = DateTime.parse(currentLocalTimeStr);
    final int currentHour = currentDateTime.hour;

    final List<Widget> cards = [];
    const int cardsToBuild = 10;
    const int intervalHours = 3;

    // --- 1. Card for Current Time ('Now') using current data ---
    cards.add(
      HourlyFocastCard(
        time: 'Now',
        temperature: current['temp_c'].toStringAsFixed(1),
        iconUrl: 'https:${current['condition']['icon']}',
        label: current['condition']['text'],
      ),
    );

    // --- 2. Find the starting index for the 3-hour forecast intervals ---
    int startIndex = currentHour + 1;

    while (startIndex % intervalHours != 0) {
      startIndex++;
    }

    startIndex = startIndex % 24;

    // --- 3. Build the remaining 9 cards (cardsToBuild - 1) ---
    for (int i = 0; i < cardsToBuild - 1; i++) {
      int targetHourIndex = (startIndex + (intervalHours * i)) % 24;

      if (targetHourIndex < hourList.length) {
        final hourlyData = hourList[targetHourIndex];

        final String fullTime = hourlyData['time'];

        // **Simplified Time Extraction: "YYYY-MM-DD HH:MM" -> "HH:MM"**
        final String time = fullTime.split(' ')[1];

        final double tempC = hourlyData['temp_c'];
        final String iconUrl = 'https:${hourlyData['condition']['icon']}';
        final String label = hourlyData['condition']['text'];

        cards.add(
          HourlyFocastCard(
            time: time,
            temperature: tempC.toStringAsFixed(1),
            iconUrl: iconUrl,
            label: label,
          ),
        );
      } else {
        break;
      }
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    // If data is still loading, show a spinner
    if (isLoading || forecastData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Extract required data after ensuring forecastData is not null
    final current = forecastData!['current'];
    final location = forecastData!['location'];

    // Main Card Data
    final currentTempC = current['temp_c'].toString();
    final weatherCondition = current['condition']['text'];
    final iconUrl =
        'http:${current['condition']['icon']}'; // WeatherAPI uses a protocol-relative URL

    // Additional Info Data
    final humidity = current['humidity'].toString();
    final windKph = current['wind_kph'].toString();
    final pressureMb = current['pressure_mb'].toString();

    // Prepare the hourly forecast cards
    final List<Widget> hourlyCards = buildHourlyForecastCards();

    return Scaffold(
      appBar: AppBar(
        // title: Text(
        //   'Weather App for ${location['name']}',
        //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        // ),
        title: _isSearching
            ? Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: TextFormField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Enter City Name",
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    // Option to clear the text
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _cityController.clear();
                      },
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    // When the user submits (hits enter)
                    if (value.isNotEmpty) {
                      setState(() {
                        city = value; // Update the city
                        _isSearching = false; // Close the search bar
                      });
                      getWeatherForecast(); // Fetch new weather
                    }
                  },
                ),
              )
            : Text(
                '${location['name']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        centerTitle: true,
        actions: <Widget>[
          // Search Icon
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching; // Toggle search bar visibility
              });
            },
            // icon: const Icon(Icons.refresh, color: Colors.white),
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
          ),
          // Refresh Icon
          // InkWell / GestureDetector can also be used
          IconButton(
            onPressed:
                getWeatherForecast, // Refresh button - re-fetches current city
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          spacing: 11,
                          children: [
                            Text(
                              "$currentTempC°C", // Display fetched temperature
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Icon(Icons.cloud, size: 64, color: Colors.white),
                            Image.network(
                              iconUrl,
                              height: 100,
                              width: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.error,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                            ),
                            Text(
                              weatherCondition,
                              style: const TextStyle(
                                fontSize: 20,
                                // fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              //Weather forecast cards
              const Text(
                "Weather Forecast",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: hourlyCards,
                ),
              ),
              const SizedBox(height: 20),

              //Additional weather details
              const Text(
                "Additional Information",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    title: "Humidity",
                    value: "$humidity%",
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    title: "Wind Speed",
                    value: "$windKph kph",
                  ),
                  AdditionalInfoItem(
                    icon: Icons.speed,
                    title: "Pressure",
                    value: "$pressureMb hPa",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        // The currently selected index
        selectedIndex: 0,
        // What happens when a destination is tapped (e.g., switch screens)
        onDestinationSelected: (int index) {
          // setState(() { _selectedIndex = index; });
          // Logic to switch the main body content
        },
        // The items shown in the navigation bar
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.cloud_queue), // Your current weather view
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: '7-Day',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
