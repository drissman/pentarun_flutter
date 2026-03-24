import 'package:flutter/material.dart';
import 'package:pentarun_flutter/app.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_theme.dart';

void main() {
  runApp(const PentarunRoot());
}

class PentarunRoot extends StatefulWidget {
  const PentarunRoot({super.key});

  @override
  State<PentarunRoot> createState() => _PentarunRootState();
}

class _PentarunRootState extends State<PentarunRoot> {
  final _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: MaterialApp(
        title: 'PENTARUN v1.2',
        debugShowCheckedModeBanner: false,
        theme: A2Theme.dark,
        home: const Scaffold(
          body: PentarunApp(),
        ),
      ),
    );
  }
}
