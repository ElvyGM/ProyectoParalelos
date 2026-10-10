import 'package:flutter_test/flutter_test.dart';import 'package:userflow_mobile/models/models.dart';
void main(){test('calcula mejora porcentual',(){const r=PerformanceResult(4,8000,3000);expect(r.savedMs,5000);expect(r.improvement,62.5);});}
