import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';
import 'auth_session_manager.dart';

final authSessionManagerProvider = Provider<AuthSessionManager>((ref) {
  final storage = ref.read(secureStorageProvider);

  return AuthSessionManager(storage);
});
