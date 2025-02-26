import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/shared_view/animation/common_animation_slide.dart';
import 'package:flutter_bloc_template/base/shared_view/common_app_bar.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';

import '../../../../base/constants/ui/app_text_styles.dart';

@RoutePage()
class SettingPaymentPage extends StatefulWidget {
  const SettingPaymentPage({super.key});

  @override
  State<SettingPaymentPage> createState() => _SettingPaymentPageState();
}

class _SettingPaymentPageState extends State<SettingPaymentPage> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        text: 'Payment',
        titleType: AppBarTitle.widget,
        centerTitle: false,
        onLeadingPressed: () => AutoRouter.of(context).back(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
