import 'package:flutter/material.dart';

class TabItem {
  final String id;
  final String title;
  final Widget screen;
  final IconData icon;

  TabItem({required this.id, required this.title, required this.screen, required this.icon});
}
