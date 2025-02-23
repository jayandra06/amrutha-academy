import 'package:flutter_bloc_template/base/bloc/base_bloc/base_state.dart';
import 'package:flutter_bloc_template/base/bloc/load_status.dart';
import 'package:flutter_bloc_template/base/helper/checker.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';

final class HomeSearchState extends BaseState {
  final List<SearchHistoryEntity> histories;
  final List<String> suggestions;
  final bool isTyping;
  final LoadStatus status;
  final String keyword;

  HomeSearchState({
    this.histories = const [],
    this.isTyping = false,
    this.suggestions = const [],
    this.status = LoadStatus.idle,
    this.keyword = '',
  });

  HomeSearchState copyWith({
    List<SearchHistoryEntity>? histories,
    bool? isTyping,
    List<String>? suggestions,
    LoadStatus? status,
    String? keyword,
  }) {
    return HomeSearchState(
      histories: histories ?? this.histories,
      isTyping: isTyping ?? this.isTyping,
      suggestions: suggestions ?? this.suggestions,
      status: status ?? this.status,
      keyword: keyword ?? this.keyword,
    );
  }

  bool get isSubmit => !empty(keyword);

  @override
  List<Object?> get props => [
        histories,
        suggestions,
        isTyping,
        status,
        keyword,
      ];
}
