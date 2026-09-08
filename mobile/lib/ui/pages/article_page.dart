import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tech_pulse/ui/controllers/article_page_controller.dart';
import 'package:tech_pulse/models/article/exports.dart';
import 'package:tech_pulse/ui/routes/routes.dart';
import 'package:tech_pulse/ui/widgets/article/article_comment_tree.dart';
import 'package:tech_pulse/ui/widgets/article/article_page_app_bar.dart';
import 'package:tech_pulse/ui/widgets/article/swappable_markdown.dart';
import 'package:tech_pulse/utils/l10n_date_time_utils.dart';
import 'package:tech_pulse/ui/widgets/article/ai_summary_card.dart';
import 'package:tech_pulse/ui/widgets/home/article_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePageRouteParams {
  ArticleSimple articleSimple; // 将要展示的ArticleSimple对象
  Key? heroTag; // 调用者heroTag
  ArticlePageRouteParams(this.articleSimple, {this.heroTag});
}

class ArticlePage extends GetView<ArticlePageController> {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlePageRouteParams routeData = getArguments(context);
    return Scaffold(
      body: GetBuilder<ArticlePageController>(
        init: ArticlePageController(),
        builder: (controller) {
          controller.routeData = routeData;
          return _buildPageContent(context, routeData);
        },
      ),
      bottomNavigationBar: ArticlePageAppBar(),
    );
  }

  NestedScrollView _buildPageContent(
    BuildContext context,
    ArticlePageRouteParams routeData,
  ) {
    final simple = routeData.articleSimple;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar.medium(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: routeData.heroTag ?? UniqueKey(),
              child: ArticleImage(
                nodeId: simple.nodeId,
                thumbImg: simple.thumbImg,
                headerImg: simple.headerImg,
              ),
            ),
          ),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
          title: Text(simple.titleCn),
          pinned: true,
        ),
      ],
      body: FutureBuilder<ArticleFull?>(
        future: controller.articleFuture,
        builder: (BuildContext context, AsyncSnapshot<ArticleFull?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting
            return Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            // Show an error message if something went wrong
            return const Text(
              'Something went wrong while loading the article. Please try again later.',
            ); //TODO: 实现错误页面
          } else {
            // Show the data once it's available
            return _buildBody(context, snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ArticleFull articleFull) {
    final textStyle = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Text(
                articleFull.titleCn,
                style: textStyle.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              _buildAuthor(articleFull),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AISummaryCardWidget(summary: articleFull.summaryCn),
              ),
              SizedBox(height: 16.0),
            ]),
          ),
          TapSwapMarkdown(segments: articleFull.segments),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ...articleFull.tags.map<Widget>(
                    (e) => ActionChip.elevated(
                      elevation: 0,
                      avatar: Icon(Icons.tag),
                      label: Text(e.valueCn),
                      onPressed: () {},
                    ),
                  ),
                  ...articleFull.tagsPlain.map<Widget>(
                    (e) => ActionChip.elevated(
                      elevation: 0,
                      label: Text(e),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(articleFull.url));
                    },
                    child: Text(
                      '阅读原文',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  Text(
                    '阅读 ${articleFull.views}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  '留言 12',
                  style: textStyle.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              ArticleCommentTree(),
              Divider(),
              Text(
                '没有更多了~',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Row _buildAuthor(ArticleFull article) {
    return Row(
      spacing: 8,
      children: [
        CircleAvatar(
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(1000),
            child: Image.network(article.author.avatar, fit: BoxFit.cover),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(article.author.name),
              Text('发布于：${L10nDateTimeUtils.toStringLocal(article.pubTime)}'),
            ],
          ),
        ),
        ActionChip.elevated(
          avatar: Icon(Icons.add, color: Colors.white),
          label: Text('关注', style: TextStyle(color: Colors.white)),
          onPressed: () {},
          color: WidgetStateProperty.all(Colors.purple[400]),
        ),
      ],
    );
  }
}
