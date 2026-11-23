import 'package:flutter/widgets.dart';

/// Centers page content and caps its width on large (web/desktop) screens.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child, this.maxWidth = 1080});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// Space reserved at the bottom of tab content for the floating nav bar.
double navBarClearance(BuildContext context) =>
    96 + MediaQuery.paddingOf(context).bottom;
