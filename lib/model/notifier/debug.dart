import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug.g.dart';

@riverpod
class DebugNotifier extends _$DebugNotifier {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}
