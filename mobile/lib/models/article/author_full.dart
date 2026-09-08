import 'package:tech_pulse/models/article/graph_ql_node.dart';

class AuthorFull extends GraphQLNode {
  int authorId;
  String name;
  String avatar;
  String? description;
  AuthorFull({
    required super.nodeId,
    required this.authorId,
    required this.name,
    required this.avatar,
    this.description,
  });

  factory AuthorFull.fromGraphNode(dynamic node) {
    return AuthorFull(
      nodeId: node.nodeId,
      authorId: node.author_id,
      avatar: node.avatar,
      description: node.description,
      name: node.name,
    );
  }
}
