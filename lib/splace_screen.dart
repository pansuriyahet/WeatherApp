import 'package:flutter/material.dart';
import 'today_weather_screen.dart'; // Make sure this file exists and has a screen

void main() {
  runApp(const SplashScreen());
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WeatherSplashScreen(),
    );
  }
}

class WeatherSplashScreen extends StatelessWidget {
  const WeatherSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8C3EFF),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8C3EFF), Color(0xFFCF63C1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Weather Image
            Image.asset(
              'assets/image/w1.png',
              height: 150,
            ),

            const SizedBox(height: 40),

            // Weather Text
            const Text(
              'Weather',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Forecasts Text
            const Text(
              'ForeCasts',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFC107), // Yellow color
              ),
            ),

            const SizedBox(height: 40),

            // Get Start Button
            ElevatedButton(
              onPressed: () {
                // ✅ Navigate to TodayWeatherScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TodayWeatherScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Get Start',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
