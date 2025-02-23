import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/bloc/base_bloc/base_bloc.dart';
import 'package:flutter_bloc_template/base/helper/duration_provider.dart';
import 'package:flutter_bloc_template/base/helper/result.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_search_history_list_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_search_suggestion_list_use_case.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_event.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_state.dart';
import 'package:injectable/injectable.dart';

import '../../../../../base/helper/stream_helper.dart';

@injectable
class HomeSearchBloc extends BaseBloc<HomeSearchEvent, HomeSearchState> {
  HomeSearchBloc(
    this._fetchSearchSuggestionListUseCase,
    this._fetchSearchHistoryListUseCase,
  ) : super(HomeSearchState()) {
    on<HomeSearchDataRequestEvent>(_onHomeSearchDataRequestEvent);
    on<HomeSearchKeywordChangedEvent>(
      _onHomeSearchKeywordChangedEvent,
      transformer: debounceTransformer(const VeryLongDuration()),
    );
  }

  final FetchSearchSuggestionListUseCase _fetchSearchSuggestionListUseCase;
  final FetchSearchHistoryListUseCase _fetchSearchHistoryListUseCase;

  Future<void> _onHomeSearchDataRequestEvent(HomeSearchDataRequestEvent event, Emitter<HomeSearchState> emit) async {
    return runAction(
      onAction: () async {
        final result = await _fetchSearchHistoryListUseCase.invoke(null);
        result.when(
          ok: (data) {
            emit(state.copyWith(histories: data));
          },
        );
      },
      handleLoading: false,
    );
  }

  FutureOr<void> _onHomeSearchKeywordChangedEvent(HomeSearchKeywordChangedEvent event, Emitter<HomeSearchState> emit) {}
}
