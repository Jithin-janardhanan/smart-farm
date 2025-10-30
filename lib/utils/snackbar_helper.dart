import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showThemedSnackbar(
  String title,
  String message, {
  bool isError = false,
  bool isSuccess = false,
}) {
  final theme = Get.theme.colorScheme;

  final background = isError
      ? theme.errorContainer
      : isSuccess
      ? theme.primaryContainer
      : theme.surface;

  final textColor = isError
      ? theme.onErrorContainer
      : isSuccess
      ? theme.onPrimaryContainer
      : theme.onSurface;

  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: background,
    colorText: textColor,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
    animationDuration: const Duration(milliseconds: 300),
    icon: Icon(
      isError
          ? Icons.error_outline
          : isSuccess
          ? Icons.check_circle_outline
          : Icons.info_outline,
      color: textColor,
    ),
  );
}
