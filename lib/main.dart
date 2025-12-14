import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';
import 'repositories/local_user_repository.dart';
import 'repositories/todo_repository.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/profile.dart';
import 'screens/register.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/connectivity_service.dart';
import 'services/mqtt_service.dart';
import 'services/todo_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final userRepo = LocalUserRepository();
  final authService = AuthService(repository: userRepo);

  // Один екземпляр ConnectivityService на весь app
  final connectivity = ConnectivityService();

  // API
  final apiClient = ApiClient(baseUrl: 'https://jsonplaceholder.typicode.com/');
  final todoApi = TodoApiService(apiClient);

  // Repo (API -> cache -> UI)
  final todoRepo = TodoRepository(
    apiService: todoApi,
    connectivity: connectivity,
  );

  runApp(AppLoader(
    authService: authService,
    todoRepo: todoRepo,
    connectivity: connectivity,
  ));
}

class AppLoader extends StatelessWidget {
  final AuthService authService;
  final TodoRepository todoRepo;
  final ConnectivityService connectivity;

  const AppLoader({
    required this.authService,
    required this.todoRepo,
    required this.connectivity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: authService.checkSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final initialRoute = snapshot.data != null ? '/home' : '/login';
        final initialUser = snapshot.data;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MqttService()),
            ChangeNotifierProvider.value(value: connectivity),
          ],
          child: MyApp(
            authService: authService,
            todoRepo: todoRepo,
            initialRoute: initialRoute,
            initialUser: initialUser,
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final TodoRepository todoRepo;
  final String initialRoute;
  final User? initialUser;

  const MyApp({
    required this.authService,
    required this.todoRepo,
    required this.initialRoute,
    this.initialUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ToDo Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      locale: const Locale('en', 'US'),
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => LoginPage(authService: authService),
        '/register': (_) => RegisterPage(authService: authService),
        '/home': (_) => HomePage(
              authService: authService,
              todoRepo: todoRepo,
              autoLoggedInUser: initialUser,
            ),
        '/profile': (_) => ProfilePage(authService: authService),
      },
    );
  }
}
