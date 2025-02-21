import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../exception/app_exception.dart';
import '../../navigator/app_navigator.dart';
import '../common_bloc/common_bloc.dart';
import '../common_bloc/common_event.dart';
import 'base_event.dart';
import 'base_state.dart';

abstract class BaseBloc<T extends BaseEvent, S extends BaseState> extends Bloc<T, S> {
  late final CommonBloc _commonBloc;

  BaseBloc(super.initState);

  late AppNavigator navigator;

  @protected
  void showLoading() => _commonBloc.add(LoadingVisibilityEmitted(isLoading: true));

  @protected
  void hideLoading() => _commonBloc.add(LoadingVisibilityEmitted(isLoading: false));

  Future<void> runAction({
    required AsyncCallback? onAction,
    bool handleLoading = true,
    bool handleError = true,
    ValueChanged<Object>? onError,
    VoidCallback? onComplete,
  }) async {
    if (handleLoading) showLoading();
    try {
      await onAction?.call();
    } catch (err) {
      if (err is AppException) buildException(err);

      if (handleError) onError?.call(err);
    } finally {
      if (handleLoading) hideLoading();
      onComplete?.call();
    }
  }

  set commonBloc(CommonBloc commonBloc) {
    _commonBloc = commonBloc;
  }

  void onThrottle<Event extends T>(EventHandler<Event, S> handler, {required Duration duration}) {
    on<Event>(handler, transformer: (events, mapper) {
      return events.throttleTime(duration).switchMap(mapper);
    });
  }

  @override
  void add(T event) {
    if (isClosed) {
      log('⚠️ Unable to add event $event because $runtimeType has already been closed');
      return;
    }
    super.add(event);
  }

  @protected
  void buildException(AppException err) {
    _commonBloc.add(AddExceptionCommonEvent(exception: err));
  }
}
