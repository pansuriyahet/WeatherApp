import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'today_weather_screen.dart';

// 🌤 Forecast Data Model
class ForecastDay {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String iconUrl;

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.iconUrl,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'],
      minTemp: json['day']['mintemp_c'],
      iconUrl: 'https:${json['day']['condition']['icon']}',
    );
  }
}

// 🌐 Fetch Weather API with dynamic city
Future<List<ForecastDay>> fetch7DayForecast(String city) async {
  final url =
      'http://api.weatherapi.com/v1/forecast.json?key=97c982281aeb41119d670447253107&q=$city&days=7&aqi=no&alerts=no';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final forecastList = jsonData['forecast']['forecastday'] as List;
    return forecastList.map((item) => ForecastDay.fromJson(item)).toList();
  } else {
    throw Exception('Failed to fetch forecast');
  }
}

// 🔠 Convert date to weekday
String getDayName(String dateStr) {
  final date = DateTime.parse(dateStr);
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  return days[date.weekday % 7];
}

// 🏙 City Search Screen (same as your TodayWeatherScreen's search)
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
      Navigator.pop(context, city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C3EFF),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Search City', style: TextStyle(color: Colors.white)),
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

// 🌈 Forecast App
class ForecastApp extends StatelessWidget {
  const ForecastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SevenDayForecastScreen(),
    );
  }
}

// 📱 Forecast Screen (Stateful)
class SevenDayForecastScreen extends StatefulWidget {
  const SevenDayForecastScreen({super.key});

  @override
  State<SevenDayForecastScreen> createState() => _SevenDayForecastScreenState();
}

class _SevenDayForecastScreenState extends State<SevenDayForecastScreen> {
  int selectedIndex = -1;
  String city = 'Ahmedabad';  // Default city

  void _openSearch() async {
    final typedCity = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySearchScreen()),
    );

    if (typedCity != null && typedCity is String && typedCity.isNotEmpty) {
      setState(() {
        city = typedCity;
        selectedIndex = -1;  // reset selection on new city
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8C3EFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8C3EFF),
        title: Text(city, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8C3EFF), Color(0xFFCF63C1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 Back Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodayWeatherScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 20),

                // 📍 Location Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text("Live 7-Day Forecast",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                const Text(
                  "7-Days Forecasts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔄 Forecast List from API
                SizedBox(
                  height: 140,
                  child: FutureBuilder<List<ForecastDay>>(
                    future: fetch7DayForecast(city),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        final forecast = snapshot.data!;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: forecast.length,
                          itemBuilder: (context, index) {
                            final day = forecast[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: ForecastDayTile(
                                day: getDayName(day.date),
                                temp: '${day.maxTemp.toStringAsFixed(0)}°C',
                                iconUrl: day.iconUrl,
                                isSelected: selectedIndex == index,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 🌫 Air Quality Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF883CFF), Color(0xFFB14BDF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AIR QUALITY",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 5),
                          Text(
                            "3 - Low Health Risk",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🌅 Sunrise + UV Index
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white10,
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SUNRISE",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            SizedBox(height: 6),
                            Text("5:28 AM",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text("Sunset: 7:25 PM",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white10,
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("UV INDEX",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            SizedBox(height: 6),
                            Text("4",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            Text("Moderate",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Center(
                    child: Icon(Icons.menu, color: Colors.white, size: 35)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔄 Forecast Day Tile
class ForecastDayTile extends StatelessWidget {
  final String day;
  final String temp;
  final String iconUrl;
  final bool isSelected;

  const ForecastDayTile({
    super.key,
    required this.day,
    required this.temp,
    required this.iconUrl,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.yellowAccent : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            temp,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Image.network(iconUrl, height: 30),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.black87 : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
