import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService api;
  AuthRepository(this.api);
  Future<UserModel> login(String email, String password) async {
    final j =
        await api.post('/auth/login', {'email': email, 'password': password});
    await (await SharedPreferences.getInstance()).setString('jwt', j['token']);
    return UserModel.fromJson(j['user']);
  }

  Future<UserModel> register(String n, String a, String e, String p) async {
    final j = await api.post('/auth/register',
        {'nombre': n, 'apellido': a, 'email': e, 'password': p});
    await (await SharedPreferences.getInstance()).setString('jwt', j['token']);
    return UserModel.fromJson(j['user']);
  }

  Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove('jwt');
}

class UserRepository {
  final ApiService api;
  UserRepository(this.api);
  Future<List<UserModel>> all() async => ((await api.get('/users')) as List)
      .map((x) => UserModel.fromJson(x))
      .toList();
  Future<UserModel> profile() async =>
      UserModel.fromJson(await api.get('/profile'));
  Future<UserModel> create(Map<String, dynamic> data) async =>
      UserModel.fromJson(await api.post('/users', data));
  Future<UserModel> update(int id, Map<String, dynamic> data) async =>
      UserModel.fromJson(await api.put('/users/$id', data));
  Future<void> delete(int id) => api.delete('/users/$id');
  Future<StatsModel> stats() async =>
      StatsModel.fromJson(await api.get('/stats'));
  Future<List<dynamic>> notifications() async =>
      (await api.get('/notifications')) as List;
}

class FileRepository {
  final ApiService api;
  FileRepository(this.api);
  Future<List<FileModel>> all() async => ((await api.get('/files')) as List)
      .map((x) => FileModel.fromJson(x))
      .toList();
  Future<FileModel> upload(String path) async =>
      FileModel.fromJson(await api.upload('/upload', path));
  Future<void> delete(int id) => api.delete('/upload/$id');
}

class NotificationRepository {
  final ApiService api;
  NotificationRepository(this.api);

  Future<void> send(String email, String subject, String message) async {
    await api.post('/notifications/send',
        {'email': email, 'subject': subject, 'message': message});
  }
}
