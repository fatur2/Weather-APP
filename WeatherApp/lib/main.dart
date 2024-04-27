import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uts_mp_fatur/service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca DiLokasi saya'),
      ),
      body: FutureBuilder(
        future: _getLokasiCuaca(), 
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final weatherData = snapshot.data!;
              final lokasiName = weatherData['cityName'];
              final weather = weatherData['weather'];
              IconData iconData;

              switch (weather.toLowerCase()) {
                case 'clear':
                  iconData = Icons.wb_sunny;
                  break;
                case 'clouds':
                  iconData = Icons.cloud;
                  break;
                case 'rain':
                  iconData = Icons.beach_access;
                  break;
                case 'thunderstorm':
                  iconData = Icons.flash_on;
                  break;
                case 'drizzle':
                  iconData = Icons.grain;
                  break;
                case 'snow':
                  iconData = Icons.ac_unit;
                  break;
                case 'mist':
                  iconData = Icons.blur_on;
                  break;
                default:
                  iconData = Icons.error_outline;
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        lokasiName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cuaca: $weather',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        iconData,
                        size: 60,
                        color: Colors.black, 
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getLokasiCuaca() async {
    try {
      if (!(await Permission.location.status.isGranted)) {
        await Permission.location.request();
      }
      if (await Permission.location.serviceStatus.isEnabled) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final weatherService = OpenWeather();
        final weatherData = await weatherService.fetchWeatherDataByCoordinates(
            position.latitude, position.longitude);
        return {'cityName': weatherData['name'], 'temperature': weatherData['main']['temp'], 'weather': weatherData['weather'][0]['main']};
      } else {
        throw Exception('Akses lokasi dibutuhkan, Silahkan izinkan akses');
      }
    } catch (e) {
      return {'cityName': 'Unknown', 'temperature': 'Unknown', 'weather': 'Unknown'};
    }
  }
}
