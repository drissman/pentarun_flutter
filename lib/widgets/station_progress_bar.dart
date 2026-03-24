import 'package:flutter/material.dart';
import 'package:pentarun_flutter/theme/a2ui_colors.dart';

class StationProgressBar extends StatelessWidget {
  final int currentStation;
  const StationProgressBar({super.key, required this.currentStation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: currentStation > i ? A2Colors.vert : Colors.transparent,
                border: i < 4
                    ? const Border(
                        right: BorderSide(color: Color(0xFF050505), width: 1),
                      )
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
