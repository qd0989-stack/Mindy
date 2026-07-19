import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/app_bloc.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependencies
  await initializeDependencies();

  // Initialize storage service
  final storage = getIt<StorageService>();

  runApp(MindyApp(storage: storage));
}

/// Main application widget for Mindy
class MindyApp extends StatelessWidget {
  final StorageService storage;

  const MindyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(storage)..add(const AppInitialize()),
      child: MaterialApp.router(
        title: 'Mindy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
