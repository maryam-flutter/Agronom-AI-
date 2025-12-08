class WeatherModel {
  final String city;
  final String region;
  final String localtime;
  final double currentTemp;
  final double tempF;
  final String description; // Bu maydon qo'shildi
  final String iconUrl; // Ob-havo ikonkasini saqlash uchun
  final double feelsLike; // Seziladigan harorat
  final int isDay;
  final int humidity;
  final double windKph;
  final double windMph;
  final String windDir; // Shamol yo'nalishi
  final double pressureMb;
  final double uv;
  final double visKm;
  final List<WeeklyForecast> weeklyForecast;

  WeatherModel({
    required this.city,
    this.region = '',
    this.localtime = '',
    required this.currentTemp,
    this.tempF = 0.0,
    this.description = '',
    this.iconUrl = '',
    this.feelsLike = 0.0,
    // Yangi maydonlar uchun standart qiymatlar
    this.isDay = 1,
    this.humidity = 0,
    this.windKph = 0.0,
    this.windMph = 0.0,
    this.windDir = '',
    this.pressureMb = 0.0,
    this.uv = 0.0,
    this.visKm = 0.0,
    required this.weeklyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Haftalik prognozni olish
    var forecastList = <WeeklyForecast>[];
    if (json['weekly_forecast'] != null) {
      forecastList = (json['weekly_forecast'] as List)
          .map((item) => WeeklyForecast.fromJson(item))
          .toList();
    }

    // Ob-havo tavsifini olish
    String weatherDescription = 'Noma\'lum';
    if (json['weather'] != null && (json['weather'] as List).isNotEmpty) {
      weatherDescription = json['weather'][0]['description'] ?? 'Noma\'lum';
    }

    return WeatherModel(
      city: json['city'] ?? 'Noma\'lum shahar',
      region: '', // Bu fromJson hozircha ishlatilmayapti
      localtime: '', // Bu fromJson hozircha ishlatilmayapti
      currentTemp: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      tempF: 0.0, // Bu fromJson hozircha ishlatilmayapti
      feelsLike: (json['main']?['feels_like'] as num?)?.toDouble() ?? 0.0,
      description: weatherDescription,
      iconUrl: '', // Bu fromJson hozircha ishlatilmayapti
      // Bu yerda fromJson'dan foydalanilmayapti, lekin kelajak uchun qo'shib qo'yish mumkin
      isDay: 1,
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      windKph: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      windMph: 0.0,
      windDir: json['wind']?['deg']?.toString() ?? '', // fromJson uchun misol
      pressureMb: (json['main']?['pressure'] as num?)?.toDouble() ?? 0.0,
      uv: 0.0,
      visKm: 0.0,
      weeklyForecast: forecastList,
    );
  }
}

class WeeklyForecast {
  final String day;
  final double temp;

  WeeklyForecast({required this.day, required this.temp});

  factory WeeklyForecast.fromJson(Map<String, dynamic> json) {
    return WeeklyForecast(
      day: json['day'] ?? 'Noma\'lum kun',
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
    );
  }
}