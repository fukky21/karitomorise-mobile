import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/follow_button_bloc/index.dart';
import '../../providers/index.dart';
import 'custom_outline_button.dart';
import 'custom_raised_button.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({
    @required this.uid,
    @required this.width,
    @required this.height,
  });

  final String uid;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FollowButtonBloc>(
      create: (context) => FollowButtonBloc(context: context),
      child: BlocBuilder<FollowButtonBloc, FollowButtonState>(
        builder: (context, state) {
          if (state != null && state.inProgress) {
            return SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Consumer<FollowingProvider>(
            builder: (context, provider, _) {
              final _following = provider?.following ?? [];
              if (_following.contains(uid)) {
                return CustomRaisedButton(
                  labelText: 'フォロー中',
                  width: width,
                  height: height,
                  onPressed: () {
                    context
                        .read<FollowButtonBloc>()
                        .add(UnFollowUserOnPressed(uid: uid));
                  },
                );
              }
              return CustomOutlineButton(
                labelText: 'フォローする',
                width: width,
                height: height,
                onPressed: () {
                  context
                      .read<FollowButtonBloc>()
                      .add(FollowUserOnPressed(uid: uid));
                },
              );
            },
          );
        },
      ),
    );
  }
}
