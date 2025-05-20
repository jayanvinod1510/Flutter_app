import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import 'frappe_auth_service.dart';

class AppointmentService {
  final String baseUrl;
  final FrappeAuthService authService;

  AppointmentService({
    required this.baseUrl,
    required this.authService,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Cookie': token,
    };
  }

  Future<List<Appointment>> getAppointments() async {
    List<Appointment> appointments = [];
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/resource/Medical Appointment?fields=["*"]'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Appointments:" + data.toString());
        appointments = (data['data'] as List)
            .map((json) => Appointment.fromJson(json))
            .toList();
      }
      return appointments;
    } catch (e) {
      throw Exception('Failed to load appointments456: $e');
    }
  }

  Future<Appointment> addAppointment(Appointment appointment) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/resource/Medical Appointment'),
        headers: headers,
        body: jsonEncode(appointment.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Appointment.fromJson(data['data']);
      }
      throw Exception('Failed to create appointment');
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<Appointment> updateAppointment(Appointment appointment) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(
            '$baseUrl/api/resource/Medical Appointment/${appointment.name}'),
        headers: headers,
        body: jsonEncode(appointment.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Appointment.fromJson(data['data']);
      }
      throw Exception('Failed to update appointment');
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<void> deleteAppointment(String name) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/resource/Medical Appointment/$name'),
        headers: headers,
      );

      if (response.statusCode != 202) {
        throw Exception('Failed to delete appointment');
      }
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  Future<List<Map<String, String>>> getDoctors() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/resource/Doctor?fileds=["name","doctor_name"]'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => {
                  'id': json['name'].toString(),
                  'name': (json['doctor_name'] ?? json['name']).toString(),
                })
            .toList();
      }
      throw Exception('Failed to load doctors');
    } catch (e) {
      throw Exception('Failed to load doctors: $e');
    }
  }
}
