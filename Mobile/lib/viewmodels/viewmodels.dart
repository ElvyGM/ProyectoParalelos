import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

abstract class BaseViewModel extends ChangeNotifier {
  bool loading = false;
  String? error;
  void begin() {
    loading = true;
    error = null;
    notifyListeners();
  }

  void fail(Object e) {
    error = e.toString();
  }

  void end() {
    loading = false;
    notifyListeners();
  }
}

class AuthViewModel extends BaseViewModel {
  final AuthRepository repo;
  AuthViewModel(this.repo);
  UserModel? user;
  Future<bool> login(String e, String p) async {
    begin();
    try {
      user = await repo.login(e, p);
      return true;
    } catch (x) {
      fail(x);
      return false;
    } finally {
      end();
    }
  }

  Future<bool> register(String n, String a, String e, String p) async {
    begin();
    try {
      user = await repo.register(n, a, e, p);
      return true;
    } catch (x) {
      fail(x);
      return false;
    } finally {
      end();
    }
  }

  Future<void> logout() => repo.logout();
}

class UsersViewModel extends BaseViewModel {
  final UserRepository repo;
  UsersViewModel(this.repo);
  List<UserModel> users = [];
  Future<void> load() async {
    begin();
    try {
      users = await repo.all();
    } catch (e) {
      fail(e);
    } finally {
      end();
    }
  }

  Future<void> save(
      {UserModel? user,
      required String nombre,
      required String apellido,
      required String email,
      required String password}) async {
    begin();
    try {
      final Map<String, dynamic> data = {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password.isEmpty ? null : password,
        'foto': user?.foto
      };
      if (user == null) {
        data['password'] = password;
        await repo.create(data);
      } else {
        await repo.update(user.id, data);
      }
      users = await repo.all();
    } catch (e) {
      fail(e);
      rethrow;
    } finally {
      end();
    }
  }

  Future<void> remove(int id) async {
    begin();
    try {
      await repo.delete(id);
      users.removeWhere((x) => x.id == id);
    } catch (e) {
      fail(e);
    } finally {
      end();
    }
  }
}

class DashboardViewModel extends BaseViewModel {
  final UserRepository usersRepo;
  final FileRepository filesRepo;
  DashboardViewModel(this.usersRepo, this.filesRepo);
  UserModel? profile;
  StatsModel? stats;
  List<UserModel> users = [];
  List<FileModel> files = [];
  List<dynamic> notifications = [];
  Future<void> loadConcurrent() async {
    begin();
    try {
      final r = await Future.wait([
        usersRepo.all(),
        usersRepo.profile(),
        usersRepo.stats(),
        filesRepo.all(),
        usersRepo.notifications()
      ]);
      users = r[0] as List<UserModel>;
      profile = r[1] as UserModel;
      stats = r[2] as StatsModel;
      files = r[3] as List<FileModel>;
      notifications = r[4] as List<dynamic>;
    } catch (e) {
      fail(e);
    } finally {
      end();
    }
  }
}

class UploadViewModel extends BaseViewModel {
  final FileRepository repo;
  UploadViewModel(this.repo);
  List<FileModel> files = [];
  PerformanceResult? result;
  Future<int> uploadSequential(List<String> paths) async {
    final sw = Stopwatch()..start();
    for (final p in paths) {
      files.add(await repo.upload(p));
    }
    sw.stop();
    return sw.elapsedMilliseconds;
  }

  Future<int> uploadConcurrent(List<String> paths) async {
    final sw = Stopwatch()..start();
    files.addAll(await Future.wait(paths.map(repo.upload)));
    sw.stop();
    return sw.elapsedMilliseconds;
  }

  Future<void> compare(List<String> paths) async {
    begin();
    try {
      final sequential = await uploadSequential(paths);
      final concurrent = await uploadConcurrent(paths);
      result = PerformanceResult(paths.length, sequential, concurrent);
    } catch (e) {
      fail(e);
    } finally {
      end();
    }
  }
}

class NotificationViewModel extends BaseViewModel {
  final NotificationRepository repo;
  NotificationViewModel(this.repo);

  Future<bool> send(String email, String subject, String message) async {
    begin();
    try {
      await repo.send(email, subject, message);
      return true;
    } catch (e) {
      fail(e);
      return false;
    } finally {
      end();
    }
  }
}
