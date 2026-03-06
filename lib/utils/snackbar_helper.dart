import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showThemedSnackbar(
  String title,
  String message, {
  bool isError = false,
  bool isSuccess = false,
  bool isWarning = false, // 👈 NEW
}) {
  final context = Get.context;
  if (context == null) return;

  final theme = Theme.of(context).colorScheme;

  final background = isError
      ? theme.errorContainer
      : isWarning
      ? Colors.amber.shade600
      : isSuccess
      ? theme.primaryContainer
      : theme.surface;

  final textColor = isError
      ? theme.onErrorContainer
      : isWarning
      ? Colors
            .black // 👈 better contrast on yellow
      : isSuccess
      ? theme.onPrimaryContainer
      : theme.onSurface;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: background,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline
                : isWarning
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: textColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text("$title\n$message", style: TextStyle(color: textColor)),
          ),
        ],
      ),
    ),
  );
}
