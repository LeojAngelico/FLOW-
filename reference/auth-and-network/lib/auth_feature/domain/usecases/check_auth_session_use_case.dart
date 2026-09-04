import '../../data/datasources/auth_local_data_source.dart';

class CheckAuthSessionUseCase {
  final AuthLocalDataSource localDataSource;

  const CheckAuthSessionUseCase(this.localDataSource);

  Future<bool> execute() async {
    final token = await localDataSource.getAccessToken();

    return token != null && token.isNotEmpty;
  }
}
