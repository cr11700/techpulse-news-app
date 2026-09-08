import 'package:flutter/material.dart';
import 'package:tech_pulse/models/article/graph_ql_node.dart';

class UserFull extends GraphQLNode {
  final String uid;
  final String name;
  final String? avatar;
  final String bio;
  UserFull({
    required super.nodeId,
    required this.uid,
    required this.name,
    required this.avatar,
    required this.bio,
  });

  factory UserFull.fromGraphNode(dynamic node) {
    return UserFull(
      nodeId: node.nodeId,
      uid: node.uid!,
      name: node.name!,
      bio: node.bio!,
      avatar: node.avatar,
    );
  }

  Widget getAvatar({double? radius, bool hero = true}) {
    String avatarURL;
    if (avatar != null && avatar != '') {
      avatarURL = avatar!;
    } else {
      avatarURL =
          'https://supabase.pc.ncepu.lxy0423.top/storage/v1/object/public/public_images/avatar.jpg';
    }
    final circleAvatar = CircleAvatar(
      radius: radius,
      foregroundImage: NetworkImage(avatarURL),
    );
    if (hero) {
      return Hero(tag: ValueKey(nodeId), child: circleAvatar);
    }
    return circleAvatar;
  }
}
