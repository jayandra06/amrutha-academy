import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/helper/duration_provider.dart';

enum SlideDirection { fromTop, fromLeft, fromRight, fromBottom }

class CommonAnimationSlide extends StatefulWidget {
  final int position;
  final int itemCount;
  final Widget child;
  final SlideDirection slideDirection;
  final Duration duration;

  const CommonAnimationSlide({
    super.key,
    this.position = 0,
    this.itemCount = 1,
    required this.slideDirection,
    required this.child,
    this.duration = const LongDuration(),
  });

  @override
  State<CommonAnimationSlide> createState() => _CommonAnimationSlideState();
}

class _CommonAnimationSlideState extends State<CommonAnimationSlide> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween(begin: .0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (1 / widget.itemCount) * widget.position,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getTranslation(double animationValue) {
    switch (widget.slideDirection) {
      case SlideDirection.fromTop:
        return Offset(0, -50 * (1.0 - animationValue));
      case SlideDirection.fromBottom:
        return Offset(0, 50 * (1.0 - animationValue));
      case SlideDirection.fromRight:
        return Offset(400 * (1.0 - animationValue), 0);
      case SlideDirection.fromLeft:
      default:
        return Offset(-400 * (1.0 - animationValue), 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final translation = _getTranslation(_animation.value);
        return FadeTransition(
          opacity: _animation,
          child: Transform.translate(
            offset: translation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
