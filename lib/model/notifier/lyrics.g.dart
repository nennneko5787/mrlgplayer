// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LyricsNotifier)
final lyricsProvider = LyricsNotifierProvider._();

final class LyricsNotifierProvider
    extends $NotifierProvider<LyricsNotifier, LyricsState> {
  LyricsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lyricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lyricsNotifierHash();

  @$internal
  @override
  LyricsNotifier create() => LyricsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LyricsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LyricsState>(value),
    );
  }
}

String _$lyricsNotifierHash() => r'04ba4502e72419e46ab12187e2952c01bf1850b1';

abstract class _$LyricsNotifier extends $Notifier<LyricsState> {
  LyricsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LyricsState, LyricsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LyricsState, LyricsState>,
              LyricsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
