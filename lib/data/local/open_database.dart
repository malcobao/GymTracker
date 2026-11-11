import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app_database.dart';

/// Opens the app's database on the current platform:
/// * Android / iOS / macOS: a SQLite file in the app's private folder (sqflite);
/// * Web (Chrome): SQLite compiled to WebAssembly, saved in the browser's
///   IndexedDB (sqflite_common_ffi_web; files in `web/`). It runs in the
///   page itself (no shared worker), which works in every browser.
Future<Database> openAppDatabase() async {
  if (kIsWeb) {
    return AppDatabase.open(
      databaseFactoryFfiWebNoWebWorker,
      AppDatabase.fileName,
    );
  }
  final folder = await getDatabasesPath();
  return AppDatabase.open(
    databaseFactory,
    p.join(folder, AppDatabase.fileName),
  );
}
