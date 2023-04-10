import 'package:dio/dio.dart';

import '../constants.dart';
import '../models/photo.dart';

class UnsplashApiService {
  final _dio = Dio();

  Future<List<Photo>> getPhotos({
    String? query,
    int? page,
    int? perPage,
  }) async {
    final hasQuery = !(query == null || query.isEmpty);
    final url = hasQuery
        ? '${Constants.baseUrl}/search/photos'
        : '${Constants.baseUrl}/photos';
    try {
      final response = await _dio.get(url, queryParameters: {
        'query': query,
        'client_id': Constants.apiKey,
        'page': page,
        'per_page': perPage,
      });

      if (response.statusCode == 200) {
        return mapResponse(response, hasQuery);
      }
      throw Exception('error fetching posts');
    } catch (error) {
      return List.empty();
    }
  }

  List<Photo> mapResponse(Response<dynamic> response, bool hasQuery) {
    List<dynamic> dynamicList =
        hasQuery ? response.data['results'] as List : response.data as List;
    List<Photo> photos = dynamicList
        .map((photo) => Photo(
            id: photo['id'] as String,
            user: photo['user'] as Map,
            urls: photo['urls'] as Map))
        .toList();
    return photos;
  }
}
