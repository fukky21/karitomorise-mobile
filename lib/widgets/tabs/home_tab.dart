import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/authentication_bloc/index.dart';
import '../../blocs/home_tab_bloc/index.dart';
import '../../utils/index.dart';
import '../../widgets/components/index.dart';
import '../../widgets/screens/index.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({@required Key key}) : super(key: key);

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  static const _appBarTitle = 'ホーム';
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeTabBloc>(
      create: (context) => HomeTabBloc(context: context)..add(Initialized()),
      child: Scaffold(
        appBar: simpleAppBar(context, title: _appBarTitle),
        floatingActionButton: _createEventButton(),
        body: BlocBuilder<HomeTabBloc, SearchTabState>(
          builder: (context, state) {
            if (state == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.eventIds.isEmpty) {
              return const Center(
                child: Text('現在、募集はありません'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeTabBloc>().add(Initialized());
              },
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.eventIds.length,
                itemBuilder: (context, index) {
                  if (index == state.eventIds.length - 1 &&
                      state.isFetchabled) {
                    context.read<HomeTabBloc>().add(Fetched());
                  }
                  return EventCell(
                    eventId: state.eventIds[index],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ShowEventScreen.route,
                        arguments: ShowEventScreenArguments(
                          eventId: state.eventIds[index],
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, _) => CustomDivider(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _createEventButton() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      cubit: context.watch<AuthenticationBloc>(),
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return FloatingActionButton(
            child: const Icon(Icons.add, color: AppColors.white),
            onPressed: () {
              Navigator.pushNamed(context, CreateEventScreen.route);
            },
          );
        }
        return Container();
      },
    );
  }
}
