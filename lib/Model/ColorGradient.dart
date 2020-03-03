import 'package:flutter/cupertino.dart';

class ColorGradient {
  Color start;
  Color end;

  ColorGradient(this.start, this.end);
}

class ColorMap {
  static final Map<String, ColorGradient> colorGradientMap = {
    "Roseanna": ColorGradient(Color(0xFFFFffafbd), Color(0xFFFFffc3a0)),
    "Sexy Blue": ColorGradient(Color(0xFFFF2193b0), Color(0xFFFF6dd5ed)),
    "Purple Love": ColorGradient(Color(0xFFFFcc2b5e), Color(0xFFFF753a88)),
    "Piglet": ColorGradient(Color(0xFFFFee9ca7), Color(0xFFFFffdde1)),
    "Mauve": ColorGradient(Color(0xFFFF42275a), Color(0xFFFF734b6d)),
    "50 Shades of Grey": ColorGradient(Color(0xFFFFbdc3c7), Color(0xFFFF2c3e50)),
    "A Lost Memory": ColorGradient(Color(0xFFFFde6262), Color(0xFFFFffb88c)),
    "Socialive": ColorGradient(Color(0xFFFF06beb6), Color(0xFFFF48b1bf)),
    "Cherry": ColorGradient(Color(0xFFFFeb3349), Color(0xFFFFf45c43)),
    "Pinky": ColorGradient(Color(0xFFFFdd5e89), Color(0xFFFFf7bb97)),
    "Lush": ColorGradient(Color(0xFFFF56ab2f), Color(0xFFa8e063)),
    "Kashmir": ColorGradient(Color(0xFFFF614385), Color(0xFF516395)),
    "Tranquil": ColorGradient(Color(0xFFFFeecda3), Color(0xFFef629f)),
    "Pale Wood": ColorGradient(Color(0xFFFFeacda3), Color(0xFFd6ae7b)),
    "Green Beach": ColorGradient(Color(0xFFFF02aab0), Color(0xFF00cdac)),
    "Sha La La": ColorGradient(Color(0xFFFFd66d75), Color(0xFFe29587)),
    "Frost": ColorGradient(Color(0xFFFF000428), Color(0xFF004e92)),
    "Almost": ColorGradient(Color(0xFFFFddd6f3), Color(0xFFfaaca8)),
    "Virgin America": ColorGradient(Color(0xFFFF7b4397), Color(0xFFdc2430)),
    "Endless River": ColorGradient(Color(0xFFFF43cea2), Color(0xFF185a9d)),
    "Purple White": ColorGradient(Color(0xFFFFba5370), Color(0xFFf4e2d8)),
    "Bloody Mary": ColorGradient(Color(0xFFFFff512f), Color(0xFFdd2476)),
    "Can you feel the love tonight":
        ColorGradient(Color(0xFFFF4568dc), Color(0xFFb06ab3)),
    "Bourbon": ColorGradient(Color(0xFFFFec6f66), Color(0xFFf3a183)),
    "Dusk": ColorGradient(Color(0xFFFFffd89b), Color(0xFF19547b)),
    "Decent": ColorGradient(Color(0xFFFF4ca1af), Color(0xFFc4e0e5)),
    "Sweet Morning": ColorGradient(Color(0xFFFFff5f6d), Color(0xFFffc371)),
    "Scooter": ColorGradient(Color(0xFFFF36d1dc), Color(0xFF5b86e5)),
    "Celestial": ColorGradient(Color(0xFFFFc33764), Color(0xFF1d2671)),
    "Royal": ColorGradient(Color(0xFFFF141e30), Color(0xFF243b55)),
    "Ed’s Sunset Gradient": ColorGradient(Color(0xFFFFff7e5f), Color(0xFFfeb47b)),
    "Peach": ColorGradient(Color(0xFFFFed4264), Color(0xFFffedbc)),
    "Sea Blue": ColorGradient(Color(0xFFFF2b5876), Color(0xFF4e4376)),
    "Orange Coral": ColorGradient(Color(0xFFFFff9966), Color(0xFFff5e62)),
    "Aubergine": ColorGradient(Color(0xFFFFaa076b), Color(0xFF61045f)),
  };
  static getColorGradient(index){
    int size = colorGradientMap.length;
    return colorGradientMap.values.toList()[index%size];
  }
  static getContainerGradient(index){
    ColorGradient colorGradient = getColorGradient(index);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:[colorGradient.start,colorGradient.end],
      stops: [
        0.1,1.0
      ]
    );
  }
}
