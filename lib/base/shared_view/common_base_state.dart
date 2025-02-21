import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../di/di.dart';
import '../../resource/generated/assets.gen.dart';
import '../bloc/base_bloc/base_bloc.dart';
import '../bloc/base_bloc/base_event.dart';
import '../bloc/base_bloc/base_state.dart';
import '../bloc/common_bloc/common_bloc.dart';
import '../bloc/common_bloc/common_state.dart';
import '../constants/ui/app_colors.dart';
import '../exception/app_exception.dart';
import '../helper/duration_provider.dart';
import '../navigator/app_navigator.dart';

enum LoadingType { circle, line }

abstract class CommonBaseState<P extends StatefulWidget, T extends BaseBloc<BaseEvent, BaseState>> extends State<P> {
  late final AppNavigator navigator = SL.get<AppNavigator>();
  late final CommonBloc commonBloc = SL.get<CommonBloc>();
  late final T bloc = SL.get<T>()
    ..navigator = navigator
    ..commonBloc = commonBloc;

  bool get shouldUseApplicationWidget => false;

  LoadingType get loadingType => LoadingType.line;

  @override
  void dispose() {
    commonBloc.close();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldUseApplicationWidget) AppColors.of(context);

    return Provider(
      create: (_) => navigator,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: commonBloc),
          BlocProvider.value(value: bloc),
        ],
        child: BlocListener<CommonBloc, CommonState>(
          listenWhen: (previous, current) => previous.exception != current.exception && current.exception != null,
          listener: (_, state) => handleException(state.exception!),
          child: buildListeners(
            child: shouldUseApplicationWidget
                ? buildPage(context)
                : Stack(
                    children: [
                      buildPage(context),
                      BlocSelector<CommonBloc, CommonState, bool>(
                          selector: (state) => state.isLoading,
                          builder: (_, isLoading) {
                            return AnimatedSwitcher(
                              duration: const MediumDuration(),
                              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                              child: Visibility(
                                visible: isLoading,
                                key: ValueKey<String>('loading_core_$isLoading'),
                                child: buildLoading(),
                              ),
                            );
                          })
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context);

  Widget buildListeners({required Widget child}) => child;

  Widget buildLoading() {
    if (loadingType == LoadingType.circle) return const Center(child: CircularProgressIndicator());
    return Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(color: Colors.black.withOpacity(.16), dismissible: false),
        Transform.scale(scale: .25, child: Assets.animations.loading.lottie(fit: BoxFit.scaleDown)),
      ],
    );
  }

  void handleException(AppException e) async {
    if (e.type == AppExceptionType.unauthorized) {
      // Handle unauthorized exception
      return;
    }
    if(e.type == AppExceptionType.unknown) {
      navigator.displayDialog(AppDialogType.ok, message: e.message);
    }
  }
}
