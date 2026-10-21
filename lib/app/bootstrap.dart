import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
import 'package:hafatra/features/identity/domain/channel_info.dart';
import 'package:hafatra/features/identity/domain/local_identity.dart';
import 'package:hafatra/features/mesh/data/codec/mesh_packet_codec.dart';
import 'package:hafatra/features/mesh/data/mesh_repository.dart';
import 'package:hafatra/features/settings/data/settings_repository.dart';
import 'package:hafatra/features/settings/domain/app_settings.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// Services construits une fois au démarrage. Riverpod les expose ensuite par
/// petits providers spécialisés.
final class AppDependencies {
  const AppDependencies({
    required this.database,
    required this.logger,
    required this.clock,
    required this.idGenerator,
    required this.crypto,
    required this.codec,
    required this.secretStore,
    required this.identityService,
    required this.channelService,
    required this.chatRepository,
    required this.meshRepository,
    required this.settingsRepository,
    required this.alertService,
    required this.authoritySource,
    required this.notificationService,
    required this.permissionService,
    required this.foregroundService,
    required this.batteryInfo,
    required this.initialIdentity,
    required this.initialChannel,
    required this.initialSettings,
    required this.onboardingComplete,
  });

  final AppDatabase database;
  final AppLogger logger;
  final Clock clock;
  final IdGenerator idGenerator;
  final CryptoService crypto;
  final MeshPacketCodec codec;
  final SecretStore secretStore;
  final IdentityService identityService;
  final ChannelService channelService;
  final ChatRepository chatRepository;
  final MeshRepository meshRepository;
  final SettingsRepository settingsRepository;
  final AlertService alertService;
  final TrustedAuthoritySource authoritySource;
  final NotificationService notificationService;
  final PermissionService permissionService;
  final ForegroundServiceController foregroundService;
  final BatteryInfoSource batteryInfo;
  final LocalIdentity? initialIdentity;
  final ChannelInfo? initialChannel;
  final AppSettings initialSettings;
  final bool onboardingComplete;
}

/// Prépare la base, les logs, l'identité et les préférences avant le premier
/// rendu. Toute erreur remonte à `main`, qui affiche un écran de secours.
Future<AppDependencies> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  RotatingFileSink? fileSink;
  try {
    final support = await getApplicationSupportDirectory();
    fileSink = RotatingFileSink(
      File(
        '${support.path}${Platform.pathSeparator}logs'
        '${Platform.pathSeparator}hafatra.log',
      ),
    );
  } on Object {
    // Les logs fichier sont un confort : l'application continue sans eux.
  }

  final logger = AppLogger(
    level: kDebugMode ? Level.FINE : Level.INFO,
    fileSink: fileSink,
  );
  const clock = SystemClock();
  final crypto = CryptoService();
  final idGenerator = SecureIdGenerator();
  final database = AppDatabase();
  await database.customSelect('SELECT 1').get();
  logger.info('Database opened (schema v${database.schemaVersion})');

  final secretStore = SecureSecretStore();
  final identityService = IdentityService(
    database: database,
    crypto: crypto,
    secretStore: secretStore,
    clock: clock,
    logger: logger,
  );
  final channelService = ChannelService(
    database: database,
    crypto: crypto,
    clock: clock,
    logger: logger,
  );
  final identity = await identityService.load();
  final channel = await channelService.load();
  final settingsRepository = SettingsRepository(database);
  final settings = await settingsRepository.load();
  final savedOnboarding = await settingsRepository.isOnboardingComplete();
  final onboardingComplete =
      savedOnboarding && identity != null && channel != null;
  final chatRepository = ChatRepository(database: database, clock: clock);
  final meshRepository = MeshRepository(database);
  final codec = MeshPacketCodec(
    crypto: crypto,
    clock: clock,
    idGenerator: idGenerator,
  );
  final authoritySource = AssetTrustedAuthoritySource();
  final alertService = AlertService(
    database: database,
    verifier: AlertVerifier(crypto),
    authoritySource: authoritySource,
    clock: clock,
    logger: logger,
  );
  final notificationService = NotificationService(logger: logger);
  await notificationService.initialize();
  final permissionService = PermissionService(logger: logger);
  final foregroundService = ForegroundServiceController(logger: logger);
  ForegroundServiceController.initialize();

  logger.info(
    'Bootstrap complete (identity=${identity != null}, '
    'channel=${channel != null}, demo=${settings.demoMode})',
  );

  return AppDependencies(
    database: database,
    logger: logger,
    clock: clock,
    idGenerator: idGenerator,
    crypto: crypto,
    codec: codec,
    secretStore: secretStore,
    identityService: identityService,
    channelService: channelService,
    chatRepository: chatRepository,
    meshRepository: meshRepository,
    settingsRepository: settingsRepository,
    alertService: alertService,
    authoritySource: authoritySource,
    notificationService: notificationService,
    permissionService: permissionService,
    foregroundService: foregroundService,
    batteryInfo: BatteryPlusInfoSource(),
    initialIdentity: identity,
    initialChannel: channel,
    initialSettings: settings,
    onboardingComplete: onboardingComplete,
  );
}
