import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../util/index.dart';

class CustomPickerModal extends StatefulWidget {
  const CustomPickerModal({
    @required this.initialItem,
    @required this.items,
    @required this.completeButtonEvent,
    @required this.onSelectedItemChanged,
  });

  final int initialItem;
  final List<Widget> items;
  final void Function() completeButtonEvent;
  final void Function(int) onSelectedItemChanged;

  @override
  _CustomPickerModalState createState() => _CustomPickerModalState();
}

class _CustomPickerModalState extends State<CustomPickerModal> {
  FixedExtentScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(
      initialItem: widget.initialItem,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                onPressed: () {
                  widget.completeButtonEvent();
                  Navigator.pop(context);
                },
                child: const Text('完了'),
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
                child: CupertinoPicker(
                  scrollController: scrollController,
                  itemExtent: 40,
                  onSelectedItemChanged: widget.onSelectedItemChanged,
                  children: widget.items,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
