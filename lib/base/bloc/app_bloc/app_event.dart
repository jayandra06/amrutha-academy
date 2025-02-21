import 'package:flutter_bloc_template/base/bloc/base_bloc/base_event.dart';
import 'package:flutter_bloc_template/domain/entity/config/load_app_config_entity.dart';

sealed class AppEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

final class AppStartedEvent extends AppEvent {
  final LoadAppConfigEntity loadAppConfig;

  AppStartedEvent(this.loadAppConfig);
}

final class UserLoggedInEvent extends AppEvent {
  final String userId;
  UserLoggedInEvent(this.userId);
}

final class UserLoggedOutEvent extends AppEvent {}

final class LoadAppConfigEvent extends AppEvent {}

final class ConnectivityChangedEvent extends AppEvent {
  final bool isConnected;
  ConnectivityChangedEvent(this.isConnected);
}

class ThemeChangedEvent extends AppEvent {
  final bool isDarkMode;
  ThemeChangedEvent(this.isDarkMode);
}

class LanguageChangedEvent extends AppEvent {
  final String languageCode;
  LanguageChangedEvent(this.languageCode);
}
