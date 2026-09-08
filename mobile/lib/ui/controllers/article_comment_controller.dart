import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/ui/routes/routes.dart';

class ArticleCommentController extends GetxController {
  static ArticleCommentController get to =>
      Get.find<ArticleCommentController>();

  late TextEditingController commentEditController;

  final Rx<String> _commentFieldLabel = Rx<String>('你猜我的评论区在等待谁？');
  String get commentFieldLabel => _commentFieldLabel.value;

  @override
  void onInit() {
    super.onInit();
    commentEditController = TextEditingController();
  }

  @override
  void onClose() {
    commentEditController.dispose();
    super.onClose();
  }

  Future<void> onSendComment() async {
    // TODO: 实现评论发布
    goBack();
    showSnackBar(SnackBar(content: Text('评论发布成功')));
  }
}
