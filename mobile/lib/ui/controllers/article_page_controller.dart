import 'package:get/get.dart';
import 'package:tech_pulse/models/article/exports.dart';
import 'package:tech_pulse/repositories/article_repo.dart';
import 'package:tech_pulse/services/article_cache_service.dart';
import 'package:tech_pulse/services/article_http_service.dart';
import 'package:tech_pulse/services/graphql_service.dart';
import 'package:tech_pulse/services/supabase_auth_service.dart';
import 'package:tech_pulse/ui/pages/article_page.dart';

class ArticlePageController extends GetxController {
  static ArticlePageController get to => Get.find<ArticlePageController>();
  final ArticleRepository _repo = ArticleRepository(
    ArticleCacheService.to,
    GraphqlService.to,
  );

  final SupabaseAuthService _auth = SupabaseAuthService.to;

  ArticlePageRouteParams? _routeData;
  set routeData(ArticlePageRouteParams value) {
    if (value != _routeData) {
      _routeData = value;
      articleFuture = getFullArticle(_routeData!.articleSimple.nodeId);
    }
  }

  final Rx<ArticleFull?> _articleFull = Rx(null);
  ArticleFull? get articeFull => _articleFull.value;
  bool get isLiked => articeFull != null && articeFull!.isLiked;

  ArticleSimple get articleSimple => _routeData!.articleSimple;

  late Future<ArticleFull?> articleFuture;

  Future<ArticleFull?> getFullArticle(String nodeId) async {
    final article = await _repo.getArticle(nodeId);
    _articleFull.value = article;
    if (article != null) {
      ArticleHttpService.to.trackView(article.articleId);
    }
    return article;
  }

  // 处理点赞按钮事件
  Future<void> onLikeButtonPressed() async {
    if (_articleFull.value != null) {
      if (_articleFull.value!.isLiked) {
        final result = await _repo.dislikeArticle(article: _articleFull.value!);
        if (result != null) {
          _articleFull.value = result;
        }
      } else {
        final user = _auth.getUser();
        if (user != null) {
          final result = await _repo.likeArticle(
            uid: user.id,
            article: _articleFull.value!,
          );
          if (result != null) {
            _articleFull.value = result;
          }
        }
      }
    }
  }
}
