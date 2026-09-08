import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ArticleApi extends GetConnect {
  ArticleApi() {
    httpClient.baseUrl = dotenv.env['REST_BASE_URL']!;
  }

  Future<void> trackView(int id) async {
    final res = await post('/api/stats/view/$id', null);
    if (res.statusCode == null || res.statusCode! >= 400) {
      throw Exception('trackView failed: ${res.statusCode} ${res.statusText}');
    }
  }
}
