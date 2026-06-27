import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velo_core/velo_core.dart';

final apiProvider = Provider((ref) => ApiClient());

final authRepoProvider = Provider((ref) => AuthRepository(ref.watch(apiProvider)));

final authStateProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.watch(authRepoProvider).me();
});
