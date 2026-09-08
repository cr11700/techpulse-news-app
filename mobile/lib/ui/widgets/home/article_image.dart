import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.nodeId,
    required this.thumbImg,
    this.headerImg,
  });
  final String nodeId;
  final String thumbImg;
  final String? headerImg;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: thumbImg,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(value: downloadProgress.progress),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }
}
