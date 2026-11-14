import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/themes/base.dart';

class DefaultTheme extends AppTheme {
  DefaultTheme()
      : super(
          theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness:Brightness.light),),
          darkTheme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness:Brightness.dark),),
        );
}