import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/themes/base.dart';

class LenTheme extends AppTheme {
  LenTheme()
      : super(
          theme: ThemeData(colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 230, 145, 56), brightness:Brightness.light),),
          darkTheme: ThemeData(colorScheme: .fromSeed(seedColor: Color.fromARGB(255, 230, 145, 56), brightness:Brightness.dark),),
        );
}