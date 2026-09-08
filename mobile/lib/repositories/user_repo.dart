import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tech_pulse/api/graphql/query/users/query_user.graphql.dart';
import 'package:tech_pulse/models/user/user_full.dart';
import 'package:tech_pulse/services/graphql_service.dart';

class UserRepository {
  UserRepository(GraphqlService graphql) : _graphql = graphql;

  final GraphqlService _graphql;

  FetchPolicy _getFetchPolicy(bool forceRefresh) {
    if (forceRefresh) {
      return FetchPolicy.networkOnly;
    }
    return FetchPolicy.cacheAndNetwork;
  }

  T? _getParsedData<T>(QueryResult<T> queryResult) {
    if (queryResult.hasException) {
      if (kDebugMode) {
        debugPrint(queryResult.exception.toString());
      }
      return null;
    }
    return queryResult.parsedData;
  }

  Future<Query$GetUserByUid?> _queryUserByUid(
    String uid, {
    bool forceRefresh = false,
  }) async {
    final queryResult = await _graphql.client.query$GetUserByUid(
      Options$Query$GetUserByUid(
        variables: Variables$Query$GetUserByUid(uid: uid),
        fetchPolicy: _getFetchPolicy(forceRefresh),
      ),
    );
    return _getParsedData(queryResult);
  }

  Future<UserFull?> getMyProfile(
    String uid, {
    bool forceRefresh = false,
  }) async {
    final result = await _queryUserByUid(uid);
    if (result != null &&
        result.get_user_by_uid != null &&
        result.get_user_by_uid!.edges.isNotEmpty) {
      return UserFull.fromGraphNode(result.get_user_by_uid!.edges.first.node);
    }
    return null;
  }
}
