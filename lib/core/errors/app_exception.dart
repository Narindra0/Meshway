/// Catégories d'erreurs affichables à l'utilisateur.
enum AppErrorCode {
  transport,
  storage,
  crypto,
  validation,
  permission,
  unknown,
}

sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  AppErrorCode get code;

  @override
  String toString() => '$code: $message';
}

final class TransportException extends AppException {
  const TransportException(super.message, {super.cause, super.stackTrace});

  @override
  AppErrorCode get code => AppErrorCode.transport;
}

final class StorageException extends AppException {
  const StorageException(super.message, {super.cause, super.stackTrace});

  @override
  AppErrorCode get code => AppErrorCode.storage;
}

final class CryptoException extends AppException {
  const CryptoException(super.message, {super.cause, super.stackTrace});

  @override
  AppErrorCode get code => AppErrorCode.crypto;
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause, super.stackTrace});

  @override
  AppErrorCode get code => AppErrorCode.validation;
}

final class PermissionException extends AppException {
  const PermissionException(super.message, {super.cause, super.stackTrace});

  @override
  AppErrorCode get code => AppErrorCode.permission;
}

final class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause, super.stackTrace});

  @override
  AppErrorCode get code => AppErrorCode.unknown;
}
