import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'forecast_screen.dart';
import 'map_screen.dart';

// 🌤 Weather Model
class WeatherModel {
  final double temp;
  final String condition;
  final String icon;
  final String locationName;

  WeatherModel({
    required this.temp,
    required this.condition,
    required this.icon,
    required this.locationName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temp: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      icon: "https:${json['current']['condition']['icon']}",
      locationName: json['location']['name'],
    );
  }
}

// 🌐 Fetch Weather API with dynamic city parameter
Future<WeatherModel> fetchWeather(String city) async {
  final url =
      'http://api.weatherapi.com/v1/current.json?key=97c982281aeb41119d670447253107&q=$city&aqi=no';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return WeatherModel.fromJson(data);
  } else {
    throw Exception('Failed to load weather data');
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodayWeatherScreen(),
  ));
}

// 🖼 Main Screen with AppBar & Search Icon with white title and icons
class TodayWeatherScreen extends StatefulWidget {
  const TodayWeatherScreen({super.key});

  @override
  State<TodayWeatherScreen> createState() => _TodayWeatherScreenState();
}

class _TodayWeatherScreenState extends State<TodayWeatherScreen> {
  String city = "Ahmedabad"; // Default city

  void _openSearch() async {
    final typedCity = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySearchScreen()),
    );

    if (typedCity != null && typedCity is String && typedCity.isNotEmpty) {
      setState(() {
        city = typedCity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8C3EFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C3EFF),
        title: Text(
          city,
          style: const TextStyle(color: Colors.white),  // White title text
        ),
        iconTheme: const IconThemeData(color: Colors.white),  // White icons
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: WeatherDetailsScreen(city: city),
    );
  }
}

// 📊 Weather UI with dynamic city parameter
class WeatherDetailsScreen extends StatelessWidget {
  final String city;
  const WeatherDetailsScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherModel>(
      future: fetchWeather(city),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No Data', style: TextStyle(color: Colors.white)));
        }

        final weather = snapshot.data!;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C3EFF), Color(0xFFCF63C1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.network(weather.icon, height: 100),
                  const SizedBox(height: 10),
                  Text("${weather.temp.toStringAsFixed(0)}°",
                      style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(weather.condition,
                      style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 5),
                  Text("Location: ${weather.locationName}",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  Image.asset('assets/image/w2.png', height: 170),
                  const SizedBox(height: 20),

                  // Bottom Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7B2DE3),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Today", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("July 30", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            WeatherTimeTile(time: "15:00", temp: "34°C", icon: "assets/image/w1.png"),
                            WeatherTimeTile(time: "16:00", temp: "33°C", icon: "assets/image/w3.png"),
                            WeatherTimeTile(time: "17:00", temp: "31°C", icon: "assets/image/w3.png"),
                            WeatherTimeTile(time: "18:00", temp: "29°C", icon: "assets/image/w3.png"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // 🗺 Map Screen Button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MapScreen()),
                                );
                              },
                              child: const Icon(Icons.location_on, color: Colors.white, size: 28),
                            ),
                            // ➕ Forecast Button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForecastApp()),
                                );
                              },
                              child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                            ),
                            const Icon(Icons.menu, color: Colors.white, size: 28),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🔹 Time Tile Widget
class WeatherTimeTile extends StatelessWidget {
  final String time;
  final String temp;
  final String icon;

  const WeatherTimeTile({super.key, required this.time, required this.temp, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(temp, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 5),
        Image.asset(icon, height: 30),
        const SizedBox(height: 5),
        Text(time, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

// 🏙 City Search Screen for entering city name
class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitCity() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      Navigator.pop(context, city); // Return city name to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitCity(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitCity,
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
