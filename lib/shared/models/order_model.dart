import 'package:flutter/material.dart';

class OrderModel {
  final String title;
  final String client;
  final String status;
  final String date;
  final IconData icon;

  OrderModel({
    required this.title,
    required this.client,
    required this.status,
    required this.date,
    required this.icon,
  });
}
