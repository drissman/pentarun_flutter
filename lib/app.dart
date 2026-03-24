// SPEC-KIT §3.1 — Phase router + auth gate
import 'package:flutter/material.dart';
import 'package:pentarun_flutter/screens/racing_screen.dart';
import 'package:pentarun_flutter/screens/setup_screen.dart';
import 'package:pentarun_flutter/screens/summary_screen.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/widgets/toast_overlay.dart';

class PentarunApp extends StatelessWidget {
  const PentarunApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Stack(
      children: [
        // Phase router
        switch (state.phase) {
          AppPhase.setup => const SetupScreen(),
          AppPhase.racing => const RacingScreen(),
          AppPhase.summary => const SummaryScreen(),
        },
        // Toast overlay
        if (state.toast != null) ToastOverlay(message: state.toast!),
      ],
    );
  }
}
