import 'package:flutter/material.dart';
import 'package:voclio_app/core/api/api_endpoints.dart';

void main() {
  print('======================');
  print('API Configuration Test');
  print('======================');
  print('Base URL: ${ApiEndpoints.baseUrl}');
  print('Login endpoint: ${ApiEndpoints.login}');
  print('Full URL: ${ApiEndpoints.baseUrl}${ApiEndpoints.login}');
  print('======================');
}
