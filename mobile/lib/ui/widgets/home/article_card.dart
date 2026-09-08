import 'package:flutter/material.dart';
import 'package:tech_pulse/models/article/exports.dart';
import 'package:tech_pulse/ui/controllers/home_page_controller.dart';
import 'package:tech_pulse/utils/l10n_date_time_utils.dart';
import 'package:tech_pulse/ui/widgets/home/article_image.dart';

// 新闻卡片（双列）
class ArticleCardWidget extends StatelessWidget {
  const ArticleCardWidget(this.article, {super.key, required this.heroTag});
  final Key heroTag;
  final ArticleSimple article;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => HomePageController.to.openArticle(article, heroTag),
              child: Column(
                children: [
                  SizedBox(
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        _buildImageWithShadow(heroTag),
                        _buildArticleViewInfo(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8.0,
                        children: [
                          Text(
                            article.titleCn,
                            style: TextStyle(fontSize: 14, height: 1.2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            spacing: 8,
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: Image.network(
                                    article.authorAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  article.authorName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: IconButton(
              onPressed: () {},
              iconSize: 15,
              constraints: BoxConstraints.loose(Size(40, 40)),
              icon: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleViewInfo() {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Row(
        spacing: 4,
        children: [
          Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.white),
          Text(
            article.views.toString(),
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
          SizedBox(width: 4),
          Icon(Icons.thumb_up_outlined, size: 12, color: Colors.white),
          Text(
            article.likes.toString(),
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
          Spacer(),
          Text(
            L10nDateTimeUtils.timeAgo(article.pubTime),
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  AspectRatio _buildImageWithShadow(Key heroTag) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black87],
            begin: Alignment.center,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Hero(
          tag: heroTag,
          child: ArticleImage(
            nodeId: article.nodeId,
            thumbImg: article.thumbImg,
            headerImg: article.headerImg,
          ),
        ),
      ),
    );
  }
}
