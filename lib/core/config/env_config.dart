import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied(path: '.env')
abstract class EnvConfig {
  @EnviedField(varName: 'API_BASE_URL', defaultValue: 'https://fibo.io.vn')
  static String apiBaseUrl = _EnvConfig.apiBaseUrl;
}
