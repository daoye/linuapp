import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'dart:io';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();


  // 初始化 SQLite3 原生库（Android 需要）
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }

  // 保持原生 splash 直到 Flutter 准备好
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    const ProviderScope(
      child: LinuApp(),
    ),
  );
}
