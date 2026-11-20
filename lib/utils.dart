import "package:mrlgplayer/main.dart";
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import "package:material_ui/material_ui.dart" as material_ui show debugPrint;

void debugPrint(Object? object) {
  MRLGPlayerState.logBucket.add(
    LogEvent(level: LogLevel.debug, message: object.toString()),
  );
  material_ui.debugPrint(object.toString());
}
