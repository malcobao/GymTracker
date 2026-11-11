import 'package:flutter/foundation.dart';

/// Notifies listeners after every successful write to the database
/// (observer pattern). Screens that stay alive in the background, such as
/// statistics and reports, listen to it and reload, so they never show stale
/// numbers.
class DatabaseChanges extends ChangeNotifier {
  void changed() => notifyListeners();
}
