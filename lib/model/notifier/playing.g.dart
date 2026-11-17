// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayingNotifier)
final playingProvider = PlayingNotifierProvider._();

final class PlayingNotifierProvider
    extends $NotifierProvider<PlayingNotifier, Song?> {
  PlayingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playingNotifierHash();

  @$internal
  @override
  PlayingNotifier create() => PlayingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Song? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Song?>(value),
    );
  }
}

String _$playingNotifierHash() => r'116d97206ba0fdd84b03c57c7cebc0fb9fa82e78';

abstract class _$PlayingNotifier extends $Notifier<Song?> {
  Song? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Song?, Song?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Song?, Song?>,
              Song?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
