import 'package:tech_pulse/models/article/graph_ql_node.dart';

class PublisherFull extends GraphQLNode {
  int publisherId;
  String name;
  String icon;
  PublisherFull({
    required super.nodeId,
    required this.publisherId,
    required this.name,
    required this.icon,
  });

  factory PublisherFull.fromGraphNode(dynamic node) {
    return PublisherFull(
      nodeId: node.nodeId,
      publisherId: node.publisher_id,
      name: node.name,
      icon: node.icon,
    );
  }
}
