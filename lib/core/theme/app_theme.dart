import 'package:flutter/material.dart';

const Color baseGreen = Color(0xFF29E33C);
const Color primaryBackground = Color(0xFF151718); 
const Color widgetsColor = Color(0xFF282A2C);
const Color scaffoldBackground = Colors.black;
const Color cardBackground = Color(0xFF161616);
const Color cardBackgroundAlt = Color(0xFF1A1A1A);
const Color textPrimary = Colors.white;
const Color textSecondary = Colors.white70;
const Color textTertiary = Colors.white54;
const Color borderColor = Colors.white70;
const Color errorColor = Colors.red;
const Color successColor = Color.fromRGBO(128, 249, 136, 1);

final ThemeData darkTheme = ThemeData(
  // Configurações básicas escuras
  brightness: Brightness.dark,
  scaffoldBackgroundColor: primaryBackground,
  
  // Tema da AppBar para o fundo correto
  appBarTheme: const AppBarTheme(
    backgroundColor: widgetsColor,
    elevation: 0,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),

  // Cor de destaque
  primaryColor: baseGreen,
  colorScheme: const ColorScheme.dark(
    primary: baseGreen,
    secondary: baseGreen,
    surface: widgetsColor, 
  ),
  
  // Estilo de botões
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: baseGreen,
      foregroundColor: primaryBackground, 
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
    ),
  ),
  
  // Estilo de texto padrão (opcional)
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
);