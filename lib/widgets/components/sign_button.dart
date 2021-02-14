import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/sign_button_bloc/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class SignButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignButtonBloc>(
      create: (context) => SignButtonBloc(context: context),
      child: BlocBuilder<SignButtonBloc, SignButtonState>(
        builder: (context, state) {
          Widget _child;
          if (state != null && state.inProgress) {
            _child = InkWell(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 50,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              onTap: null,
            );
          } else {
            _child = Consumer<CurrentUserProvider>(
              builder: (context, provider, _) {
                if (provider.currentUser == null) {
                  return InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      child: Text(
                        'サインイン',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, SignInScreen.route);
                    },
                  );
                } else {
                  return InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 50,
                      child: Text(
                        'サインアウト',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context).errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    onTap: () {
                      BlocProvider.of<SignButtonBloc>(context).add(
                        SignOutOnPressed(),
                      );
                    },
                  );
                }
              },
            );
          }

          return Column(
            children: [
              CustomDivider(),
              Material(
                color: AppColors.grey20,
                child: _child,
              ),
              CustomDivider(),
            ],
          );
        },
      ),
    );
  }
}
