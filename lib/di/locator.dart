import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../core/services/navigation_service.dart';
import '../env/flavor_config.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  _registerServices();
  _registerUseCases();
  _registerRepositories();
  _registerProviders();
}

void _registerServices() {
  getIt.registerSingleton(NavigationService());
  getIt.registerLazySingleton(
    () => ApiClient(baseUrl: FlavorConfig.instance.values.baseUrl),
  );
}

void _registerUseCases() {}

void _registerRepositories() {}

void _registerProviders() {}
