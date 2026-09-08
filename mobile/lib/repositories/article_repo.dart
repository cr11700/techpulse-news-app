import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tech_pulse/api/graphql/query/articles/mutation_article_like.graphql.dart';
import 'package:tech_pulse/models/article/exports.dart';
import 'package:tech_pulse/services/article_cache_service.dart';
import 'package:tech_pulse/services/graphql_service.dart';
import 'package:tech_pulse/api/graphql/query/articles/query_home_page.graphql.dart';
import 'package:tech_pulse/api/graphql/query/articles/query_article_detail.graphql.dart';

class ArticleRepository {
  final ArticleCacheService _cache;
  final GraphqlService _graphql;
  ArticleRepository(ArticleCacheService cache, GraphqlService graphql)
    : _cache = cache,
      _graphql = graphql;

  FetchPolicy _getFetchPolicy(bool forceRefresh) {
    if (forceRefresh) {
      return FetchPolicy.networkOnly;
    }
    return FetchPolicy.cacheAndNetwork;
  }

  Future<Query$HomePageArticleCollection?> _queryHomePageArticles(
    String? after, {
    bool forceRefresh = false,
  }) async {
    final queryResult = await _graphql.client.query$HomePageArticleCollection(
      Options$Query$HomePageArticleCollection(
        variables: Variables$Query$HomePageArticleCollection(after: after),
        fetchPolicy: _getFetchPolicy(forceRefresh),
      ),
    );
    return _getParsedData(queryResult);
  }

  Future<Query$HomePageArticleByTag?> _queryHomePageArticlesByTag(
    int tagId,
    String? after, {
    bool forceRefresh = false,
  }) async {
    final queryResult = await _graphql.client.query$HomePageArticleByTag(
      Options$Query$HomePageArticleByTag(
        variables: Variables$Query$HomePageArticleByTag(
          tag: tagId,
          after: after,
        ),
        fetchPolicy: _getFetchPolicy(forceRefresh),
      ),
    );
    return _getParsedData(queryResult);
  }

  Future<Query$HomePageArticleByPublisher?> _queryHomePageArticlesByPublisher(
    int publisherId,
    String? after, {
    bool forceRefresh = false,
  }) async {
    final queryResult = await _graphql.client.query$HomePageArticleByPublisher(
      Options$Query$HomePageArticleByPublisher(
        variables: Variables$Query$HomePageArticleByPublisher(
          publisherId: publisherId,
          after: after,
        ),
        fetchPolicy: _getFetchPolicy(forceRefresh),
      ),
    );
    return _getParsedData(queryResult);
  }

  Future<Query$HomePageTags?> _queryHomePageTags({
    bool forceRefresh = false,
  }) async {
    final queryResult = await _graphql.client.query$HomePageTags(
      Options$Query$HomePageTags(fetchPolicy: _getFetchPolicy(forceRefresh)),
    );
    return _getParsedData(queryResult);
  }

  Future<Query$PublisherCollection?> _queryPublishers({
    bool forceRefresh = false,
  }) async {
    final queryResult = await _graphql.client.query$PublisherCollection(
      Options$Query$PublisherCollection(
        fetchPolicy: _getFetchPolicy(forceRefresh),
      ),
    );
    return _getParsedData(queryResult);
  }

  Future<Query$ArticleDetailNode?> _queryArticleDetail(
    String nodeId, {
    bool forceRefresh = false,
  }) async {
    final queryResult = await _graphql.client.query$ArticleDetailNode(
      Options$Query$ArticleDetailNode(
        variables: Variables$Query$ArticleDetailNode(nodeId: nodeId),
        fetchPolicy: _getFetchPolicy(forceRefresh),
      ),
    );
    return _getParsedData(queryResult);
  }

  T? _getParsedData<T>(QueryResult<T> queryResult) {
    if (queryResult.hasException) {
      debugPrint(queryResult.exception.toString());
      return null;
    }
    return queryResult.parsedData;
  }

  Future<ArticleFull?> getArticle(String nodeId) async {
    ArticleFull? article = _cache.getArticleFull(nodeId);
    if (article != null) return article;
    final result = await _queryArticleDetail(nodeId);
    if (result == null) {
      return null;
    }
    final articleFull = ArticleFull.fromGraphQL(result);
    _cache.putArticleFull(articleFull);
    return articleFull;
  }

  Future<ArticleSimple?> getArticleSimple(String nodeId) async {
    ArticleSimple? article = _cache.getArticleSimple(nodeId);
    if (article != null) return article;
    await getArticle(nodeId);
    // getArticle会同时将ArticleFull和ArticleSimple存入缓存，因此可直接从缓存中获取simple
    return _cache.getArticleSimple(nodeId);
  }

  Future<({List<ArticleSimple> articles, String? endCursor, bool hasMore})>
  getArticleList({
    String? fetchMoreCursor,
    int? tagId,
    int? publisherId,
    bool forceRefresh = false,
  }) async {
    List<ArticleSimple> articles = [];
    dynamic edges;
    dynamic pageInfo;
    if (tagId != null) {
      // 根据标签过滤
      final result = await _queryHomePageArticlesByTag(
        tagId,
        fetchMoreCursor,
        forceRefresh: forceRefresh,
      );
      if (result != null && result.get_articles_by_tag != null) {
        edges = result.get_articles_by_tag!.edges;
        pageInfo = result.get_articles_by_tag!.pageInfo;
      }
    } else if (publisherId != null) {
      // 根据出版社过滤
      final result = await _queryHomePageArticlesByPublisher(
        publisherId,
        fetchMoreCursor,
        forceRefresh: forceRefresh,
      );
      if (result != null && result.articleCollection != null) {
        edges = result.articleCollection!.edges;
        pageInfo = result.articleCollection!.pageInfo;
      }
    } else {
      // 首页推荐
      final result = await _queryHomePageArticles(
        fetchMoreCursor,
        forceRefresh: forceRefresh,
      );
      if (result != null && result.articleCollection != null) {
        edges = result.articleCollection!.edges;
        pageInfo = result.articleCollection!.pageInfo;
      }
    }
    if (edges != null) {
      for (final node in edges) {
        final article = ArticleSimple.fromGraphNode(node);
        _cache.putArticleSimple(article);
        articles.add(article);
      }
      return (
        articles: articles,
        endCursor: pageInfo.endCursor as String?,
        hasMore: true,
      );
    }
    return (articles: const <ArticleSimple>[], endCursor: null, hasMore: false);
  }

  Future<List<TagFull>> getPredefinedTags({bool forceRefresh = false}) async {
    final result = await _queryHomePageTags(forceRefresh: forceRefresh);
    if (result != null && result.tagCollection != null) {
      return result.tagCollection!.edges
          .map((e) => TagFull.fromGraphNode(e.node))
          .toList();
    }
    return [];
  }

  Future<List<PublisherFull>> getPublishers({bool forceRefresh = false}) async {
    final result = await _queryPublishers(forceRefresh: forceRefresh);
    if (result != null && result.publisherCollection != null) {
      return result.publisherCollection!.edges
          .map((e) => PublisherFull.fromGraphNode(e.node))
          .toList();
    }
    return [];
  }

  // Mutation
  Future<ArticleFull?> likeArticle({
    required String uid,
    required ArticleFull article,
  }) async {
    final result = await _graphql.client
        .mutate$InsertIntolike_articleCollection(
          Options$Mutation$InsertIntolike_articleCollection(
            variables: Variables$Mutation$InsertIntolike_articleCollection(
              uid: uid,
              articleId: article.articleId,
            ),
          ),
        );
    if (result.hasException) {
      return null;
    }
    final modifiedArticle = article.copyWith(
      isLiked: true,
      likes: article.likes + 1,
    );
    _cache.putArticleFull(modifiedArticle);
    return modifiedArticle;
  }

  Future<ArticleFull?> dislikeArticle({required ArticleFull article}) async {
    final result = await _graphql.client
        .mutate$DeleteFromlike_articleCollection(
          Options$Mutation$DeleteFromlike_articleCollection(
            variables: Variables$Mutation$DeleteFromlike_articleCollection(
              articleId: article.articleId,
            ),
          ),
        );
    if (result.hasException) {
      return null;
    }
    final modifiedArticle = article.copyWith(
      isLiked: false,
      likes: article.likes - 1,
    );
    _cache.putArticleFull(modifiedArticle);
    return modifiedArticle;
  }
}
