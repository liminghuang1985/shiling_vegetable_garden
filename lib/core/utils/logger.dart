import 'package:flutter/foundation.dart';

/// 应用统一日志工具
///
/// 替代散落的 `print` / `debugPrint`.
/// - Debug 模式: 完整打印 (含时间戳 + 级别 + tag)
/// - Release 模式: 仅 `logger.e` 走 `debugPrint` (debugPrint 在 release 自动静默)
class AppLogger {
  AppLogger._();

  static const String _tag = 'ShilingGarden';

  static void _log(String level, String message, {Object? error, StackTrace? stackTrace}) {
    if (kReleaseMode && level != 'ERROR') {
      // release 模式: info / warn 不输出, 仅 error 走 debugPrint
      if (level == 'ERROR') {
        debugPrint('[$_tag][$level] $message ${error ?? ''}');
      }
      return;
    }
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final buf = StringBuffer('[$_tag][$level][$timestamp] $message');
    if (error != null) buf.write(' | error: $error');
    if (stackTrace != null) buf.write('\n$stackTrace');
    debugPrint(buf.toString());
  }

  /// 普通信息
  static void i(String message) => _log('INFO', message);

  /// 警告
  static void w(String message, {Object? error}) => _log('WARN', message, error: error);

  /// 错误 (release 也会保留)
  static void e(String message, {Object? error, StackTrace? stackTrace}) =>
      _log('ERROR', message, error: error, stackTrace: stackTrace);

  /// 调试
  static void d(String message) => _log('DEBUG', message);
}
