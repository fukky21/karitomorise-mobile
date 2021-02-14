import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart';
import '../../providers/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class MyPageTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, title: 'マイページ'),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _accountCard(context),
            const SizedBox(height: 20),
            SignButton(),
            const SizedBox(height: 20),
            CustomRaisedButton(
              width: 300,
              labelText: 'GO TO TEST USER2',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  ShowUserScreen.route,
                  arguments: ShowUserScreenArguments(
                    uid: '6EgrOanTTXdUY9r50Gqo7TRr3Uh2',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountCard(BuildContext context) {
    final _width = MediaQuery.of(context).size.width * 0.9;
    const _height = 80.0;

    return Consumer<CurrentUserProvider>(
      builder: (context, currentUserProvider, _) {
        final _currentUser = currentUserProvider.currentUser;
        if (_currentUser == null) {
          return Container();
        }
        return Consumer<UsersProvider>(
          builder: (context, usersProvider, _) {
            final _user = usersProvider.get(_currentUser.uid);
            Widget _child;
            void Function() _onTap;
            if (_user == null) {
              _child = const Center(child: CircularProgressIndicator());
            } else {
              _child = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Flexible(
                      child: Row(
                        children: [
                          CustomCircleAvatar(
                            filePath: _user.avatarType.iconFilePath,
                            radius: _height / 2 - 10,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _user.displayName ?? 'Unknown',
                              maxLines: 2,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: const Icon(Icons.chevron_right_sharp),
                  ),
                ],
              );
              _onTap = () {
                Navigator.pushNamed(
                  context,
                  ShowUserScreen.route,
                  arguments: ShowUserScreenArguments(uid: _user.id),
                );
              };
            }

            return Card(
              color: AppColors.grey20,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: _width,
                  height: _height,
                  child: _child,
                ),
                onTap: _onTap,
              ),
            );
          },
        );
      },
    );
  }
}
