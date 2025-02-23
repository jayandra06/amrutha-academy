import 'package:flutter_bloc_template/base/bloc/base_bloc/base_state.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';

final class HomeSearchState extends BaseState {
  final List<SearchHistoryEntity> histories;
  final bool isTyping;

  HomeSearchState({
    this.histories = const [],
    this.isTyping = false,
  });

  HomeSearchState copyWith({
    List<SearchHistoryEntity>? histories,
    bool? isTyping,
  }) {
    return HomeSearchState(
      histories: histories ?? this.histories,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [
        histories,
        isTyping,
      ];
}
