import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'repositories/auth_repository.dart';
import 'router/app_router.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/course_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw StateError(
      'SUPABASE_URL e SUPABASE_ANON_KEY precisam estar definidos no arquivo .env',
    );
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await AuthRepository().init();
  final authViewModel = AuthViewModel();
  await authViewModel.checkLoginStatus();
  runApp(CatApp(authViewModel: authViewModel));
}

class CatApp extends StatelessWidget {
  final AuthViewModel authViewModel;

  const CatApp({required this.authViewModel, super.key});

  @override
  Widget build(BuildContext context) {
    String initialLocation;
    if (authViewModel.isLoggedIn) {
      initialLocation = authViewModel.isAdmin ? '/admin-home' : '/home';
    } else {
      initialLocation = '/login';
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProxyProvider<AuthViewModel, CourseViewModel>(
          create: (_) => CourseViewModel(),
          update: (_, auth, course) => course!..updateAuth(auth.currentUser?.ra),
        ),
      ],
      child: MaterialApp.router(
        title: 'CAT Cursos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF1976D2),
            onPrimary: Colors.white,
            secondary: Colors.white,
            onSecondary: Color(0xFF1976D2),
            error: Colors.red,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.createRouter(initialLocation, authViewModel),
      ),
    );
  }
}
