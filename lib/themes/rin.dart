import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/themes/base.dart';

class RinTheme extends AppTheme {
  RinTheme()
    : super(
        theme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: Color.fromARGB(255, 255, 217, 102),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: Color.fromARGB(255, 255, 217, 102),
            brightness: Brightness.dark,
          ),
        ),
      );
}
