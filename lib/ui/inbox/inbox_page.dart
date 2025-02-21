import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/domain/entity/enum/enum.dart';

import '../../base/constants/ui/app_colors.dart';
import '../../base/shared_view/common_app_bar.dart';
import '../../base/shared_view/common_scaffold.dart';
import '../../resource/generated/assets.gen.dart';

@RoutePage()
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: InboxTab.values.length,
      child: CommonScaffold(
        appBar: CommonAppBar(
          text: 'Inbox',
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          leadingIcon: LeadingIcon.none,
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Assets.icons.searchLight.svg(
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.current.greyscale900,
                    BlendMode.srcIn,
                  )),
            ),
            IconButton(
              onPressed: () {},
              icon: Assets.icons.moreCircleLight.svg(
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.current.greyscale900,
                    BlendMode.srcIn,
                  )),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.current.otherWhite,
              padding: const EdgeInsets.all(24).copyWith(bottom: 0),
              child: TabBar(
                tabs: InboxTab.values.map<Widget>((e) => Tab(text: e.fromTitle())).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
