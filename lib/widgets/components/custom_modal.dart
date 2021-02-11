import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showErrorModal(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

Future<bool> showConfirmModal(
  BuildContext context,
  String message, {
  String okButtonText = 'OK',
  bool isDestructiveAction = false,
}) async {
  var isConfirmed = false;
  await showDialog<void>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('確認'),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('キャンセル'),
            onPressed: () {
              isConfirmed = false;
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text(okButtonText),
            isDestructiveAction: isDestructiveAction,
            onPressed: () {
              isConfirmed = true;
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
  return isConfirmed;
}
