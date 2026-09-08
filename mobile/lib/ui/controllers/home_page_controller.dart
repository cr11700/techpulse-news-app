import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/models/article/exports.dart';
import 'package:tech_pulse/services/supabase_auth_service.dart';
import 'package:tech_pulse/ui/controllers/user_avatar_controller_mixin.dart';
import 'package:tech_pulse/ui/pages/article_page.dart';
import 'package:tech_pulse/ui/routes/routes.dart';
import 'package:tech_pulse/repositories/article_repo.dart';
import 'package:tech_pulse/services/article_cache_service.dart';
import 'package:tech_pulse/services/graphql_service.dart';

enum FixedTab {
  following,
  recommend;

  @override
  String toString() {
    switch (this) {
      case FixedTab.following:
        return '关注';
      case FixedTab.recommend:
        return '推荐';
    }
  }
}

class HomePageController extends GetxController
    with GetTickerProviderStateMixin, UserAvatarControllerMixin {
  static HomePageController get to => Get.find<HomePageController>();

  final ArticleRepository _repo = ArticleRepository(
    ArticleCacheService.to,
    GraphqlService.to,
  );

  final List<FixedTab> _fixedTabs = FixedTab.values; // 固定tab，置于所有tab最左端
  final List<PublisherFull> _publishers = []; // 文章发布者
  final List<TagFull> _tags = []; // 标签
  final List<List<ArticleSimple>?> _articles = [];
  final List<ArticleSimple?> _articleHeadlines = [];
  final List<String?> fetchMoreCursor = [];
  final List<bool> hasMore = [];
  TabController? tabController;

  Future<void> onAvatarPressed() async {
    if (SupabaseAuthService.to.isLoginned == false) {
      await goNamedRoute(Routes.userLogin);
      update();
    } else {
      goNamedRoute(Routes.user);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _rebuildTabContent();
    _prepareTabs();
  }

  Future<void> _prepareTabs() async {
    await _fetchPublishers();
    await _fetchTags();
    await _fetchSiblingTabContent(1);
  }

  // 获取相邻页面的内容
  Future<void> _fetchSiblingTabContent(int index) async {
    if (_articles[index] == null) {
      await forceRefreshArticles(index);
    }
    if (index + 1 < _articles.length && _articles[index + 1] == null) {
      await forceRefreshArticles(index + 1);
    }
    if (index - 1 >= 0 && _articles[index - 1] == null) {
      await forceRefreshArticles(index - 1);
    }
  }

  // 重建文章列表，注意此处为懒加载
  void _rebuildTabContent() {
    _articles.clear();
    _articleHeadlines.clear();
    final newTabsCount = _tags.length + _publishers.length + _fixedTabs.length;
    for (int i = 0; i < newTabsCount; i++) {
      _articles.add(null);
      _articleHeadlines.add(null);
      fetchMoreCursor.add(null);
      hasMore.add(true);
    }
    int initialIndex = 1;
    if (tabController != null) {
      TabController oldController = tabController!;
      initialIndex = oldController.index;
      Future.microtask(() => oldController.dispose());
    }
    tabController = TabController(
      length: newTabsCount,
      vsync: this,
      initialIndex: initialIndex,
    );
    // 当页面切换时，保证相邻页面已经加载
    tabController!.addListener(() {
      int index = tabController!.index;
      _fetchSiblingTabContent(index);
    });
    update();
  }

  // 从服务器获取最新标签
  Future<void> _fetchTags({bool forceRefresh = false}) async {
    final List<TagFull> newTags = await _repo.getPredefinedTags(
      forceRefresh: forceRefresh,
    );
    if (forceRefresh == true || newTags.length != _tags.length) {
      _tags.clear();
      _tags.addAll(newTags);
      _rebuildTabContent();
    }
  }

  // 从服务器获取最新来源
  Future<void> _fetchPublishers({bool forceRefresh = false}) async {
    final List<PublisherFull> newPublishers = await _repo.getPublishers(
      forceRefresh: forceRefresh,
    );
    if (forceRefresh == true || newPublishers.length != _publishers.length) {
      _publishers.clear();
      _publishers.addAll(newPublishers);
      _rebuildTabContent();
    }
  }

  Future<void> forceRefreshArticles(int index) async {
    _articles[index] = [];
    _articleHeadlines[index] = null;
    fetchMoreCursor[index] = null;
    hasMore[index] = true;
    return fetchMoreArticles(index);
  }

  Future<void> fetchMoreArticles(int index, {bool forceRefresh = false}) async {
    if (hasMore[index] == false && forceRefresh == false) return;
    if (_articles[index] == null) {
      forceRefreshArticles(index);
      return;
    }
    List<ArticleSimple> articles = [];
    String? resultEndCursor;
    bool resultHasMore = false;
    int relativeIndex = index;
    if (relativeIndex < _fixedTabs.length) {
      if (_fixedTabs[index] == FixedTab.recommend) {
        final result = await _repo.getArticleList(
          fetchMoreCursor: fetchMoreCursor[index],
          forceRefresh: forceRefresh,
        );
        articles = result.articles;
        resultEndCursor = result.endCursor;
        resultHasMore = result.hasMore;
      } else if (_fixedTabs[index] == FixedTab.following) {
        articles = []; // TODO: 实现获取已关注发布者
      }
    } else {
      relativeIndex -= _fixedTabs.length;
      if (relativeIndex < _publishers.length) {
        final result = await _repo.getArticleList(
          publisherId: _publishers[relativeIndex].publisherId,
          fetchMoreCursor: fetchMoreCursor[index],
          forceRefresh: forceRefresh,
        );
        articles = result.articles;
        resultEndCursor = result.endCursor;
        resultHasMore = result.hasMore;
      } else {
        relativeIndex -= _publishers.length;
        if (relativeIndex < _tags.length) {
          final result = await _repo.getArticleList(
            tagId: _tags[relativeIndex].tagId,
            fetchMoreCursor: fetchMoreCursor[index],
            forceRefresh: forceRefresh,
          );
          articles = result.articles;
          resultEndCursor = result.endCursor;
          resultHasMore = result.hasMore;
        }
      }
    }
    // 插入文章
    for (final articleSimple in articles) {
      // 只在主页显示头条新闻
      if (index == 1 && _articleHeadlines[index] == null) {
        _articleHeadlines[index] = articleSimple;
      } else {
        _articles[index]!.add(articleSimple);
      }
    }
    // 更新游标
    fetchMoreCursor[index] = resultEndCursor;
    hasMore[index] = resultHasMore;
    // 只更新索引所在的Tab
    update([ValueKey(index)]);
  }

  Future<Object?> openArticle(ArticleSimple simple, [Key? heroTag]) async {
    return goNamedRoute(
      Routes.article,
      arguments: ArticlePageRouteParams(simple, heroTag: heroTag),
    );
  }

  ArticleSimple? getCarouselArticle(int index) {
    return _articleHeadlines[index];
  }

  List<String> get tabs {
    return <String>[
      ..._fixedTabs.map((e) => e.toString()),
      ..._publishers.map((e) => e.name),
      ..._tags.map((e) => e.valueCn),
    ];
  }

  // 获取某一Tab的文章列表
  List<ArticleSimple> getTabContent(int index) {
    return _articles[index] ?? [];
  }
}
