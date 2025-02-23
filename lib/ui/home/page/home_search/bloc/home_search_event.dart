import 'dart:async';

import 'package:flutter_bloc_template/base/bloc/base_bloc/base_event.dart';
import 'package:flutter_bloc_template/base/bloc/load_status.dart';

sealed class HomeSearchEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

final class HomeSearchDataRequestEvent extends HomeSearchEvent {}

final class HomeSearchKeywordChangedEvent extends HomeSearchEvent {
  final String keyword;
  final Completer<LoadStatus> completer;

  HomeSearchKeywordChangedEvent({required this.keyword, required this.completer});

  @override
  List<Object?> get props => [
        keyword,
        completer,
      ];
}

final class HomeSearchStatusChangedEvent extends HomeSearchEvent {
  final LoadStatus status;

  HomeSearchStatusChangedEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

final class SubmitHomeSearchEvent extends HomeSearchEvent {
  final String keyword;

  SubmitHomeSearchEvent({required this.keyword});

  @override
  List<Object?> get props => [keyword];
}
