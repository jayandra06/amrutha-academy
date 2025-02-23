import 'package:flutter_bloc_template/base/bloc/base_bloc/base_event.dart';

sealed class HomeSearchEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

final class HomeSearchDataRequestEvent extends HomeSearchEvent {}

final class HomeSearchKeywordChangedEvent extends HomeSearchEvent {
  final String keyword;

  HomeSearchKeywordChangedEvent({required this.keyword});

  @override
  List<Object?> get props => [
        keyword,
      ];
}
