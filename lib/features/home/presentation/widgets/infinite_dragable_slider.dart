import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animation_app1/features/home/presentation/widgets/dragable_widget.dart';

// We made it :)
// On next we are gonna learn, How to make this 3D slide

class InfiniteDragableSlider extends StatefulWidget {
  final Function(BuildContext context, int index) itemBuilder;

  final int iteamCount;
  final int index;
  const InfiniteDragableSlider({
    super.key,
    required this.itemBuilder,
    required this.iteamCount,
    this.index = 0,
  });

  @override
  State<InfiniteDragableSlider> createState() => _InfiniteDragableSliderState();
}

class _InfiniteDragableSliderState extends State<InfiniteDragableSlider>
    with SingleTickerProviderStateMixin {
  final double defaultAngle18Dgree = pi * 0.1;

  late AnimationController controller;
  late int index;

  SlideDirection slideDirection = SlideDirection.left;

  void animationListener() {
    if (controller.isCompleted) {
      // Pretty soon you will get it
      // It helps us to make it infinite slide
      setState(() {
        if (widget.iteamCount == ++index) {
          index = 0;
        }
      });
      controller.reset();
    }
  }

  // It made the slide, but it looks bit wired because now there is no animation while shifting

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Stack(
            children: List.generate(
              4,
              (stackIndex) {
                final modIndex = (index + 3 - stackIndex) % widget.iteamCount;
                return Transform.translate(
                  offset: getOffser(stackIndex),
                  child: Transform.scale(
                    scale: getScal(stackIndex),
                    child: Transform.rotate(
                      angle: getAngle(stackIndex),
                      child: DragableWidget(
                        onSlideOut: onSlideOut,
                        isEnableDrag: stackIndex == 3,
                        child: widget.itemBuilder(context, modIndex),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  @override
  void dispose() {
    controller
      ..removeListener(animationListener)
      ..dispose();
    super.dispose();
  }

  double getAngle(int stackIndex) =>
      {
        0: lerpDouble(0, -defaultAngle18Dgree, controller.value),
        1: lerpDouble(
            -defaultAngle18Dgree, defaultAngle18Dgree, controller.value),
        2: lerpDouble(defaultAngle18Dgree, 0, controller.value),
      }[stackIndex] ??
      0.0;

  Offset getOffser(int stackIndex) {
    return {
          0: Offset(lerpDouble(0, -70, controller.value)!, 30),
          1: Offset(lerpDouble(-70, 70, controller.value)!, 30),
          2: const Offset(70, 30) * (1 - controller.value),
        }[stackIndex] ??
        Offset(
            MediaQuery.of(context).size.width *
                controller.value *
                (slideDirection == SlideDirection.left ? -1 : 1),
            0);
  }

  // We are almost made it, it feels so good to slide
  double getScal(int stackIndex) =>
      {
        0: lerpDouble(0.6, 0.9, controller.value),
        1: lerpDouble(0.9, 0.95, controller.value),
        2: lerpDouble(0.95, 1, controller.value),
      }[stackIndex] ??
      1.0;

  @override
  void initState() {
    index = widget.index;
    controller =
        AnimationController(vsync: this, duration: kThemeAnimationDuration)
          ..addListener(animationListener);
    super.initState();
  }

  void onSlideOut(SlideDirection direction) {
    slideDirection = direction;
    controller.forward();
  }
}
