import 'package:hafatra/core/constants/mesh_constants.dart';

/// Limite le débit par expéditeur pour contenir les inondations locales.
final class MeshRateLimiter {
  MeshRateLimiter({
    this.maxPerWindow = 20,
    this.minInterval = const Duration(seconds: 2),
  });

  final int maxPerWindow;
  final Duration minInterval;
  final Map<String, List<DateTime>> _events = {};

  bool allow(String senderId, DateTime now) {
    final events = _events.putIfAbsent(senderId, () => <DateTime>[])
      ..removeWhere(
        (time) => now.difference(time) > MeshConstants.rateLimitWindow,
      );
    if (events.isNotEmpty) {
      final last = events.last;
      if (now.difference(last) < minInterval) {
        return false;
      }
    }
    if (events.length >= maxPerWindow) {
      return false;
    }
    events.add(now);
    return true;
  }

  void clear() => _events.clear();
}
