import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

/// Petit buffer de logs consultable depuis l'écran Diagnostics.
final class AppLogger {
  AppLogger({Level level = Level.INFO, RotatingFileSink? fileSink})
    : _fileSink = fileSink,
      _level = level {
    // Sans ce mode, `logging` interdit de régler le niveau d'un logger autre
    // que la racine. Le buffer de Hafatra doit rester indépendant.
    hierarchicalLoggingEnabled = true;
    _logger.level = level;
    _subscription = _logger.onRecord.listen(_onRecord);
  }

  static const int maxMemoryLines = 500;

  final Logger _logger = Logger('Hafatra');
  final RotatingFileSink? _fileSink;
  final Level _level;
  final List<String> _memory = [];
  final StreamController<String> _linesController =
      StreamController<String>.broadcast();
  late final StreamSubscription<LogRecord> _subscription;

  Level get level => _level;

  List<String> get lines => List<String>.unmodifiable(_memory);

  Stream<String> get lineStream => _linesController.stream;

  void debug(String message) => _logger.fine(message);

  void info(String message) => _logger.info(message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.warning(message, error, stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.severe(message, error, stackTrace);

  void _onRecord(LogRecord record) {
    final timestamp = record.time.toIso8601String();
    final buffer = StringBuffer(
      '$timestamp ${record.level.name} ${record.message}',
    );
    if (record.error != null) {
      buffer.write(' | ${record.error}');
    }
    final line = buffer.toString();

    _memory.add(line);
    if (_memory.length > maxMemoryLines) {
      _memory.removeAt(0);
    }
    if (!_linesController.isClosed) {
      _linesController.add(line);
    }
    final sink = _fileSink;
    if (sink != null) {
      unawaited(sink.write(line));
    }
  }

  Future<String> export() async {
    if (_memory.isEmpty) {
      return '';
    }
    return _memory.join('\n');
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _linesController.close();
  }
}

/// Écrit les logs dans un fichier avec rotation simple (1 archive).
final class RotatingFileSink {
  RotatingFileSink(this.file, {this.maxBytes = 512 * 1024});

  final File file;
  final int maxBytes;
  Future<void> _pending = Future<void>.value();

  Future<void> write(String line) {
    return _pending = _pending.then((_) => _write(line)).catchError((Object _) {
      // Les logs ne doivent jamais faire planter l'application.
    });
  }

  Future<void> _write(String line) async {
    await file.parent.create(recursive: true);
    // Le sink tourne hors du thread UI : la vérification synchrone de
    // l'existence et de la taille est volontaire pour éviter des courses
    // entre écritures concurrentes sur le même fichier de log.
    // ignore: avoid_slow_async_io
    if (await file.exists() && await file.length() > maxBytes) {
      final backup = File('${file.path}.1');
      // Même raison que ci-dessus : l'archive doit être vérifiée avant
      // d'être supprimée pour ne pas masquer une erreur d'état du disque.
      // ignore: avoid_slow_async_io
      if (await backup.exists()) {
        await backup.delete();
      }
      await file.rename(backup.path);
    }
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }
}
