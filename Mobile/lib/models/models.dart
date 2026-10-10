class UserModel {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? foto;
  final DateTime createdAt;
  const UserModel(
      {required this.id,
      required this.nombre,
      required this.apellido,
      required this.email,
      this.foto,
      required this.createdAt});
  String get fullName => '$nombre $apellido';
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
      id: j['id'],
      nombre: j['nombre'],
      apellido: j['apellido'],
      email: j['email'],
      foto: j['foto'],
      createdAt: DateTime.parse(j['createdAt']));
}

class FileModel {
  final int id;
  final String filename;
  final String originalName;
  final String url;
  final int size;
  const FileModel(
      {required this.id,
      required this.filename,
      required this.originalName,
      required this.url,
      required this.size});
  factory FileModel.fromJson(Map<String, dynamic> j) => FileModel(
      id: j['id'],
      filename: j['filename'],
      originalName: j['originalName'],
      url: j['url'],
      size: j['size']);
}

class StatsModel {
  final int users, files, myFiles;
  const StatsModel(
      {required this.users, required this.files, required this.myFiles});
  factory StatsModel.fromJson(Map<String, dynamic> j) =>
      StatsModel(users: j['users'], files: j['files'], myFiles: j['myFiles']);
}

class PerformanceResult {
  final int files, sequentialMs, concurrentMs;
  const PerformanceResult(this.files, this.sequentialMs, this.concurrentMs);
  int get savedMs => sequentialMs - concurrentMs;
  double get improvement =>
      sequentialMs == 0 ? 0 : (savedMs / sequentialMs * 100);
}
