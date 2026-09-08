import 'package:flutter/material.dart';
import 'package:tech_pulse/models/article/exports.dart';
import 'package:tech_pulse/ui/controllers/home_page_controller.dart';
import 'package:tech_pulse/ui/widgets/home/article_image.dart';

class StackedNewsHeadImage extends StatelessWidget {
  const StackedNewsHeadImage(this.article, {super.key, required this.heroTag});
  final Key heroTag;
  final ArticleSimple article;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => HomePageController.to.openArticle(article, heroTag),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SizedBox(
                    height: 220,
                    width: 8000,
                    child: ArticleImage(
                      nodeId: article.nodeId,
                      thumbImg: article.thumbImg,
                      headerImg: article.headerImg,
                    ),
                  ),
                ),
                SizedBox(
                  height: 220,
                  width: 8000,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.titleCn,
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          article.publisherName,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
