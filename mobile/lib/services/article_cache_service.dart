import 'package:get/get.dart';
import 'package:tech_pulse/models/article/exports.dart';

class ArticleCacheService extends GetxService {
  static ArticleCacheService get to => Get.find<ArticleCacheService>();
  final Map<String, ArticleSimple> _articleSimpleCache = {};
  final Map<String, ArticleFull> _articleCache = {};
  ArticleFull? getArticleFull(String nodeId) {
    return _articleCache[nodeId];
  }

  void putArticleFull(ArticleFull article) {
    _articleCache[article.nodeId] = article;
  }

  ArticleSimple? getArticleSimple(String nodeId) {
    ArticleSimple? simple = _articleSimpleCache[nodeId];
    if (simple != null) return simple;
    ArticleFull? full = _articleCache[nodeId];
    if (full != null) {
      simple = ArticleSimple.fromFull(full);
      _articleSimpleCache[nodeId] = simple;
    }
    return simple;
  }

  void putArticleSimple(ArticleSimple article) {
    _articleSimpleCache[article.nodeId] = article;
  }
}
