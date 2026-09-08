import 'package:flutter/material.dart';
import 'package:tech_pulse/ui/routes/routes.dart';

class MyBottomSheetPageRoute<T> extends PageRoute<T> {
  ///
  MyBottomSheetPageRoute({
    required RoutePageBuilder pageBuilder,
    Duration transitionDuration = const Duration(milliseconds: 400),
    super.settings,
    super.requestFocus,
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

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _pageBuilder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnim = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubicEmphasized,
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnim),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.0, 0.5),
          end: Offset(0.0, 0.0),
        ).animate(curvedAnim),
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => null;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;
  @override
  bool get barrierDismissible => true;
}

Future<T?> showMyBottomSheet<T>({
  BuildContext? context,
  required Widget child,
}) {
  context ??= navigatorKey.currentContext!;
  return Navigator.of(context).push(
    MyBottomSheetPageRoute(
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
    ),
  );
}
