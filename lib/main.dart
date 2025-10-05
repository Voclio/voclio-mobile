import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/styles/theme/app_theme.dart';
import 'package:voclio_app/voclio_app.dart';
import 'core/app/connectivily_control.dart';
import 'core/routes/App_routes.dart';
import 'core/splash/Voclio_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConnectivityControler.instance.init();
  runApp(const VoclioApp());
}



