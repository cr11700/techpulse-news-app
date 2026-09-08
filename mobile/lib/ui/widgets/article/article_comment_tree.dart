import 'package:comment_tree/comment_tree.dart';
import 'package:flutter/material.dart';

class ArticleCommentTree extends StatelessWidget {
  const ArticleCommentTree({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CommentTreeWidget<Comment, Comment>(
      Comment(
        avatar: null,
        userName: '用户名',
        content: 'felangel made felangel/cubit_and_beyond public ',
      ),
      [
        Comment(
          avatar: null,
          userName: '用户名',
          content: 'A Dart template generator which helps teams',
        ),
        Comment(
          avatar: null,
          userName: '用户名',
          content:
              'A Dart template generator which helps teams generator which helps teams generator which helps teams',
        ),
      ],
      treeThemeData: TreeThemeData(lineColor: colorScheme.primary, lineWidth: 3),
      avatarRoot: (context, data) => PreferredSize(
        preferredSize: Size.fromRadius(18),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(
            'https://supabase.pc.ncepu.lxy0423.top/storage/v1/object/public/public_images/author_avatars/f0/f0d30e82a9b9f6ba3298c2e636e9e72f.png',
          ),
        ),
      ),
      avatarChild: (context, data) => PreferredSize(
        preferredSize: Size.fromRadius(12),
        child: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(
            'https://supabase.pc.ncepu.lxy0423.top/storage/v1/object/public/public_images/author_avatars/f0/f0d30e82a9b9f6ba3298c2e636e9e72f.png',
          ),
        ),
      ),
      contentChild: (context, data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.userName ?? '',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${data.content}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w300,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Text('点赞'),
                    SizedBox(width: 24),
                    Text('回复'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      contentRoot: (context, data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dangngocduc',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${data.content}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w300,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Text('点赞'),
                    SizedBox(width: 24),
                    Text('回复'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
