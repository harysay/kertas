/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*
*  Copyright (c) The Flutter Authors.
*  See ThirdPartyNotices.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// const Duration kSMMRouteTransitionDuration = const Duration(milliseconds: 650);
// const Duration kSMMRouteTransitionDuration = const Duration(milliseconds: 550);
const Duration kSMMRouteTransitionDuration = const Duration(milliseconds: 240);

/// Type for function that returns boolean
typedef bool BoolFunction();

/// Needed to define constant [defBoolFunc]
bool _trueFunc() {
  return true;
}

/// Used as default bool function in [RouteTransition]
const BoolFunction defBoolFunc = _trueFunc;

/// Type for function that returns [SystemUiOverlayStyle]
typedef SystemUiOverlayStyle UIFunction();

// Tweens for exit dim animations

/// Tween for exit forward dim
final Tween<double> exitDimTween = Tween<double>(begin: 1.0, end: 0.7);

/// Tween for exit reverse dim
final Tween<double> exitRevDimTween = Tween<double>(begin: 1.0, end: 0.93);

/// Tween that always evaluates to one
final Tween<double> constTween = Tween<double>(begin: 1.0, end: 1.0);

/// Abstract class to create various route transitions
abstract class RouteTransition<T extends Widget> extends PageRouteBuilder<T> {
  final T route;


  /// Function that checks whether to play enter animation or not
  ///
  /// E.G disable enter animation for main route
  BoolFunction checkEntAnimationEnabled;

  /// Function that checks whether to play exit animation or not
  ///
  /// E.G disable exit animation for particular route pushes
  BoolFunction checkExitAnimationEnabled;

  /// A curve for enter animation
  ///
  /// Defaults to [Curves.linearToEaseOut]
  final Curve entCurve;

  /// A curve for reverse enter animation
  ///
  /// Defaults to [Curves.easeInToLinear]
  final Curve entReverseCurve;

  /// A curve for exit animation
  ///
  /// Defaults to [Curves.linearToEaseOut]
  final Curve exitCurve;

  /// A curve for reverse exit animation
  ///
  /// Defaults to [Curves.easeInToLinear]
  final Curve exitReverseCurve;

  /// Whether to ignore touch events while enter forward animation
  ///
  /// Defaults to false
  final bool entIgnoreEventsForward;

  /// Whether to ignore touch events while exit forward animation
  ///
  /// Defaults to false
  final bool exitIgnoreEventsForward;

  /// Whether to ignore touch events while exit reverse animation
  ///
  /// Defaults to false
  final bool exitIgnoreEventsReverse;

  /// Function to get system Ui to be set when navigating to route
  ///
  /// Defaults to [Constants.AppSstemUIThemes.allScreens.auto(context)]
  UIFunction? checkSystemUi;

  @override
  late RoutePageBuilder pageBuilder;

  @override
  late RouteTransitionsBuilder transitionsBuilder;

  /// Variable to disable the animation switch call if ui is already animating.
  ///
  /// Mostly needed to correctly switch when popping the route, because secondaryAnimation status listener is called multiple times.
  bool uiAnimating = false;

  /// Says when to disable [animation]
  bool entAnimationEnabled = false;

  /// Says when to disable [secondaryAnimation]
  bool exitAnimationEnabled = false;

  /// Says when to ignore widget in [animation]
  bool ignore = false;

  /// Says when to ignore widget in [secondaryAnimation]
  bool secondaryIgnore = false;

  RouteTransition({
    required this.route,
    this.checkEntAnimationEnabled = defBoolFunc,
    this.checkExitAnimationEnabled = defBoolFunc,
    this.entCurve = Curves.linearToEaseOut,
    this.entReverseCurve = Curves.easeInToLinear,
    this.exitCurve = Curves.linearToEaseOut,
    this.exitReverseCurve = Curves.easeInToLinear,
    this.entIgnoreEventsForward = false,
    this.exitIgnoreEventsForward = false,
    this.exitIgnoreEventsReverse = false,
    this.checkSystemUi,
    Duration transitionDuration = kSMMRouteTransitionDuration,
    RouteSettings? settings,
    bool opaque = true,
    bool maintainState = false,
  }) : super(
            settings: settings,
            opaque: opaque,
            maintainState: maintainState,
            transitionDuration: transitionDuration,
            pageBuilder: (
              BuildContext? context,
              Animation<double>? animation,
              Animation<double>? secondaryAnimation,
            ) {
              return route;
            });



  /// Checks if animation  must be enabled
  void handleEnabledCheck(
      Animation<double> animation, Animation<double> secondaryAnimation) {
    animation.addStatusListener((status) {
      entAnimationEnabled = checkEntAnimationEnabled();
    });
    secondaryAnimation.addStatusListener((status) {
      exitAnimationEnabled = checkExitAnimationEnabled();
    });
  }

  /// Checks if route taps must be ignored
  void handleIgnoranceCheck(
      Animation<double> animation, Animation<double> secondaryAnimation) {
    animation.addStatusListener((status) {
      ignore = entIgnoreEventsForward && status == AnimationStatus.forward;
    });

    secondaryAnimation.addStatusListener((status) {
      secondaryIgnore =
          exitIgnoreEventsForward && status == AnimationStatus.forward ||
              exitIgnoreEventsReverse && status == AnimationStatus.reverse;
    });
  }
}


/// [SlideTransition] class, but with [enabled] parameter
class TurnableSlideTransition extends SlideTransition {
  TurnableSlideTransition(
      {Key? key,
      required Animation<Offset> position,
      bool transformHitTests: true,
      required TextDirection textDirection,
      required Widget? child,
      this.enabled: true})
      : super(
          key: key,
          position: position,
          transformHitTests: transformHitTests,
          textDirection: textDirection,
          child: child!,
        );

  /// If false, animation won't be played
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      Offset offset = position.value;
      if (textDirection == TextDirection.rtl)
        offset = Offset(-offset.dx, offset.dy);
      return FractionalTranslation(
        translation: offset,
        transformHitTests: transformHitTests,
        child: child,
      );
    }
    return child!;
  }
}
