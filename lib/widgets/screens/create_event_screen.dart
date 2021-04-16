import 'package:big_tip/big_tip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/create_event_screen_bloc/index.dart';
import '../../models/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';

class CreateEventScreen extends StatefulWidget {
  static const route = '/create_event';

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const _appBarTitle = '募集を作成';
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController;
  TextEditingController _descriptionController;

  static const _descriptionMaxLength = 140;
  static const _descriptionHintText = 'モンスター名, ロビー識別番号など';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEventScreenBloc>(
      create: (context) => CreateEventScreenBloc(context: context),
      child: BlocBuilder<CreateEventScreenBloc, CreateEventScreenState>(
        builder: (context, state) {
          if (state is CreateEventFailure) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: BigTip(
                  title: Text('エラーが発生しました'),
                  child: Icon(Icons.error_outline_sharp),
                ),
              ),
            );
          }
          if (state is CreateEventSuccess) {
            return Scaffold(
              appBar: simpleAppBar(context, title: _appBarTitle),
              body: const Center(
                child: Text('募集を作成しました'),
              ),
            );
          }
          return ModalProgressHUD(
            inAsyncCall: state is CreateEventInProgress,
            child: Scaffold(
              appBar: simpleAppBar(
                context,
                title: _appBarTitle,
                actions: [_createEventButton(context, state)],
              ),
              body: Form(
                key: _formKey,
                child: ScrollableLayoutBuilder(
                  controller: _scrollController,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 15,
                      right: 15,
                      bottom: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _descriptionController,
                          autofocus: true,
                          maxLength: _descriptionMaxLength,
                          maxLines: 13,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration: const InputDecoration(
                            hintText: _descriptionHintText,
                            border: OutlineInputBorder(),
                          ),
                          validator: _descriptionValidator,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '記入すると良いかも？',
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 5),
                        const BulletTexts(
                          texts: [
                            '募集するプレイヤーのレベル',
                            'プレイ予定時間',
                            '装備・アイテム',
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          '禁止事項',
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 5),
                        const BulletTexts(
                          texts: [
                            '他人に不快な思いをさせる書き込み',
                            '意図的な連投行為',
                            '他サイトやアプリの宣伝',
                            '金銭に関係する書き込み',
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _createEventButton(
      BuildContext context, CreateEventScreenState state) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 5),
        onPressed: () {
          FocusScope.of(context).unfocus();
          if (_formKey.currentState.validate()) {
            final event = AppEvent(
              description: _descriptionController.text,
            );
            context
                .read<CreateEventScreenBloc>()
                .add(CreateEventOnPressed(event: event));
          } else {
            _scrollController.animateTo(
              0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          }
        },
        child: Text(
          '投稿',
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                color: state is CreateEventInProgress
                    ? AppColors.grey60
                    : Theme.of(context).primaryColor,
              ),
        ),
      ),
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
