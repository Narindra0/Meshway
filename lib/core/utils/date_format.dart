import 'package:intl/intl.dart';

/// Formats numériques volontairement indépendants de la locale : ils restent
/// lisibles en français comme en malgache, y compris sur les téléphones dont
/// les données de date système sont incomplètes.
abstract final class AppDateFormat {
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dayMonth = DateFormat('dd/MM');
  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat _full = DateFormat('dd/MM/yyyy HH:mm');

  static String time(DateTime moment) => _time.format(moment.toLocal());

  static String short(DateTime moment) {
    final local = moment.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (sameDay) {
      return _time.format(local);
    }
    if (local.year == now.year) {
      return '${_dayMonth.format(local)} ${_time.format(local)}';
    }
    return _full.format(local);
  }

  static String full(DateTime moment) => _full.format(moment.toLocal());

  /// Clé de regroupement : deux messages appartiennent au même jour quand leur
  /// clé coïncide, indépendamment du fuseau et de l'heure.
  static String dayKey(DateTime moment) {
    final local = moment.toLocal();
    return '${local.year}-${local.month}-${local.day}';
  }

  /// Libellé de séparateur de date hors « aujourd'hui » et « hier », qui
  /// relèvent de la traduction.
  static String dayLabel(DateTime moment) {
    final local = moment.toLocal();
    return local.year == DateTime.now().year
        ? _dayMonth.format(local)
        : _dayMonthYear.format(local);
  }
}
