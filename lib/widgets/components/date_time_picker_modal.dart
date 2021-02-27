import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/index.dart';

class DateTimePickerModal extends StatelessWidget {
  const DateTimePickerModal({
    @required this.mode,
    @required this.initialDateTime,
    @required this.completeButtonEvent,
    @required this.onDateTimeChanged,
  });

  final CupertinoDatePickerMode mode;
  final DateTime initialDateTime;
  final void Function() completeButtonEvent;
  final void Function(DateTime) onDateTimeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: const BoxDecoration(color: AppColors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: const Text('キャンセル'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: const Text('完了'),
                onPressed: () {
                  completeButtonEvent();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6),
          color: AppColors.white,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.headline6,
            child: GestureDetector(
              onTap: () {},
              child: SafeArea(
                top: false,
                child: CupertinoDatePicker(
                  mode: mode,
                  use24hFormat: true,
                  initialDateTime: initialDateTime,
                  onDateTimeChanged: onDateTimeChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
