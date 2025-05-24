import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class FrappeAuthService {
  final String baseUrl;
  static const String tokenKey = 'frappe_token';

  FrappeAuthService({required this.baseUrl});

  Future<bool> login(String username, String password) async {
    try {
      // Step 1: Login to Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      final idToken = await userCredential.user?.getIdToken();

      // Step 2: Send Firebase ID token and password to Frappe backend
      final formData = jsonEncode({
        'id_token': idToken,
        'password': password,
      });
      final response = await html.HttpRequest.request(
        'http://localhost:86/api/method/frappe.healthcare_management.doctype.doctor.doctor.get_user_details',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        method: 'POST',
        sendData: formData,
        withCredentials: true,
      );

      if (response.status == 200) {
        debugPrint('Login successful: ${response.responseText}');
        final data = jsonDecode(response.responseText ?? '');
        final sid = data['message']['sid'];

        if (sid != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('sid', sid);
          html.document.cookie = 'sid=$sid; path=/';
          debugPrint('Login successful! SID: $sid');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove('user_data');
      html.document.cookie =
          'sid=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/';
      debugPrint('Logged out successfully');
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
