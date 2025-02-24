import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/bloc/load_status.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/extension/context_extension.dart';
import 'package:flutter_bloc_template/base/helper/duration_provider.dart';
import 'package:flutter_bloc_template/base/shared_view/common_app_bar.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';
import 'package:flutter_bloc_template/base/shared_view/dialog/app_dialogs.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:flutter_bloc_template/ui/home/components/home_search_widget.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_bloc.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_event.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_state.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/components/home_search_filter_list_widget.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/components/home_search_history_list_widget.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/components/home_search_result_list_widget.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/components/home_search_suggestion_list_widget.dart';
import 'package:gap/gap.dart';

import '../../../../base/shared_view/foundation_state.dart';
import '../../../../base/shared_view/common_circle_loading.dart';

@RoutePage()
class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({super.key});

  @override
  State<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends FoundationState<HomeSearchPage, HomeSearchBloc> {
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc.add(HomeSearchDataRequestEvent());
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.paddingVerticalLarge).copyWith(top: 0),
        child: BlocBuilder<HomeSearchBloc, HomeSearchState>(
          builder: (context, state) {
            if (state.status.isLoading) {
              return const CommonCircleLoading();
            }
            if (!state.isTyping && state.isSubmit) {
              return HomeSearchResultListWidget(
                keyword: state.keyword,
                total: 0,
              );
            }
            if (state.isTyping) {
              return HomeSearchSuggestionListWidget(
                onTap: _didTapValue,
                suggestions: state.suggestions,
              );
            }
            if (!state.isTyping && state.histories.isNotEmpty) {
              return HomeSearchHistoryListWidget(
                histories: state.histories,
                onTap: _didTapValue,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  _buildAppBar() {
    return CommonAppBar(
      text: HomeSearchWidget(
        autoFocus: true,
        controller: _editingController,
        onChanged: (String value) async {
          final completer = Completer<LoadStatus>();
          bloc.add(HomeSearchKeywordChangedEvent(keyword: value.trim(), completer: completer));
          final result = await completer.future;
          bloc.add(HomeSearchStatusChangedEvent(status: result));
        },
        onFilterPressed: () {
          AppDialogs.showScrollBottomSheet(
            context,
            builder: (_, scrollController) => HomeSearchFilterListWidget(
              scrollController: scrollController,
            ),
          );
        },
      ),
      titleType: AppBarTitle.widget,
      height: 100,
    );
  }

  void _didTapValue(String value) {
    context.hideKeyboard();
    _editingController.text = value;
    bloc.add(SubmitHomeSearchEvent(keyword: value));
  }
}
