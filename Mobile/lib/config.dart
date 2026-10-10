class AppConfig {
  // API desplegada en GCP. Puede reemplazarse al ejecutar con --dart-define.
  static const apiUrl = String.fromEnvironment('API_URL',
      defaultValue: 'https://userflow-gateway-dy9hl9mi.uc.gateway.dev/api');
}
