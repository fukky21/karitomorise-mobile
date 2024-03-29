import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../repositories/firebase_post_repository.dart';
import '../../repositories/firebase_user_repository.dart';
import '../../store.dart';
import '../../ui/components/custom_app_bar.dart';
import '../../ui/components/custom_divider.dart';
import '../../ui/components/custom_raised_button.dart';
import '../../ui/components/post_cell.dart';
import '../../ui/notification/notification_view_model.dart';
import '../../util/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  static const route = '/notification';
  static const _appBarTitle = '通知';

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select((Store store) => store.currentUser);

    return Scaffold(
      appBar: simpleAppBar(context, title: _appBarTitle),
      body: currentUser == null || currentUser.isAnonymous
          ? const Center(
              child: Text('サインインすると表示されます'),
            )
          : _NotificationList(),
    );
  }
}

class _NotificationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel()..init(),
      child: Consumer<NotificationViewModel>(
        builder: (context, viewModel, _) {
          final state = viewModel.getState() ?? NotificationScreenLoading();

          if (state is NotificationScreenLoadFailure) {
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('エラーが発生しました'),
                    const SizedBox(height: 30),
                    CustomRaisedButton(
                      labelText: '再読み込み',
                      onPressed: () async => viewModel.init(),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotificationScreenLoadSuccess) {
            final stream = state.stream;

            return StreamBuilder(
              stream: stream,
              builder: (context, AsyncSnapshot<List<int>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final postNumbers = snapshot.data;
                final cells = <_NotificationCell>[];
                for (final number in postNumbers) {
                  cells.add(_NotificationCell(postNumber: number));
                }

                if (cells.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: const Text('通知はありません'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => viewModel.init(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: postNumbers.length,
                    itemBuilder: (context, index) => cells[index],
                    separatorBuilder: (context, _) => CustomDivider(),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _NotificationCell extends StatelessWidget {
  _NotificationCell({@required this.postNumber});

  final _userRepository = FirebaseUserRepository();
  final _postRepository = FirebasePostRepository();
  final int postNumber;

  Future<String> _getPost(BuildContext context) async {
    final store = context.read<Store>();
    final post = await _postRepository.getPost(number: postNumber);

    if (post.isAnonymous) {
      store.addUser(
        user: AppUser(
          id: post.uid,
          name: '名無しのハンター',
          avatar: AppUserAvatar.unknown,
        ),
      );
    } else {
      final user = await _userRepository.getUser(id: post.uid);
      store.addUser(user: user);
    }

    store.addPost(post: post);
    return post.id;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPost(context),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          final postId = snapshot.data;
          return PostCell(postId: postId);
        }
        return Container(
          color: AppColors.grey20,
          width: double.infinity,
          height: 150,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
