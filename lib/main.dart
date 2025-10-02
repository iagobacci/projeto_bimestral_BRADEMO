import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/splash_screen/presentation/controller/splash_controller.dart';
import 'features/splash_screen/presentation/pages/splash_screen.dart';

import 'features/form_screen/presentation/controller/form_controller.dart';
import 'features/form_screen/presentation/pages/form_screen.dart';

import 'features/home/presentation/controller/home_controller.dart';
import 'features/home/presentation/pages/home_screen.dart';

import 'features/activity/presentation/controller/activity_controller.dart';
import 'features/activity/presentation/pages/activity_screen.dart';

import 'features/pulse_measurement/presentation/controller/pulse_controller.dart';
import 'features/pulse_measurement/presentation/pages/pulse_screen.dart';


void main() {
  runApp(const MyApp());
}

// Widget principal do app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthPulse',             
      initialRoute: '/splash',
      // Rotas do app
      routes: {

        '/splash': (context) => Provider<SplashController>(
              create: (_) => SplashController(),
              child: const SplashScreen(),
            ),
            
        '/home': (context) => ChangeNotifierProvider(
              create: (_) => HomeController(),
              child: const Home(),
            ),

        '/form': (context) => ChangeNotifierProvider(
              create: (_) => FormController(),
              child: const FormScreen(),
            ),
            
        '/pulse': (context) => ChangeNotifierProvider(
              create: (_) => PulseController(),
              child: const PulseScreen(),
            ),
            
        '/activity': (context) => ChangeNotifierProvider(
              create: (_) => ActivityController(),
              child: const ActivityScreen(),
            ),
      },
    );
  }
}