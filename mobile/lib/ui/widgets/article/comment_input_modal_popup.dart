import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/ui/controllers/article_comment_controller.dart';

class CommentInputModalPopup extends GetView<ArticleCommentController> {
  const CommentInputModalPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArticleCommentController>(
      init: ArticleCommentController(),
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ModalBarrier(),
          bottomNavigationBar: BottomAppBar(
            height: 180,
            child: Column(
              spacing: 8,
              children: [
                Obx(
                  () => TextFormField(
                    autofocus: true,
                    controller: controller.commentEditController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: controller.commentFieldLabel,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.emoji_emotions_rounded),
                    ),
                    Spacer(),
                    FilledButton(
                      onPressed: controller.onSendComment,
                      child: Text('发布'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
