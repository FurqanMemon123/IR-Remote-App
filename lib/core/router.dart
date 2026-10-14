import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/add_remote/device_type_screen.dart';
import '../features/add_remote/brand_screen.dart';
import '../features/add_remote/test_code_screen.dart';
import '../features/add_remote/save_remote_screen.dart';
import '../features/remote/remote_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/add/type', builder: (_, _) => const DeviceTypeScreen()),
    GoRoute(path: '/add/brand', builder: (_, _) => const BrandScreen()),
    GoRoute(path: '/add/test', builder: (_, _) => const TestCodeScreen()),
    GoRoute(path: '/add/save', builder: (_, _) => const SaveRemoteScreen()),
    GoRoute(
      path: '/remote/:id',
      builder: (_, state) => RemoteScreen(remoteId: state.pathParameters['id']!),
    ),
  ],
);
