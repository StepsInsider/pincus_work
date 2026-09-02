import 'package:flutter/material.dart';
import 'pincus_workspace.dart';

void main() {
  runApp(const PincusApp());
}

class PincusApp extends StatelessWidget {
  const PincusApp({super.key});
  @override
  Widget build(BuildContext context) => const PincusWorkspace();
}
