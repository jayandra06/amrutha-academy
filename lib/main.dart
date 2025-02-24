import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/bloc/app_bloc/app_bloc.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_theme.dart';
import 'package:flutter_bloc_template/base/helper/log.dart';
import 'package:flutter_bloc_template/config/environment.dart';
import 'package:flutter_bloc_template/di/di.dart';
import 'package:flutter_bloc_template/domain/entity/config/load_app_config_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/config/load_app_config_use_case.dart';
import 'package:flutter_bloc_template/navigation/router.dart';
import 'package:flutter_bloc_template/navigation/router.gr.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'base/bloc/app_bloc/app_event.dart';
import 'base/shared_view/foundation_state.dart';
import 'base/utils/http_utils.dart';
import 'config/app_config.dart';
import 'navigation/app_router_observer.dart';
import 'resource/generated/l10n.dart';

Future<void> initApp({
  AsyncCallback beforeRun = _defaultBeforeRun,
  required AppEnvironment env,
  required bool enableLog,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  CoreLog.enableLog = enableLog;
  HttpOverrides.global = MyHttpOverrides();
  SL.registerLazySingleton<EnvironmentConfigurable>(() => env);

  await beforeRun.call();

  CoreLog.i('Starting app with environment: ${env.getBaseUrl()}');

  final loadAppConfig = SL.get<LoadAppConfigUseCase>().invoke(null);

  CoreLog.i('Load App config: $loadAppConfig');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: SL.get<AppBloc>()..add(AppStartedEvent(loadAppConfig))),
      ],
      child: _MyApp(config: loadAppConfig),
    ),
  );
}

Future<void> _defaultBeforeRun() async {
  // Default logic (if any) before app runs
  await AppConfig.instance().init();
}

class _MyApp extends StatefulWidget {
  const _MyApp({required this.config});

  final LoadAppConfigEntity config;

  @override
  State<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends FoundationState<_MyApp, AppBloc> {
  late final appRouter = SL.get<AppRouter>();

  @override
  bool get shouldUseApplicationWidget => true;

  @override
  Widget buildPage(BuildContext context) {
    return MaterialApp.router(
      title: SL.get<EnvironmentConfigurable>().getBrandName(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routeInformationParser: appRouter.defaultRouteParser(),
      routerDelegate: appRouter.delegate(
        navigatorObservers: () => [AppRouterObserver()],
        deepLinkBuilder: (deepLink) => _handleDeepLinkBuilder(deepLink),
      ),
    );
  }

  FutureOr<DeepLink> _handleDeepLinkBuilder(PlatformDeepLink deepLink) async {
    late List<PageRouteInfo> routes;
    routes = [const SplashRoute()];

    if (widget.config.isFirstLaunchApp) routes = [const OnboardingRoute()];

    routes = [const MainRoute()];
    return DeepLink(routes);
  }
}
