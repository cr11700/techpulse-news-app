import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:tech_pulse/ui/routes/routes.dart';

class MatrixTransitionWithoutHitTestTransform extends MatrixTransition {
  /// Creates a matrix transition.
  ///
  /// The [alignment] argument defaults to [Alignment.center].
  const MatrixTransitionWithoutHitTestTransform({
    super.key,
    required super.animation,
    required super.onTransform,
    super.alignment = Alignment.center,
    super.filterQuality,
    super.child,
  });

  @override
  Widget build(BuildContext context) {
    // The ImageFilter layer created by setting filterQuality will introduce
    // a saveLayer call. This is usually worthwhile when animating the layer,
    // but leaving it in the layer tree before the animation has started or after
    // it has finished significantly hurts performance.
    return Transform(
      transformHitTests: false,
      transform: onTransform(animation.value),
      alignment: alignment,
      filterQuality: animation.isAnimating ? filterQuality : null,
      child: child,
    );
  }
}

class MyDialogPageRoute<T> extends PageRoute<T> {
  /// A general dialog route which allows for customization of the dialog popup.
  MyDialogPageRoute({
    required RoutePageBuilder pageBuilder,
    Duration transitionDuration = const Duration(milliseconds: 400),
    super.settings,
    super.requestFocus,
    this.anchorPoint,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
  }) : _pageBuilder = pageBuilder,
       _transitionDuration = transitionDuration;

  final RoutePageBuilder _pageBuilder;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  @override
  bool get opaque => false;

  final Offset? anchorPoint;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: DisplayFeatureSubScreen(
        anchorPoint: anchorPoint,
        child: _pageBuilder(context, animation, secondaryAnimation),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return MyDialogForegroundTransition(animation: animation, child: child);
  }

  @override
  bool get maintainState => true;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => _delegatedTransition;

  static Widget? _delegatedTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool allowSnapshotting,
    Widget? child,
  ) {
    final clippingAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 80),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 20),
    ]).animate(secondaryAnimation);
    final curvedAnim = CurvedAnimation(
      parent: clippingAnim,
      curve: Curves.easeInOut,
    );
    final rRectAnim = Tween<double>(begin: 0.0, end: 16.0).animate(curvedAnim);
    final slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, 0.02),
    ).animate(curvedAnim);
    return SlideTransition(
      position: slideAnim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(curvedAnim),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(rRectAnim.value),
          child: child,
        ),
      ),
    );
  }

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;
  @override
  bool get barrierDismissible => true;
}

class MyDialogForegroundTransition extends StatelessWidget {
  const MyDialogForegroundTransition({
    super.key,
    required this.animation,
    required this.child,
  });
  final Animation<double> animation;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: animation.value * 5,
        sigmaY: animation.value * 5,
      ),
      child: DualTransitionBuilder(
        animation: animation,
        child: child,
        forwardBuilder: (context, animation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.linearToEaseOut,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1),
              end: Offset(0, 0),
            ).animate(curvedAnimation),
            child: MatrixTransitionWithoutHitTestTransform(
              animation: Tween<double>(
                begin: 1.0,
                end: 0.0,
              ).animate(curvedAnimation),
              onTransform: (double value) {
                return Matrix4.identity()
                  ..setEntry(3, 2, 0.005)
                  ..rotateX(-math.pi * 0.5 * value)
                  ..scale(1 - value);
              },
              child: child,
            ),
          );
        },
        reverseBuilder: (context, animation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.linearToEaseOut,
          );
          final bluredValue = Tween<double>(
            begin: 0.0,
            end: 5.0,
          ).animate(curvedAnimation);
          final tweenSeqOffsetAnim = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -0.05),
          ).animate(curvedAnimation);
          final tweenSeqScaleAnim = Tween<double>(
            begin: 1.0,
            end: 0.85,
          ).animate(curvedAnimation);
          return ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: bluredValue.value,
              sigmaY: bluredValue.value,
            ),
            child: SlideTransition(
              position: tweenSeqOffsetAnim,
              child: ScaleTransition(
                scale: tweenSeqScaleAnim,
                child: MatrixTransitionWithoutHitTestTransform(
                  animation: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(curvedAnimation),
                  onTransform: (double value) {
                    return Matrix4.identity()..scale(1 + value * 0.4);
                  },
                  child: FadeTransition(
                    opacity: Tween(
                      begin: 1.0,
                      end: 0.0,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<T?> showMyDialog<T>({BuildContext? context, required Widget child}) {
  context ??= navigatorKey.currentContext!;
  return Navigator.of(context).push(
    MyDialogPageRoute(
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
    ),
  );
}
