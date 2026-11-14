import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/themes/base.dart';

class MikuTheme extends AppTheme {
  MikuTheme()
      : super(
          theme: ThemeData(colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 134, 206, 203), brightness:Brightness.light),),
          darkTheme: ThemeData(colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 134, 206, 203), brightness:Brightness.dark),),
        );
}