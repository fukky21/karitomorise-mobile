import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../utils/index.dart';
import 'custom_divider.dart';
import 'custom_picker_modal.dart';
import 'custom_text_form_field.dart';

class EditEventForm extends StatefulWidget {
  const EditEventForm({
    @required Key key,
    @required this.initialValue,
  }) : super(key: key);

  final AppEvent initialValue;

  @override
  EditEventFormState createState() => EditEventFormState();
}

class EditEventFormState extends State<EditEventForm> {
  TextEditingController _descriptionController;
  EventType _type;
  EventQuestRank _questRank;
  EventTargetLevel _targetLevel;
  EventPlayTime _playTime;

  static const _descriptionMaxLength = 140;

  static const _descriptionHintText = '(モンスター名、クエスト名、素材名、集会エリア番号、注意点など)\n\n'
      '例) リオレウス討伐を手伝ってくれる方を募集します！\n\n'
      '集会エリア番号: ABCD 1234 EFGH';

  AppEvent get() {
    return AppEvent(
      description: _descriptionController.text,
      type: _type,
      questRank: _questRank,
      targetLevel: _targetLevel,
      playTime: _playTime,
    );
  }

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialValue?.description ?? '',
    );
    _type = widget.initialValue?.type;
    _questRank = widget.initialValue?.questRank;
    _targetLevel =
        widget.initialValue?.targetLevel ?? EventTargetLevel.values[0];
    _playTime = widget.initialValue?.playTime;
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              CustomTextFormField(
                labelText: '募集内容',
                hintText: _descriptionHintText,
                controller: _descriptionController,
                maxLength: _descriptionMaxLength,
                maxLines: 10,
                validator: _descriptionValidator,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        CustomDivider(),
        _selectEventTypeCell(),
        CustomDivider(),
        _selectEventQuestRankCell(),
        CustomDivider(),
        _selectEventTargetLevelCell(),
        CustomDivider(),
        _selectPlayTimeCell(),
        CustomDivider(),
      ],
    );
  }

  Widget _selectEventTypeCell() {
    EventType _currentValue;

    final _items = <Widget>[]..add(const Text('設定しない'));
    for (final type in EventType.values) {
      _items.add(Text(type.name));
    }

    return _selectCell(
      title: '募集タイプ',
      label: _type?.name ?? '設定しない',
      onTap: () {
        _currentValue = _type;
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) {
            return CustomPickerModal(
              initialItem: _currentValue?.id ?? 0,
              items: _items,
              completeButtonEvent: () {
                setState(() {
                  _type = _currentValue;
                });
              },
              onSelectedItemChanged: (value) {
                _currentValue = getEventType(id: value);
              },
            );
          },
        );
      },
    );
  }

  Widget _selectEventQuestRankCell() {
    EventQuestRank _currentValue;

    final _items = <Widget>[]..add(const Text('設定しない'));
    for (final questRank in EventQuestRank.values) {
      _items.add(Text(questRank.name));
    }

    return _selectCell(
      title: 'クエスト難度',
      label: _questRank?.name ?? '設定しない',
      onTap: () {
        _currentValue = _questRank;
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) {
            return CustomPickerModal(
              initialItem: _currentValue?.id ?? 0,
              items: _items,
              completeButtonEvent: () {
                setState(() {
                  _questRank = _currentValue;
                });
              },
              onSelectedItemChanged: (value) {
                _currentValue = getEventQuestRank(id: value);
              },
            );
          },
        );
      },
    );
  }

  Widget _selectEventTargetLevelCell() {
    EventTargetLevel _currentValue;

    final _items = <Widget>[];
    for (final targetLevel in EventTargetLevel.values) {
      _items.add(Text(targetLevel.name));
    }

    return _selectCell(
      title: '募集レベル',
      label: _targetLevel.name,
      onTap: () {
        _currentValue = _targetLevel ?? EventTargetLevel.values[0];
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) {
            return CustomPickerModal(
              initialItem: _currentValue.id - 1,
              items: _items,
              completeButtonEvent: () {
                setState(() {
                  _targetLevel = _currentValue;
                });
              },
              onSelectedItemChanged: (value) {
                _currentValue = getEventTargetLevel(id: value + 1);
              },
            );
          },
        );
      },
    );
  }

  Widget _selectPlayTimeCell() {
    EventPlayTime _currentValue;

    final _items = <Widget>[]..add(const Text('設定しない'));
    for (final playTime in EventPlayTime.values) {
      _items.add(Text(playTime.name));
    }

    return _selectCell(
      title: '予定プレイ時間',
      label: _playTime?.name ?? '設定しない',
      onTap: () {
        _currentValue = _playTime;
        showCupertinoModalPopup<void>(
          context: context,
          builder: (context) {
            return CustomPickerModal(
              initialItem: _currentValue?.id ?? 0,
              items: _items,
              completeButtonEvent: () {
                setState(() {
                  _playTime = _currentValue;
                });
              },
              onSelectedItemChanged: (value) {
                _currentValue = getEventPlayTime(id: value);
              },
            );
          },
        );
      },
    );
  }

  Widget _selectCell({
    String title,
    String label,
    void Function() onTap,
  }) {
    return Material(
      color: AppColors.grey20,
      child: InkWell(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                margin: const EdgeInsets.only(right: 15),
                child: Text(title),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: AutoSizeText(
                          label ?? '',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.chevron_right_sharp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  String _descriptionValidator(String description) {
    final errorMessages = <String>[]
      ..add(Validations.blank(description))
      ..add(Validations.maxLength(description, _descriptionMaxLength));

    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
