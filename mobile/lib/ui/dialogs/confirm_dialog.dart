import 'package:flutter/material.dart';
import 'package:tech_pulse/ui/routes/dialog.dart';

class ConfirmDialog extends StatelessWidget {
  final Widget title;
  final String confirmText;
  final String cancelText;
  final Widget? content;
  final Widget? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      icon: icon,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

Future<bool> showConfirmDialog({
  required BuildContext context,
  required Widget title,
  Widget? content,
  Widget? icon,
  String confirmText = '确认',
  String cancelText = '取消',
}) async {
  final result = await showMyDialog<bool>(
    context: context,
    child: ConfirmDialog(
      title: title,
      content: content,
      icon: icon,
      confirmText: confirmText,
      cancelText: cancelText,
    ),
  );
  return result ?? false;
}
