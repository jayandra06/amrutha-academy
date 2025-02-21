import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_template/config/environment.dart';
import 'package:flutter_bloc_template/main.dart';

void main() {
  initApp(
    env: AppEnvironment.prod,
    enableLog: !kReleaseMode,
  );
}
