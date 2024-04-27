import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uts_mp_fatur/constants.dart';

class OpenWeather {
  Future<Map<String, dynamic>> fetchWeatherDataByCoordinates(double latitude, double longitude) async {
    final url =
        '${Constants.apiUrl}/weather?lat=$latitude&lon=$longitude&appid=${Constants.apiKey}&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }
}
