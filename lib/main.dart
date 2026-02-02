import 'package:flutter/material.dart';
import 'dart:io';
import 'package:voclio_app/voclio_app.dart';
import 'package:voclio_app/core/api/my_http_overrides.dart';
import 'package:voclio_app/core/app/connectivily_control.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/language_controller.dart';
import 'package:voclio_app/core/di/injection_container.dart';

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
