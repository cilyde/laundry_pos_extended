


// const bool isSunmi = true;

// class Config{
//   static const isSunmi = false;
// }

const bool isSunmi = bool.fromEnvironment('IS_SUNMI');
///Use
///flutter build apk --dart-define=IS_SUNMI=true
///while compiling
///
///
/// while running
/// flutter run --dart-define=IS_SUNMI=true
///
///  flutter build apk --dart-define=IS_SUNMI=true
/// adb install -r build/app/outputs/flutter-apk/app-release.apk