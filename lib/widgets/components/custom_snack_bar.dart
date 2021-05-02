import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../util/index.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.grey10,
      behavior: SnackBarBehavior.floating,
      content: AutoSizeText(
        message,
        style: const TextStyle(color: AppColors.white),
        maxLines: 1,
      ),
      action: SnackBarAction(
        label: 'とじる',
        textColor: AppColors.white,
        onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar(),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
