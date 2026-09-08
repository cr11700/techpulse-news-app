import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';

class AISummaryCardWidget extends StatelessWidget {
  const AISummaryCardWidget({super.key, required this.summary});
  final String summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GlowContainer(
      glowRadius: 5,
      gradientColors: [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.purple,
      ],
      rotationDuration: Duration(seconds: 10),
      glowLocation: GlowLocation.both,
      containerOptions: ContainerOptions(
        borderRadius: 15,
        backgroundColor: Color.lerp(Colors.blue, colorScheme.surfaceContainer, 0.92),
        borderSide: BorderSide(width: 1.0, color: Colors.black),
      ),
      transitionDuration: Duration(milliseconds: 300),
      showAnimatedBorder: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandableText(
              summary,
              animation: true,
              collapseText: '收起',
              expandText: '展开',
              linkColor: Colors.blue,
              maxLines: 3,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Deepseek AI生成',
                style: textTheme.bodySmall!.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
