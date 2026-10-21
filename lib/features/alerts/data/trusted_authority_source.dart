import 'package:flutter/services.dart';
import 'package:hafatra/features/alerts/domain/trusted_authority.dart';

abstract interface class TrustedAuthoritySource {
  Future<List<TrustedAuthority>> load();
}

/// Charge la liste embarquée dans `assets/trusted_authorities.json`.
final class AssetTrustedAuthoritySource implements TrustedAuthoritySource {
  AssetTrustedAuthoritySource({
    AssetBundle? bundle,
    this.assetPath = 'assets/trusted_authorities.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  List<TrustedAuthority>? _cache;

  @override
  Future<List<TrustedAuthority>> load() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }
    final source = await _bundle.loadString(assetPath);
    final authorities = TrustedAuthority.listFromJsonString(source);
    _cache = authorities;
    return authorities;
  }
}

/// Utilisé par les tests et la CLI.
final class StaticTrustedAuthoritySource implements TrustedAuthoritySource {
  const StaticTrustedAuthoritySource(this.authorities);

  final List<TrustedAuthority> authorities;

  @override
  Future<List<TrustedAuthority>> load() async => authorities;
}
