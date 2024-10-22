import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:netvibe/core/state-models/net_speed.dart';
import 'package:netvibe/core/state-models/show_speed.dart';
import 'package:netvibe/pages/main_page.dart';
import 'package:netvibe/services/network_speed.dart';
import 'package:provider/provider.dart';

void setupDependencies() {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<NetworkSevices>(NetworkSevices());
  getIt.registerSingleton<NetSpeedProvider>(NetSpeedProvider());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShowSpeed()),
        ChangeNotifierProvider(create: (_) => NetSpeedProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NetVibe',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.cyan,
          ).copyWith(
            secondary: Colors.deepPurple,
          ), 
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        home: const MainPage(),
      ),
    );
  }
}
