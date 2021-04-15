import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../utils/index.dart';
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

  static const _descriptionMaxLength = 140;

  static const _descriptionHintText = '(モンスター名、クエスト名、素材名、集会エリア番号、注意点など)\n\n'
      '例) リオレウス討伐を手伝ってくれる方を募集します！\n\n'
      '集会エリア番号: ABCD 1234 EFGH';

  AppEvent get() {
    return AppEvent(
      description: _descriptionController.text,
    );
  }

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialValue?.description ?? '',
    );
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
      ],
    );
  }

  String _descriptionValidator(String description) {
    final errorMessages = <String>[
      Validations.blank(description),
      Validations.maxLength(description, _descriptionMaxLength),
    ];

    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
