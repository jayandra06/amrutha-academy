import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/shared_view/common_app_bar.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:flutter_bloc_template/ui/home/components/home_search_widget.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_bloc.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_event.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/bloc/home_search_state.dart';
import 'package:gap/gap.dart';

import '../../../../base/shared_view/common_base_state.dart';

@RoutePage()
class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({super.key});

  @override
  State<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends CommonBaseState<HomeSearchPage, HomeSearchBloc> {
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.histories.isNotEmpty) Expanded(child: buildHistoryList(state.histories)),
              ],
            );
          },
        ),
      ),
    );
  }

  _buildAppBar() {
    return CommonAppBar(
      text: HomeSearchWidget(
        autoFocus: true,
        onChanged: (String value) => bloc.add(HomeSearchKeywordChangedEvent(keyword: value.trim())),
      ),
      titleType: AppBarTitle.widget,
      height: 100,
    );
  }

  Widget buildHistoryList(List<SearchHistoryEntity> histories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent', style: AppTextStyles.h5Bold),
        const Gap(Dimens.paddingVerticalLarge),
        Divider(height: 1, color: AppColors.current.greyscale200),
        const Gap(Dimens.paddingVerticalLarge),
        Expanded(
            child: ListView.separated(
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (_, __) => const Gap(Dimens.paddingVerticalLarge),
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final item = histories[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.keyword,
                  style: AppTextStyles.bodyXLargeMedium.copyWith(color: AppColors.current.greyscale600),
                ),
                const Gap(12),
                Assets.icons.closeSquareCurved.svg(),
              ],
            );
          },
        ))
      ],
    );
  }
}
