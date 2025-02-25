import 'package:flutter/widgets.dart';

class CommonExpandableSection extends StatefulWidget {
  final Widget child;
  final bool expand;

  const CommonExpandableSection({super.key, this.expand = false, required this.child});

  @override
  State<CommonExpandableSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<CommonExpandableSection> with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(CommonExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
  }
}
