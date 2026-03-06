import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartfarm/model/motor_model.dart';

/// Shows a live countdown badge when the motor has an active timed run.
/// Returns SizedBox.shrink() when there's no active timer.
class MotorTimerBadge extends StatefulWidget {
  final Motor motor;

  const MotorTimerBadge({super.key, required this.motor});

  @override
  State<MotorTimerBadge> createState() => _MotorTimerBadgeState();
}

class _MotorTimerBadgeState extends State<MotorTimerBadge> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final end = widget.motor.timerEndAt.value;
    if (end == null) {
      if (mounted) setState(() => _remaining = Duration.zero);
      return;
    }
    final diff = end.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  @override
Widget build(BuildContext context) {
  final end = widget.motor.timerEndAt.value;

  if (end == null ||
      !widget.motor.isTimedRunActive ||
      _remaining == Duration.zero) {
    return const SizedBox.shrink();
  }

  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: colorScheme.primary.withOpacity(0.3),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 14,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          _format(_remaining),
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}

}