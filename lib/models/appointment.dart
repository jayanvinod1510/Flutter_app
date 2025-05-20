import 'package:flutter/material.dart';

class Appointment {
  final String? name;
  final String doctor;
  final String? doctor_name;
  final String patient_id;
  final DateTime date;
  final TimeOfDay time;
  final String reason;
  static const String doctype = "Medical Appointment";

  Appointment({
    this.name,
    this.doctor_name,
    required this.doctor,
    required this.patient_id,
    required this.date,
    required this.time,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'doctor': doctor,
      'doctor_name': doctor_name,
      'patient_id': patient_id,
      'date': date.toIso8601String().split('T')[0],
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      'reason': reason,
      'doctype': doctype,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    List<String> timeParts = json['time'].split(':');
    final parsedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return Appointment(
      name: json['name'],
      doctor: json['doctor'],
      doctor_name: json['doctor_name'],
      patient_id: json['patient_id'],
      date: DateTime.parse(json['date']),
      time: parsedTime,
      reason: json['reason'],
    );
  }
}
