import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../repositories/firebase_report_repository.dart';

class SendReportViewModel with ChangeNotifier {
  final _reportRepository = FirebaseReportRepository();
  SendReportScreenState _state;

  SendReportScreenState getState() {
    return _state;
  }

  Future<void> sendReport({
    @required String report,
    @required int postNumber,
  }) async {
    _state = SendReportInProgress();
    notifyListeners();

    try {
      await _reportRepository.sendReport(
        report: report,
        postNumber: postNumber,
      );
      _state = SendReportSuccess();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint(e.toString());
      _state = SendReportFailure();
      notifyListeners();
    }
  }
}

abstract class SendReportScreenState extends Equatable {
  @override
  List<Object> get props => const [];
}

class SendReportInProgress extends SendReportScreenState {}

class SendReportSuccess extends SendReportScreenState {}

class SendReportFailure extends SendReportScreenState {}
