import 'package:drift/native.dart';
import 'package:hafatra/app/bootstrap.dart';
import 'package:hafatra/core/background/foreground_service.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/notifications/notification_service.dart';
import 'package:hafatra/core/permissions/permission_service.dart';
import 'package:hafatra/core/platform/battery_info.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/core/utils/id_generator.dart';
import 'package:hafatra/features/alerts/data/alert_service.dart';
import 'package:hafatra/features/alerts/data/trusted_authority_source.dart';
import 'package:hafatra/features/alerts/domain/alert_verifier.dart';
import 'package:hafatra/features/chat/data/chat_repository.dart';
import 'package:hafatra/features/identity/data/channel_service.dart';
import 'package:hafatra/features/identity/data/identity_service.dart';
import 'package:hafatra/features/identity/data/secret_store.dart';
import 'package:hafatra/features/mesh/data/codec/mesh_packet_codec.dart';
import 'package:hafatra/features/mesh/data/mesh_repository.dart';
import 'package:hafatra/features/settings/data/settings_repository.dart';
import 'package:hafatra/features/settings/domain/app_settings.dart';
import 'package:logging/logging.dart';

/// Batterie figée pour les tests : évite le plugin `battery_plus`.
final class StaticBatteryInfoSource implements BatteryInfoSource {
  const StaticBatteryInfoSource({
    this.info = const BatteryInfo(percent: 82, charging: false),
  });

  final BatteryInfo info;

  @override
  Future<BatteryInfo> read() async => info;
}

/// Regroupe les dépendances et leur fermeture propre après un test.
final class TestHarness {
  const TestHarness(this.dependencies);

  final AppDependencies dependencies;

  Future<void> dispose() async {
    await dependencies.alertService.dispose();
    await dependencies.database.close();
    await dependencies.logger.dispose();
  }
}

/// Construit l'application avec une base Drift en mémoire et des sources
/// déterministes, sans aucun appel aux plugins Android.
///
/// `initialIdentity` et `initialChannel` restent nuls : les tests qui ont
/// besoin d'un profil doivent le créer via `SessionController`.
Future<TestHarness> createTestHarness({
  AppSettings? settings,
  TrustedAuthoritySource authoritySource = const StaticTrustedAuthoritySource(
    [],
  ),
  Clock? clock,
  BatteryInfoSource batteryInfo = const StaticBatteryInfoSource(),
  bool onboardingComplete = false,
}) async {
  final resolvedSettings = settings ?? AppSettings.defaults();
  final resolvedClock = clock ?? FixedClock(DateTime.utc(2026, 10, 20, 12));
  final database = AppDatabase(NativeDatabase.memory());
  await database.customSelect('SELECT 1').get();
  final logger = AppLogger(level: Level.OFF);
  final crypto = CryptoService();
  final idGenerator = SecureIdGenerator(now: resolvedClock.now);
  final secretStore = InMemorySecretStore();
  final identityService = IdentityService(
    database: database,
    crypto: crypto,
    secretStore: secretStore,
    clock: resolvedClock,
    logger: logger,
  );
  final channelService = ChannelService(
    database: database,
    crypto: crypto,
    clock: resolvedClock,
    logger: logger,
  );
  final settingsRepository = SettingsRepository(database);
  final alertService = AlertService(
    database: database,
    verifier: AlertVerifier(crypto),
    authoritySource: authoritySource,
    clock: resolvedClock,
    logger: logger,
  );
  final dependencies = AppDependencies(
    database: database,
    logger: logger,
    clock: resolvedClock,
    idGenerator: idGenerator,
    crypto: crypto,
    codec: MeshPacketCodec(
      crypto: crypto,
      clock: resolvedClock,
      idGenerator: idGenerator,
    ),
    secretStore: secretStore,
    identityService: identityService,
    channelService: channelService,
    chatRepository: ChatRepository(database: database, clock: resolvedClock),
    meshRepository: MeshRepository(database),
    settingsRepository: settingsRepository,
    alertService: alertService,
    authoritySource: authoritySource,
    notificationService: NotificationService(logger: logger),
    permissionService: PermissionService(logger: logger),
    foregroundService: ForegroundServiceController(logger: logger),
    batteryInfo: batteryInfo,
    initialIdentity: null,
    initialChannel: null,
    initialSettings: resolvedSettings,
    onboardingComplete: onboardingComplete,
  );
  return TestHarness(dependencies);
}
