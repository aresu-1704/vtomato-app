import 'package:get_it/get_it.dart';
import 'package:vtomato_app/services/predict_service.dart';
import 'package:vtomato_app/services/disease_history_service.dart';
import 'package:vtomato_app/services/auth_service.dart';

final getIt = GetIt.instance;

/// Setup service locator for dependency injection
void setupServiceLocator() {
  // Register services as lazy singletons
  getIt.registerLazySingleton<PredictService>(() => PredictService());
  getIt.registerLazySingleton<DiseaseHistoryService>(
    () => DiseaseHistoryService(),
  );
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
