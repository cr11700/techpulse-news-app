import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:tech_pulse/ui/controllers/article_page_controller.dart';
import 'package:tech_pulse/ui/routes/bottom_sheet.dart';
import 'package:tech_pulse/ui/widgets/article/comment_input_modal_popup.dart';

class ArticlePageAppBar extends GetView<ArticlePageController> {
  const ArticlePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60,
      child: Row(
        spacing: 8.0,
        children: [
          Expanded(child: _buildCommentButton()),
          _buildShareLikeRow(),
        ],
      ),
    );
  }

  // 转发、点赞（非输入评论状态）
  Row _buildShareLikeRow() {
    return Row(
      spacing: 8,
      children: [
        ActionChip(
          avatar: Icon(Icons.share),
          label: Text('转发'),
          onPressed: () {},
        ),
        Obx(
          () => ActionChip(
            avatar: Icon(controller.isLiked ? Icons.thumb_up_rounded: Icons.thumb_up_outlined),
            label: Text(controller.isLiked ? '已赞' : '点赞'),
            onPressed: () {
              controller.onLikeButtonPressed();
            },
          ),
        ),
      ],
    );
  }

  // 评论按钮（非输入评论状态）
  FilledButton _buildCommentButton() {
    return FilledButton.tonal(
      onPressed: () {
        showMyBottomSheet(child: CommentInputModalPopup());
      },
      child: Text('评论千万条，等你这一条', maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
