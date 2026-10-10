import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/repositories.dart';
import 'services/api_service.dart';
import 'viewmodels/viewmodels.dart';
import 'views/login_screen.dart';

void main() {
  final api = ApiService();
  final users = UserRepository(api);
  final files = FileRepository(api);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel(AuthRepository(api))),
    ChangeNotifierProvider(create: (_) => UsersViewModel(users)),
    ChangeNotifierProvider(create: (_) => DashboardViewModel(users, files)),
    ChangeNotifierProvider(create: (_) => UploadViewModel(files)),
  ], child: const UserFlowApp()));
}

class UserFlowApp extends StatelessWidget {
  const UserFlowApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UserFlow - Elvy Grullón',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true),
      home: const LoginScreen());
}
