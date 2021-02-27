import 'package:big_tip/big_tip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/edit_user_screen_bloc/index.dart';
import '../../models/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';

class EditUserScreen extends StatelessWidget {
  static const route = '/edit_user';

  final _formKey = GlobalKey<FormState>();
  final _editUserFormStateKey = GlobalKey<EditUserFormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditUserScreenBloc>(
      create: (context) {
        return EditUserScreenBloc(context: context)..add(Initialized());
      },
      child: BlocBuilder<EditUserScreenBloc, EditUserScreenState>(
        builder: (context, state) {
          if (state is InitializeInProgress) {
            return Scaffold(
              appBar: simpleAppBar(context),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is InitializeFailure || state is UpdateUserFailure) {
            return Scaffold(
              appBar: simpleAppBar(context),
              body: const Center(
                child: BigTip(
                  title: Text('エラーが発生しました'),
                  child: Icon(Icons.error_outline_sharp),
                ),
              ),
            );
          }
          if (state is UpdateUserSuccess) {
            return Scaffold(
              appBar: transparentAppBar(context),
              body: const Center(
                child: Text('プロフィールを更新しました'),
              ),
            );
          }
          return _defaultView(context, state);
        },
      ),
    );
  }

  Widget _defaultView(BuildContext context, EditUserScreenState state) {
    AppUser _user;
    if (state is InitializeSuccess) {
      _user = state.user;
    }

    void _updateUserButtonEvent() {
      FocusScope.of(context).unfocus();
      final user = _editUserFormStateKey.currentState.get();
      if (_formKey.currentState.validate()) {
        context.read<EditUserScreenBloc>().add(UpdateUserOnPressed(user: user));
      }
    }

    return ModalProgressHUD(
      inAsyncCall: state is UpdateUserInProgress,
      child: Scaffold(
        appBar: simpleAppBar(
          context,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  '保存',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: state is UpdateUserInProgress
                            ? AppColors.grey60
                            : Theme.of(context).primaryColor,
                      ),
                ),
                onPressed: _updateUserButtonEvent,
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ScrollableLayoutBuilder(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: EditUserForm(
                  key: _editUserFormStateKey,
                  initialValue: _user,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
