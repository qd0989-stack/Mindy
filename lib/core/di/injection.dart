import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/services.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // External dependencies
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Services
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(prefs: getIt()),
  );

  getIt.registerLazySingleton<CrisisDetectionService>(
    () => CrisisDetectionService(),
  );

  getIt.registerLazySingleton<PersonalizationEngine>(
    () => PersonalizationEngine(getIt<StorageService>()),
  );

  getIt.registerFactory<DemoVoicePipelineService>(
    () => DemoVoicePipelineService(
      crisisDetection: getIt<CrisisDetectionService>(),
    ),
  );
}
