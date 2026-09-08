import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GraphqlService extends GetxService {
  static GraphqlService get to => Get.find<GraphqlService>();

  late final GraphQLClient client;
  late final HiveStore _hiveStore;
  @override
  void onInit() {
    super.onInit();
    _hiveStore = HiveStore();
    final HttpLink httpsLink = HttpLink(
      '${dotenv.env['SUPABASE_API_HOST']!}/graphql/v1',
      defaultHeaders: {'apiKey': dotenv.env['SUPABASE_ANON_KEY']!},
    );
    final AuthLink authLink = AuthLink(
      getToken: () async => Supabase.instance.client.auth.currentSession != null
          ? 'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}'
          : null,
    );
    final Link link = authLink.concat(httpsLink);
    client = GraphQLClient(
      link: link,
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.cacheAndNetwork),
      ),
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: _hiveStore),
    );
  }

  Future<void> clearCache() {
    return _hiveStore.reset();
  }
}
