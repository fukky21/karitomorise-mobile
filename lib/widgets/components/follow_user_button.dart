import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/follow_user_button_bloc/index.dart';
import '../../models/index.dart';
import 'custom_outline_button.dart';
import 'custom_raised_button.dart';

class FollowUserButton extends StatelessWidget {
  const FollowUserButton({
    @required this.user,
    @required this.width,
    @required this.height,
  });

  final AppUser user;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FollowUserButtonBloc(context: context),
      child: BlocBuilder<FollowUserButtonBloc, FollowUserButtonState>(
        builder: (context, state) {
          if (state != null && state.inProgress) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if (user?.isFollowed != null) {
            if (user.isFollowed) {
              return CustomRaisedButton(
                labelText: 'フォロー中',
                width: width,
                height: height,
                onPressed: () {
                  BlocProvider.of<FollowUserButtonBloc>(context).add(
                    UnFollowUserOnPressed(user: user),
                  );
                },
              );
            }
            return CustomOutlineButton(
              labelText: 'フォローする',
              width: width,
              height: height,
              onPressed: () {
                BlocProvider.of<FollowUserButtonBloc>(context).add(
                  FollowUserOnPressed(user: user),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
