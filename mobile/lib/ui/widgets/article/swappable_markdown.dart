import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:tech_pulse/services/preference_storage_service.dart';
import 'package:tech_pulse/ui/routes/routes.dart';

class MultiLangMarkdownSegment {
  final String en;
  final String zh;
  MultiLangMarkdownSegment({required this.en, required this.zh});
}

class TapSwapMarkdownSegment extends StatefulWidget {
  const TapSwapMarkdownSegment(this.segment, {super.key});

  final MultiLangMarkdownSegment segment;

  @override
  State<TapSwapMarkdownSegment> createState() => _TapSwapMarkdownSegmentState();
}

class _TapSwapMarkdownSegmentState extends State<TapSwapMarkdownSegment> {
  bool showingChineseContent = false;
  Offset? _tapDownPosition;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTapDown: (details) {
          _tapDownPosition = details.globalPosition;
        },
        onLongPress: _showContextMenu,
        onTap: () {
          setState(() {
            showingChineseContent = !showingChineseContent;
          });
        },
        child: Align(
          alignment: Alignment.topLeft,
          child: AnimatedSize(
            clipBehavior: Clip.none,
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastLinearToSlowEaseIn,
            child: AbsorbPointer(
              absorbing: !PreferenceStorageService.to.getPreference<bool>(
                PrefKey.enableExternalLink,
              ),
              child: MarkdownBlock(
                data: showingChineseContent
                    ? widget.segment.zh
                    : widget.segment.en,
                selectable: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showContextMenu() async {
    if (_tapDownPosition == null) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(_tapDownPosition!, _tapDownPosition!),
      Offset.zero & overlay.size,
    );

    final userChoice = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      items: [
        _buildPopMenuItem('copy', '复制', Icons.copy),
        _buildPopMenuItem('share', '分享', Icons.share),
        _buildPopMenuItem('report', '举报', Icons.report_problem),
      ],
    );
    if (userChoice == null) return;

    final text = showingChineseContent ? widget.segment.zh : widget.segment.en;

    switch (userChoice) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: text));
        showSnackBar(const SnackBar(content: Text('已复制')));
        break;
      case 'share':
        // Share.share(text);
        break;
      case 'report':
        showSnackBar(const SnackBar(content: Text('我们已收到您的反馈')));
        break;
    }
  }

  PopupMenuItem<String> _buildPopMenuItem(
    String value,
    String text,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Text(text),
        ],
      ),
    );
  }
}

class TapSwapMarkdown extends StatelessWidget {
  const TapSwapMarkdown({super.key, required this.segments});
  final List<MultiLangMarkdownSegment> segments;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: segments.length,
        (context, index) => TapSwapMarkdownSegment(segments[index]),
      ),
    );
  }
}
