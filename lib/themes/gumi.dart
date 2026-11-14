import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/themes/base.dart';

class RinTheme extends AppTheme {
  RinTheme()
      : super(
          theme: ThemeData(colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 109, 237, 83), brightness:Brightness.light),),
          darkTheme: ThemeData(colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 109, 237, 83), brightness:Brightness.dark),),
        );
}