import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/index.dart';
import '../../widgets/components/index.dart';
import 'sign_button_event.dart';
import 'sign_button_state.dart';

class SignButtonBloc extends Bloc<SignButtonEvent, SignButtonState> {
  SignButtonBloc({@required this.context}) : super(null) {
    _authRepository = context.read<FirebaseAuthenticationRepository>();
  }

  final BuildContext context;
  FirebaseAuthenticationRepository _authRepository;

  @override
  Stream<SignButtonState> mapEventToState(SignButtonEvent event) async* {
    if (event is SignOutOnPressed) {
      yield* _mapSignOutOnPressedToState();
    }
  }

  Stream<SignButtonState> _mapSignOutOnPressedToState() async* {
    yield SignButtonState(inProgress: true);
    try {
      await _authRepository.signOut();
      showSnackBar(context, 'サインアウトしました');
      yield SignButtonState(inProgress: false);
    } on Exception catch (e) {
      debugPrint(e.toString());
      showSnackBar(context, 'エラーが発生しました');
      yield SignButtonState(inProgress: false);
    }
  }
}
