import 'package:flutter/material.dart';
import 'dart:io';
import 'package:voclio_app/voclio_app.dart';
import 'core/api/my_http_overrides.dart';
import 'core/app/connectivily_control.dart';
import 'core/app/theme_controller.dart';
import 'core/app/language_controller.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await setupDependencies();
  
  // Bypass SSL verification for development
  HttpOverrides.global = MyHttpOverrides();
  
  // Initialize controllers
  await ConnectivityControler.instance.init();
  await ThemeController.instance.init();
  await LanguageController.instance.init();
  
  runApp(const VoclioApp());
}



