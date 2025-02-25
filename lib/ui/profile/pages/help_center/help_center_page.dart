import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/shared_view/common_app_bar.dart';
import 'package:flutter_bloc_template/base/shared_view/common_expandable_section.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';
import 'package:flutter_bloc_template/domain/entity/enum/enum.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:flutter_bloc_template/ui/home/components/home_search_widget.dart';
import 'package:flutter_bloc_template/ui/profile/pages/help_center/components/help_center_item_widget.dart';
import 'package:flutter_bloc_template/ui/widgets/custom_chip_widget.dart';
import 'package:gap/gap.dart';

@RoutePage()
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: HelpCenterTab.values.length,
      child: CommonScaffold(
        appBar: CommonAppBar(
          text: 'Help Center',
          centerTitle: false,
          onLeadingPressed: () => AutoRouter.of(context).back(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Dimens.paddingVerticalLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(tabs: HelpCenterTab.values.map<Widget>((e) => Tab(text: e.fromTitle())).toList()),
              const Gap(Dimens.paddingVerticalLarge),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemCount: 5,
                  itemBuilder: (_, int index) {
                    return CustomChipWidget(
                      label: 'Index $index',
                      onSelected: (v) {},
                    );
                  },
                ),
              ),
              const Gap(Dimens.paddingVerticalLarge),
              HomeSearchWidget(
                onChanged: (val) {},
                onFilterPressed: () {},
              ),
              const Gap(Dimens.paddingVerticalLarge),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (_, __) => const Gap(Dimens.paddingVerticalLarge),
                  itemCount: 5,
                  itemBuilder: (_, int index) {
                    return const HelpCenterItemWidget();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
