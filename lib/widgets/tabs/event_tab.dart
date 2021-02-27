import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class EventTab extends StatelessWidget {
  static const _appBarTitle = '募集';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      cubit: context.watch<AuthenticationBloc>(),
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return Scaffold(
            appBar: simpleAppBar(context, title: _appBarTitle),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: AppColors.white),
              onPressed: () {
                Navigator.pushNamed(context, CreateEventScreen.route);
              },
            ),
            body: const Center(
              child: Text('EVENT'),
            ),
          );
        }
        return Scaffold(
          appBar: simpleAppBar(context, title: _appBarTitle),
          body: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('サインインすると表示されます'),
                  const SizedBox(height: 30),
                  CustomRaisedButton(
                    labelText: 'サインインする',
                    onPressed: () {
                      Navigator.pushNamed(context, SignInScreen.route);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
