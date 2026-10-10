class AppConfig {
  // Emulador Android: 10.0.2.2. Dispositivo real: use la IP de su PC.
  static const apiUrl = String.fromEnvironment('API_URL',
      defaultValue: 'http://10.0.2.2:8080/api');
}
