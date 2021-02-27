import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../blocs/create_event_screen_bloc/index.dart';
import '../../widgets/components/index.dart';

class CreateEventScreen extends StatefulWidget {
  static const route = '/create_event';

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const _appBarTitle = '募集を作成';
  final _formKey = GlobalKey<FormState>();
  final _editEventFormStateKey = GlobalKey<EditEventFormState>();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateEventScreenBloc>(
      create: (context) => CreateEventScreenBloc(context: context),
      child: BlocBuilder<CreateEventScreenBloc, CreateEventScreenState>(
        builder: (context, state) {
          if (state is CreateEventFailure) {
            return _createEventFailureView(context);
          }
          if (state is CreateEventSuccess) {
            return _createEventSuccessView(context);
          }
          return _defaultView(context, state);
        },
      ),
    );
  }

  Widget _createEventFailureView(BuildContext context) {
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

  Widget _createEventSuccessView(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(context, title: _appBarTitle),
      body: const Center(
        child: Text('募集を作成しました'),
      ),
    );
  }

  Widget _defaultView(BuildContext context, CreateEventScreenState state) {
    void _createEventButtonEvent() {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState.validate()) {
        final event = _editEventFormStateKey.currentState.get();
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
    }

    return ModalProgressHUD(
      inAsyncCall: state is CreateEventInProgress,
      child: Scaffold(
        appBar: simpleAppBar(context, title: _appBarTitle),
        body: Form(
          key: _formKey,
          child: ScrollableLayoutBuilder(
            controller: _scrollController,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    EditEventForm(
                      key: _editEventFormStateKey,
                      initialValue: null,
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomRaisedButton(
                        labelText: '作成する',
                        onPressed: _createEventButtonEvent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
