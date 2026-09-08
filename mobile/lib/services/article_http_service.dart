import 'package:get/get.dart';
import 'package:tech_pulse/api/http/article/article.http.dart';

class ArticleHttpService {
  static ArticleHttpService get to => Get.find<ArticleHttpService>();
  final client = ArticleApi();

  Future<void> trackView(int id) => client.trackView(id);
}
